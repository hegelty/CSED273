`timescale 1ps / 1fs

module game(
    input [2:0] player1,
    input [2:0] player2,
    input [2:0] player3,
    input [2:0] player4,
    input [2:0] player5,
    input [2:0] player6,
    input [5:0] player_clk,
    input reset_n,
    output [2:0] out,
    output [3:0] state_out
);
    wire [3:0] state, state_;
    wire clk;
    wire [3:0] d;

    edge_trigger_D_FF ff3(reset_n, d[3], clk, state[3], state_[3]);
    edge_trigger_D_FF ff2(reset_n, d[2], clk, state[2], state_[2]);
    edge_trigger_D_FF ff1(reset_n, d[1], clk, state[1], state_[1]);
    edge_trigger_D_FF ff0(reset_n, d[0], clk, state[0], state_[0]);

    wire [3:0] player_1_next;
    mux8to1 mux_player_1_next_1(
        .in(8'b11101011),
        .select(player1),
        .out(player_1_next[0])
    );
    mux8to1 mux_player_1_next_2(
        .in(8'b00110100),
        .select(player1),
        .out(player_1_next[1])
    );
    mux8to1 mux_player_1_next_3(
        .in(8'b00000110),
        .select(player1),
        .out(player_1_next[2])
    );
    mux8to1 mux_player_1_next_4(
        .in(8'b11001001),
        .select(player1),
        .out(player_1_next[3])
    );

    assign d = player_1_next;
    assign clk = player_clk[0];
    assign out = player1;
    assign state_out = player_1_next;

    // // decode the current‐turn one‐hot signals
    // wire turn0 = ~state[2] & ~state[1] & ~state[0];
    // wire turn1 = ~state[2] & ~state[1] &  state[0];
    // wire turn2 = ~state[2] &  state[1] & ~state[0];
    // wire turn3 = ~state[2] &  state[1] &  state[0];
    // wire turn4 =  state[2] & ~state[1] & ~state[0];
    // wire turn5 =  state[2] & ~state[1] &  state[0];

    // // pass through only the correct player's clock
    // assign check_clk[0] = turn0 & player_clk[0];
    // assign check_clk[1] = turn1 & player_clk[1];
    // assign check_clk[2] = turn2 & player_clk[2];
    // assign check_clk[3] = turn3 & player_clk[3];
    // assign check_clk[4] = turn4 & player_clk[4];
    // assign check_clk[5] = turn5 & player_clk[5];

    // // detect any input from a non‐turn player
    // wire invalid_input = (player_clk[0] & ~turn0)
    //                    | (player_clk[1] & ~turn1)
    //                    | (player_clk[2] & ~turn2)
    //                    | (player_clk[3] & ~turn3)
    //                    | (player_clk[4] & ~turn4)
    //                    | (player_clk[5] & ~turn5);

    // // now out[0] can be driven high on invalid_input

    // assign out[0] = mux2to1;  // removed malformed assignment

endmodule
