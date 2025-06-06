`timescale 1ns/1ps

module tb_game;

    // Inputs
    reg  [2:0] player1;
    reg  [2:0] player2;
    reg  [2:0] player3;
    reg  [2:0] player4;
    reg  [2:0] player5;
    reg  [2:0] player6;
    reg  [5:0] player_clk;
    reg        reset_n;

    // Outputs
    wire [2:0] out;         // 패배한 플레이어 번호 (000: 없음)
    wire [3:0] state_out;   // 현재 상태 또는 패배 상태 (MSB가 1이면 패배 상태)

    // Instantiate the DUT
    game uut (
        .player1    (player1),
        .player2    (player2),
        .player3    (player3),
        .player4    (player4),
        .player5    (player5),
        .player6    (player6),
        .player_clk (player_clk),
        .reset_n    (reset_n),
        .out        (out),
        .state_out  (state_out)
    );

    initial begin
        $dumpfile("tb_game.vcd");
        $dumpvars(0, tb_game);

        // 1) 초기화 및 리셋
        player1    = 3'b000;
        player2    = 3'b000;
        player3    = 3'b000;
        player4    = 3'b000;
        player5    = 3'b000;
        player6    = 3'b000;
        player_clk = 6'b000000;
        reset_n    = 1'b0;

        #20;
        reset_n = 1'b1;      // 리셋 해제 (게임 시작: 플레이어1의 차례가 되어야 함)

        // 2) 정상 진행: 플레이어1의 턴 → 유효 입력 (예: "두모" = 2)
        #20;
        player1    = 3'b010;     // 2: 왼쪽 한 칸으로 턴 이동
        player_clk = 6'b000001;  // player1 버튼 누름
        #10;
        player_clk = 6'b000000;  // 버튼 떼기

        // 3) 다음 플레이어 (player2) 차례: 유효 입력 (예: "1")
        #20;
        player2    = 3'b001;     // 1: 왼쪽 두 칸으로 턴 이동
        player_clk = 6'b000010;  // player2 버튼 누름
        #10;
        player_clk = 6'b000000;

        // 4) 다음 플레이어 (player4) 차례: 치명적 입력 ("세모" = 3 → 즉시 패배)
        #20;
        player4    = 3'b011;     // 3: 즉시 패배 상태
        player_clk = 6'b000100;  // player4 버튼 누름
        #10;
        player_clk = 6'b000000;

        // 5) 패배가 선언된 이후에도, 혹시 잘못된 동작이 없는지 확인하기 위해
        //    out과 state_out을 계속 관찰. 상태가 L_004 (player4 패배)여야 함.

        #50;
        // 6) out-of-turn 입력 테스트: 현재 이미 패배 상태이므로
        //    player3가 버튼을 누르면 out이 3이 되어야 함.
        player3    = 3'b010;     // 임의의 수
        player_clk = 6'b000100;  // player3 버튼 누름 (3번째 비트 = index 2)
        #10;
        player_clk = 6'b000000;

        #30;
        $finish;
    end

    // 모니터링
    initial begin
        $display("Time\treset_n\tplayer_clk\tp1 p2 p3 p4 p5 p6\t| state_out\tout");
        $monitor("%0dns\t  %b\t  %06b\t   %03b %03b %03b %03b %03b %03b\t |   %04b   \t%03b",
                 $time,
                 reset_n,
                 player_clk,
                 player1, player2, player3, player4, player5, player6,
                 state_out,
                 out);
    end

endmodule
