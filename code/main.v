//=============================================================================
// Module: debounce
// Description:
//   - btn_in: 물리 버튼(raw) 입력 (Active‐High 가정)
//   - clk: 시스템 클록 (Basys3 rev B의 CLK100MHZ, 100 MHz)
//   - rst_n: Active‐Low 리셋(btnC = 1 → reset_n = 0)
//   - btn_out: 디바운스 완료된 버튼 출력 (Active‐High)
//   - DEBOUNCE_MAX: 100 MHz × 10 ms ≈ 1,000,000 카운트
//=============================================================================
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


//=============================================================================
// Module: top (Debounced player_clk 적용)
// Description:
//   - Basys3 rev B 기준 XDC와 매칭되는 핀 이름으로 작성
//   - 내부 Debounce 모듈을 6개 인스턴스화하여 player_clk 벡터 생성
//   - game 모듈과 display_segment 모듈 연결
//=============================================================================
`timescale 1ns / 1ps

module top (
    input  wire        CLK100MHZ,  // 100 MHz 시스템 클록 (XDC: W5)
    input  wire        btnC,       // 리셋 버튼 (XDC: U18)

    inout  wire [7:0]  JA,         // Pmod JA (JA[3], JA[7]이 player_clk1,2)
    inout  wire [7:0]  JB,         // Pmod JB (JB[3], JB[7]이 player_clk3,4)
    inout  wire [7:0]  JC,         // Pmod JC (JC[3], JC[7]이 player_clk5,6)

    output wire [15:0] led,        // LED (XDC: U16..L1)
    output wire [6:0]  seg,        // 7-seg (XDC: W7,W6,U8,V8,U5,V5,U7)
    output wire [3:0]  an          // 7-seg 애노드 (XDC: U2,U4,V4,W4)
);

    //===============================================================
    // 1) game 모듈 출력용 신호
    //===============================================================
    wire [3:0] state;
    wire [2:0] out_code;
    assign led[15:12] = state;
    // 디버그 용도로 JA[7:0]을 LED[7:0]에 매핑
    assign led[7:0] = JA;

    //===============================================================
    // 2) Raw player_clk 신호 (Active-High, 물리 버튼 눌림 → 1)
    //    XDC에 PULLNONE 설정되어 있어야 함
    //    JA[3] = player1 clk, JA[7] = player2 clk
    //    JB[3] = player3 clk, JB[7] = player4 clk
    //    JC[3] = player5 clk, JC[7] = player6 clk
    //===============================================================
    wire raw_clk1 = JA[3];
    wire raw_clk2 = JA[7];
    wire raw_clk3 = JB[3];
    wire raw_clk4 = JB[7];
    wire raw_clk5 = JC[3];
    wire raw_clk6 = JC[7];

    //===============================================================
    // 3) Debounce 인스턴스 (6개)
    //    - clk: CLK100MHZ
    //    - rst_n: btnC = 1 → reset_n = 0 (Active-Low)
    //===============================================================
    wire db_clk1, db_clk2, db_clk3, db_clk4, db_clk5, db_clk6;

    debounce #(
        .COUNTER_WIDTH(20),
        .DEBOUNCE_MAX (20'd999_999)   // 100 MHz × 10ms ≈ 1,000,000
    ) db1 (
        .clk    (CLK100MHZ),
        .rst_n  (~btnC),
        .btn_in (raw_clk1),
        .btn_out(db_clk1)
    );
    debounce #(
        .COUNTER_WIDTH(20),
        .DEBOUNCE_MAX (20'd999_999)
    ) db2 (
        .clk    (CLK100MHZ),
        .rst_n  (~btnC),
        .btn_in (raw_clk2),
        .btn_out(db_clk2)
    );
    debounce #(
        .COUNTER_WIDTH(20),
        .DEBOUNCE_MAX (20'd999_999)
    ) db3 (
        .clk    (CLK100MHZ),
        .rst_n  (~btnC),
        .btn_in (raw_clk3),
        .btn_out(db_clk3)
    );
    debounce #(
        .COUNTER_WIDTH(20),
        .DEBOUNCE_MAX (20'd999_999)
    ) db4 (
        .clk    (CLK100MHZ),
        .rst_n  (~btnC),
        .btn_in (raw_clk4),
        .btn_out(db_clk4)
    );
    debounce #(
        .COUNTER_WIDTH(20),
        .DEBOUNCE_MAX (20'd999_999)
    ) db5 (
        .clk    (CLK100MHZ),
        .rst_n  (~btnC),
        .btn_in (raw_clk5),
        .btn_out(db_clk5)
    );
    debounce #(
        .COUNTER_WIDTH(20),
        .DEBOUNCE_MAX (20'd999_999)
    ) db6 (
        .clk    (CLK100MHZ),
        .rst_n  (~btnC),
        .btn_in (raw_clk6),
        .btn_out(db_clk6)
    );

    //===============================================================
    // 4) Debounced player_clk 벡터 생성 (MSB: player6, LSB: player1)
    //===============================================================
    wire [5:0] player_clk = { db_clk6, db_clk5, db_clk4, db_clk3, db_clk2, db_clk1 };

    //===============================================================
    // 5) Player 번호 3비트 입력 (Active-High)
    //    JA[2:0] = player1 val, JA[6:4] = player2 val
    //    JB[2:0] = player3 val, JB[6:4] = player4 val
    //    JC[2:0] = player5 val, JC[6:4] = player6 val
    //===============================================================
    wire [2:0] player1 = JA[2:0];
    wire [2:0] player2 = JA[6:4];
    wire [2:0] player3 = JB[2:0];
    wire [2:0] player4 = JB[6:4];
    wire [2:0] player5 = JC[2:0];
    wire [2:0] player6 = JC[6:4];

    //===============================================================
    // 6) game 모듈 인스턴스
    //===============================================================
    game game_inst (
        .player1    (player1),
        .player2    (player2),
        .player3    (player3),
        .player4    (player4),
        .player5    (player5),
        .player6    (player6),
        .player_clk (player_clk),
        .reset_n    (~btnC),
        .out        (out_code),
        .state_out  (state)
    );

    //===============================================================
    // 7) 7-세그먼트 디스플레이 인스턴스
    //===============================================================
    display_segment display_inst (
        .val(out_code),
        .seg(seg),
        .an(an)
    );

endmodule
