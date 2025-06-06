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

    assign clk = player_clk[0] | player_clk[1] | player_clk[2] | player_clk[3] | player_clk[4] | player_clk[5];

    edge_trigger_D_FF ff3(reset_n, d[3], clk, state[3], state_[3]);
    edge_trigger_D_FF ff2(reset_n, d[2], clk, state[2], state_[2]);
    edge_trigger_D_FF ff1(reset_n, d[1], clk, state[1], state_[1]);
    edge_trigger_D_FF_reset_as_1 ff0(reset_n, d[0], clk, state[0], state_[0]);

    // state that will be used to determine when the current player's turn
    wire [3:0] player_1_next, player_2_next, player_3_next, player_4_next, player_5_next, player_6_next;
    mux4x8to4_c mux_player_1_next(
        .in_7(4'b1001),
        .in_6(4'b1001),
        .in_5(4'b0011),
        .in_4(4'b0010),
        .in_3(4'b1001),
        .in_2(4'b0110),
        .in_1(4'b0101),
        .in_0(4'b1001),
        .select(player1),
        .out(player_1_next)
    );

    mux4x8to4_c mux_player_2_next(
        .in_7(4'b1010),
        .in_6(4'b1010),
        .in_5(4'b0100),
        .in_4(4'b0011),
        .in_3(4'b1010),
        .in_2(4'b0001),
        .in_1(4'b0110),
        .in_0(4'b1010),
        .select(player2),
        .out(player_2_next)
    );

    mux4x8to4_c mux_player_3_next(
        .in_7(4'b1011),
        .in_6(4'b1011),
        .in_5(4'b0101),
        .in_4(4'b0100),
        .in_3(4'b1011),
        .in_2(4'b0010),
        .in_1(4'b0001),
        .in_0(4'b1011),
        .select(player3),
        .out(player_3_next)
    );

    mux4x8to4_c mux_player_4_next(
        .in_7(4'b1100),
        .in_6(4'b1100),
        .in_5(4'b0110),
        .in_4(4'b0101),
        .in_3(4'b1100),
        .in_2(4'b0011),
        .in_1(4'b0010),
        .in_0(4'b1100),
        .select(player4),
        .out(player_4_next)
    );

    mux4x8to4_c mux_player_5_next(
        .in_7(4'b1101),
        .in_6(4'b1101),
        .in_5(4'b0001),
        .in_4(4'b0110),
        .in_3(4'b1101),
        .in_2(4'b0100),
        .in_1(4'b0011),
        .in_0(4'b1101),
        .select(player5),
        .out(player_5_next)
    );

    mux4x8to4_c mux_player_6_next(
        .in_7(4'b1110),
        .in_6(4'b1110),
        .in_5(4'b0010),
        .in_4(4'b0001),
        .in_3(4'b1110),
        .in_2(4'b0101),
        .in_1(4'b0100),
        .in_0(4'b1110),
        .select(player6),
        .out(player_6_next)
    );

    // state that the current player's turn
    wire [3:0] s_d;
    mux4x8to4_c mux_write_turn_out(
        .in_7(4'b0000),
        .in_6(player_6_next),
        .in_5(player_5_next),
        .in_4(player_4_next),
        .in_3(player_3_next),
        .in_2(player_2_next),
        .in_1(player_1_next),
        .in_0(0),
        .select(state),
        .out(s_d)
    );

    wire [3:0] right_d;
    // L -> S_001, else s_d
    mux4x2to4_c mux_right_d(
        .in_1(4'b0001),
        .in_0(s_d),
        .select(state[3]),
        .out(right_d)
    );

    // wrong turn
    // clk=1 2개 이상 -> 다른 와이어 하나 1로 만들기 ->조건문 앞에서부터 -> d를 적용
    wire [5:0] turn;
    assign turn[0] = ~state[3] & ~state[2] & ~state[1] &  state[0]; // S_001
    assign turn[1] = ~state[3] & ~state[2] &  state[1] & ~state[0]; // S_010
    assign turn[2] = ~state[3] & ~state[2] &  state[1] &  state[0]; // S_011
    assign turn[3] = ~state[3] &  state[2] & ~state[1] & ~state[0]; // S_100
    assign turn[4] = ~state[3] &  state[2] & ~state[1] &  state[0]; // S_101
    assign turn[5] = ~state[3] &  state[2] &  state[1] & ~state[0]; // S_110

    wire [5:0] wrong_turn;
    assign wrong_turn[0] = player_clk[0] & ~turn[0];
    assign wrong_turn[1] = player_clk[1] & ~turn[1];
    assign wrong_turn[2] = player_clk[2] & ~turn[2];
    assign wrong_turn[3] = player_clk[3] & ~turn[3];
    assign wrong_turn[4] = player_clk[4] & ~turn[4];
    assign wrong_turn[5] = player_clk[5] & ~turn[5];

    wire wrong;
    wire [3:0] wrong_d;
    assign wrong = wrong_turn[0] | wrong_turn[1] | wrong_turn[2] | wrong_turn[3] | wrong_turn[4] | wrong_turn[5];
    priority_encoder8to3 encode_wrong_player(
        .in({1'b0, wrong_turn[5], wrong_turn[4], wrong_turn[3], wrong_turn[2], wrong_turn[1], wrong_turn[0] , 1'b0}),
        .out(wrong_d[2:0])
    );
    assign wrong_d[3] = 1'b1;

    mux4x2to4_c mux_d(
        .in_1(wrong_d),
        .in_0(right_d),
        .select(wrong),
        .out(d)
    );

    // output
    assign state_out[0] = state[0];
    assign state_out[1] = state[1];
    assign state_out[2] = state[2];
    assign state_out[3] = state[3];

    mux3x2to3_c mux_out(
        .in_1(state[2:0]),
        .in_0(3'b000),
        .select(state[3]),
        .out(out)
    );

    // TODO: 자기차례 아닐때 입력 구현


endmodule
