//=============================================================================
// Module: debounce
// Description:
//   - btn_in: 물리 버튼(raw) 입력 (0 혹은 1, active-high 가정)
//   - clk: 시스템 클록
//   - rst_n: Active-Low 비동기 리셋
//   - btn_out: 디바운싱을 거친 안정된 버튼 상태 출력
//
// 동작 원리:
//   1) raw 버튼 값(btn_in)을 매 clk 엣지마다 샘플링하여 btn_sync에 저장
//   2) btn_sync가 이전 btn_state와 다르면 카운터를 0으로 리셋하고
//      새로운 값으로 변경된 시점을 기록
//   3) btn_sync가 계속 동일한 값으로 유지되어 카운터가 DEBOUNCE_MAX에 도달하면
//      비로소 btn_state를 btn_sync 값으로 업데이트. 이 값을 btn_out으로 출력
//
//=============================================================================

module debounce #(
    parameter COUNTER_WIDTH = 20,             // 카운터 폭 (예: 20비트 → 최대 약 1M 카운트)
    parameter DEBOUNCE_MAX  = 20'd999_999     // 디바운싱 타임 (예: 1MHz클록→약1초, 적절히 조정)
)(
    input  wire             clk,      // 시스템 클록
    input  wire             rst_n,    // Active-Low 비동기 리셋
    input  wire             btn_in,   // raw 버튼 입력 (Active-High 가정)
    output reg              btn_out   // 디바운스 완료된 버튼 출력
);

    //============================================================
    // 1) 버튼 입력 동기화 (2단 플립플롭) → 메타스테이블 방지
    //============================================================
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

    //============================================================
    // 2) 디바운스용 카운터 및 상태 저장
    //============================================================
    reg [COUNTER_WIDTH-1:0] cnt;        // 디바운싱 타이머
    reg                     btn_state;  // 마지막으로 확정된 버튼 상태

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt       <= {COUNTER_WIDTH{1'b0}};
            btn_state <= 1'b0;
            btn_out   <= 1'b0;
        end else begin
            if (btn_sync != btn_state) begin
                // raw 값(btn_sync)이 이전 확정 값(btn_state)과 다르면
                // → 카운터 리셋, 변화 감지된 상태로 잠시 유지
                cnt <= {COUNTER_WIDTH{1'b0}};
            end else if (cnt < DEBOUNCE_MAX) begin
                // 버튼 값이 여전히 같다면, 카운터를 조금씩 증가
                cnt <= cnt + 1'b1;
            end

            // 카운터가 DEBOUNCE_MAX에 도달했을 때 비로소 상태 확정
            if (cnt == DEBOUNCE_MAX) begin
                btn_state <= btn_sync;
                btn_out   <= btn_sync;
            end
            // (그 외에는 btn_out, btn_state 유지)
        end
    end

endmodule
