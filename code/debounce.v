module debounce #(
    parameter COUNTER_WIDTH = 20,             // 카운터 비트 폭 (예: 20비트)
    parameter DEBOUNCE_MAX  = 20'd999_999     // 100 MHz 클록 기준 약10 ms
)(
    input  wire             clk,      // 시스템 클록 (CLK100MHZ)
    input  wire             rst_n,    // Active-Low 리셋
    input  wire             btn_in,   // raw 버튼 입력 (Active-High)
    output reg              btn_out   // 디바운스 완료된 버튼 출력
);

    // 1) 메타스테이블 방지를 위한 2단 플립플롭 동기화
    reg btn_meta, btn_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_meta <= 1'b0;
            btn_sync <= 1'b0;
        end else begin
            btn_meta <= btn_in;
            btn_sync <= btn_meta;
        end
    end

    // 2) 디바운스용 카운터와 상태 레지스터
    reg [COUNTER_WIDTH-1:0] cnt;
    reg                     btn_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt       <= {COUNTER_WIDTH{1'b0}};
            btn_state <= 1'b0;
            btn_out   <= 1'b0;
        end else begin
            if (btn_sync != btn_state) begin
                // raw 상태 변화 → 카운터 리셋
                cnt <= {COUNTER_WIDTH{1'b0}};
            end else if (cnt < DEBOUNCE_MAX) begin
                // 안정 상태 유지 중 → 카운터 증가
                cnt <= cnt + 1'b1;
            end

            if (cnt == DEBOUNCE_MAX) begin
                // 지정 시간 동안 안정적이면 상태 확정
                btn_state <= btn_sync;
                btn_out   <= btn_sync;
            end
        end
    end

endmodule