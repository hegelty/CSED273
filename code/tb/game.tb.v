`timescale 1ns/1ps

module tb_game_comprehensive;

    // Inputs
    reg  [2:0] player1;
    reg  [2:0] player2;
    reg  [2:0] player3;
    reg  [2:0] player4;
    reg  [2:0] player5;
    reg  [2:0] player6;
    reg  [5:0] player_clk;  // Active-High buttons
    reg        reset_n;

    // Outputs
    wire [2:0] out;         // 패배자 번호 (없으면 000)
    wire [3:0] state_out;   // {패배플래그, 번호} 혹은 진행 중 플레이어 번호

    // 내부 변수
    integer i;
    reg [2:0] choices [0:3];

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

    // 모니터링: 매 상태 변화 시점마다 출력
    always @(state_out or out) begin
        $display("[Time=%0t] state_out=%b, out=%b", $time, state_out, out);
    end

    // choices 초기화
    initial begin
        choices[0] = 3'b001;
        choices[1] = 3'b010;
        choices[2] = 3'b100;
        choices[3] = 3'b101;
    end

    initial begin
        $dumpfile("tb_game_comprehensive.vcd");
        $dumpvars(0, tb_game_comprehensive);

        //===============================================================
        // 1) Reset 및 초기화
        //===============================================================
        player1    = 3'b000;
        player2    = 3'b000;
        player3    = 3'b000;
        player4    = 3'b000;
        player5    = 3'b000;
        player6    = 3'b000;
        player_clk = 6'b000000;  // 모두 idle (active-high이므로 0)
        reset_n    = 1'b0;       // Active-Low reset
        #20;
        reset_n = 1'b1;          // 리셋 해제 → state_out = 4'b0001 (플레이어1 차례)
        #10;

        //===============================================================
        // 1. 패배 없이 10턴 이상 이어지는 게임
        //    - 플레이어별로 각 턴에 choices 중 하나를 순환하여 입력
        //===============================================================
        $display("=== Scenario 1: 10턴 동안 무패 진행 (다양한 입력) ===");
        for (i = 0; i < 10; i = i + 1) begin
            case (state_out[2:0])
                3'b001: player1 = choices[i % 4];
                3'b010: player2 = choices[i % 4];
                3'b011: player3 = choices[i % 4];
                3'b100: player4 = choices[i % 4];
                3'b101: player5 = choices[i % 4];
                3'b110: player6 = choices[i % 4];
                default: ;
            endcase
            // 버튼 눌림 (Active-High)
            #5;
            player_clk[state_out[2:0] - 1] = 1'b1;
            #5;
            player_clk = 6'b000000;
            #5;
        end
        // 10턴 이후 state_out 확인
        $display("After 10 varied-turns → state_out = %b, out = %b", state_out, out);
        #20;

        //===============================================================
        // 2. 자신의 차례가 아닌 사람이 CLK를 입력하는 경우
        //===============================================================
        $display("=== Scenario 2: 비턴 플레이어가 버튼 입력 → 즉시 패배 ===");
        // state_out이 플레이어5 차례라 가정
        #5;
        player3 = 3'b010;  
        #2;
        player_clk[2] = 1'b1;  
        #3;
        player_clk = 6'b000000; 
        #10;
        $display("Scenario2 result → state_out = %b, out = %b", state_out, out);
        #20;

        // 리셋하여 다음 시나리오 준비
        reset_n = 1'b0;
        #10;
        reset_n = 1'b1;
        player_clk = 6'b000000;
        #10;

        //===============================================================
        // 3. 자신의 차례인 사람과 자신의 차례가 아닌 사람이 동시에 CLK 입력
        //===============================================================
        $display("=== Scenario 3: Turn 플레이어 & 비턴 플레이어 동시 입력 ===");
        player1 = 3'b000;
        player2 = 3'b000;
        #5;
        player_clk[0] = 1'b1; // player1
        player_clk[1] = 1'b1; // player2
        #5;
        player_clk = 6'b000000;
        #10;
        $display("Scenario3 result → state_out = %b, out = %b", state_out, out);
        #20;

        // 리셋
        reset_n = 1'b0;
        #10;
        reset_n = 1'b1;
        player_clk = 6'b000000;
        #10;

        //===============================================================
        // 4a. 복합 시나리오: Turn 먼저 누르고 → Other 지연 입력
        //===============================================================
        $display("=== Scenario 4a: Turn 먼저 → Other 지연 입력 ===");
        player1 = 3'b000;
        player2 = 3'b000;
        #5;
        player_clk[0] = 1'b1; // player1 pressed
        #2;
        player_clk[1] = 1'b1; // player2 pressed (딜레이)
        #3;
        player_clk = 6'b000000;
        #10;
        $display("Scenario4a result → state_out = %b, out = %b", state_out, out);
        #20;

        // 리셋 후 준비
        reset_n = 1'b0;
        #10;
        reset_n = 1'b1;
        player_clk = 6'b000000;
        #10;

        $display("=== Scenario 4b: Other 먼저 → Turn 늦게 입력 ===");
        player1 = 3'b000;
        player2 = 3'b000;
        #5;
        player_clk[1] = 1'b1; // player2 pressed first
        #5;
        player_clk[0] = 1'b1; // player1 pressed later
        #3;
        player_clk = 6'b000000;
        #10;
        $display("Scenario4b result → state_out = %b, out = %b", state_out, out);
        #20;

        $finish;
    end

endmodule
