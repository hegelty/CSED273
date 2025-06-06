`timescale 1ns / 1ps

module top (
    // 16개 LED(led[0] ~ led[15]) 출력
    output [15:0] led,

    // 7-세그먼트(seg[0] ~ seg[6]) 및 소수점(dp) 출력
    output [6:0]  seg,
    output        dp,
    inout  [7:0]  JA,

    input btnC
);

    assign led[0] = JA[0];
    assign led[1] = JA[1];
    assign led[2] = JA[2];
    assign led[3] = JA[3];

    wire [3:0] state;
    wire [2:0] out;
    assign led[15:12] = state;
    assign led[10:8] = out;
    
    wire [5:0] player_clk;
    assign player_clk = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, JA[3]};
    wire [2:0] player1;
    assign player1 = {JA[2], JA[1], JA[0]};

    always begin
        #100000
        $display("Player 1: %b", player1);
        $display("Player Clock: %b", player_clk);
        $display("Button C: %b", btnC);
    end
    game game_inst (
        .player1(player1),
        .player2(1'b0),
        .player3(1'b0),
        .player4(1'b0),
        .player5(1'b0),
        .player6(1'b0),
        .player_clk(player_clk),
        .reset_n(btnC),
        .out(out),
        .state_out(state)
    );

endmodule
