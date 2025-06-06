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
