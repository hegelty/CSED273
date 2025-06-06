`timescale 1ns / 1ps

module top (
    output [15:0] led,

    output [6:0]  seg,
    output [3:0]  an,

    inout  [7:0]  JA,
    inout  [7:0]  JB,
    inout  [7:0]  JC,

    input btnC
);

    wire [3:0] state;
    wire [2:0] out;
    assign led[15:12] = state;

    assign led[7:0] = JA;
    
    wire [5:0] player_clk;
    assign player_clk = {JC[7], JC[3], JB[7], JB[3], JA[7], JA[3]};
    wire [2:0] player1;
    assign player1 = JA[2:0];
    wire [2:0] player2;
    assign player2 = JA[6:4];
    wire [2:0] player3;
    assign player3 = JB[2:0];
    wire [2:0] player4;
    assign player4 = JB[6:4];
    wire [2:0] player5;
    assign player5 = JC[2:0];
    wire [2:0] player6;
    assign player6 = JC[6:4];

    game game_inst (
        .player1(player1),
        .player2(player2),
        .player3(player3),
        .player4(player4),
        .player5(player5),
        .player6(player6),
        .player_clk(player_clk),
        .reset_n(~btnC),
        .out(out),
        .state_out(state)
    );

    display_segment display_inst (
        .val(out),
        .seg(seg),
        .an(an)
    );

endmodule
