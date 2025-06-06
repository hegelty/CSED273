`timescale 1ns/1ps

module tb_game_player1_100;

    // Inputs
    reg  [2:0] player1;
    reg  [2:0] player2;
    reg  [2:0] player3;
    reg  [2:0] player4;
    reg  [2:0] player5;
    reg  [2:0] player6;
    reg  [5:0] player_clk;  // Active-High button signals
    reg        reset_n;

    // Outputs
    wire [2:0] out;         // 패배자 번호 (없으면 000)
    wire [3:0] state_out;   // {패배플래그, 번호} 또는 진행 중 플레이어 번호

    // DUT 인스턴스
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

    // 모니터링: state_out이나 out 변화 시점마다 출력
    always @(posedge player_clk[0] or posedge out) begin
        $display("[Time=%0t] state_out=%b, out=%b",
                 $time, state_out, out);
    end

    initial begin
        $dumpfile("tb_game_player1_100.vcd");
        $dumpvars(0, tb_game_player1_100);

        // 1) 초기화 및 리셋
        player1    = 3'b000;
        player2    = 3'b000;
        player3    = 3'b000;
        player4    = 3'b000;
        player5    = 3'b000;
        player6    = 3'b000;
        player_clk = 6'b000000;  // 모두 idle (버튼 풀기)
        reset_n    = 1'b0;
        #20;
        reset_n    = 1'b1;       // 리셋 해제 → state_out = 4'b0001 (플레이어1 차례)
        #10;

        // 2) 플레이어1이 매 차례마다 "100" 입력을 5번 반복
        $display("=== Scenario: Player1 inputs '100' five times ===");
        // '100'을 입력
        player1 = 3'b100;
        // 버튼 신호 활성화 (Active-High)
        #5; player_clk[0] = 1'b1;
        // 짧게 눌린 상태 유지
        #5; player_clk[0] = 1'b0;
        // 입력이 처리되어 다음 상태로 넘어갈 때까지 대기
        #10;
                // '100'을 입력
        player1 = 3'b100;
        // 버튼 신호 활성화 (Active-High)
        #5; player_clk[0] = 1'b1;
        // 짧게 눌린 상태 유지
        #5; player_clk[0] = 1'b0;
        // 입력이 처리되어 다음 상태로 넘어갈 때까지 대기
        #10;
                // '100'을 입력
        player1 = 3'b100;
        // 버튼 신호 활성화 (Active-High)
        #5; player_clk[0] = 1'b1;
        // 짧게 눌린 상태 유지
        #5; player_clk[0] = 1'b0;
        // 입력이 처리되어 다음 상태로 넘어갈 때까지 대기
        #10;

        // 3) 시뮬레이션 종료
        #20;
        $finish;
    end

endmodule
