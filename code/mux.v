`timescale 1ps / 1fs

module mux2to1(
    input [1:0] in,
    input select,
    output out
);
    assign out = select & in[1] | ~select & in[0];
endmodule

module mux4to1(
    input [3:0] in,
    input [1:0] select,
    output out
);
    wire [1:0] in_muxed;
    mux2to1 mux1 (
        .in({in[3], in[2]}),
        .select(select[0]),
        .out(in_muxed[1])
    );
    mux2to1 mux0 (
        .in({in[1], in[0]}),
        .select(select[0]),
        .out(in_muxed[0])
    );
    mux2to1 mux_out (
        .in(in_muxed),
        .select(select[1]),
        .out(out)
    );
endmodule

module mux8to1(
    input [7:0] in,
    input [2:0] select,
    output out
);
    wire [1:0] in_muxed;
    mux4to1 mux1 (
        .in(in[7:4]),
        .select(select[1:0]),
        .out(in_muxed[1])
    );
    mux4to1 mux0 (
        .in(in[3:0]),
        .select(select[1:0]),
        .out(in_muxed[0])
    );
    mux2to1 mux_out (
        .in(in_muxed),
        .select(select[2]),
        .out(out)
    );
endmodule

module mux4x8to4(
    input [7:0] in_3,
    input [7:0] in_2,
    input [7:0] in_1,
    input [7:0] in_0,
    input [2:0] select,
    output [3:0] out
);
    mux8to1 mux3 (
        .in(in_3),
        .select(select),
        .out(out[3])
    );
    mux8to1 mux2 (
        .in(in_2),
        .select(select),
        .out(out[2])
    );
    mux8to1 mux1 (
        .in(in_1),
        .select(select),
        .out(out[1])
    );
    mux8to1 mux0 (
        .in(in_0),
        .select(select),
        .out(out[0])
    );
endmodule

module mux4x8to4_c(
    input [3:0] in_7,
    input [3:0] in_6,
    input [3:0] in_5,
    input [3:0] in_4,
    input [3:0] in_3,
    input [3:0] in_2,
    input [3:0] in_1,
    input [3:0] in_0,
    input [2:0] select,
    output [3:0] out
);
    wire [7:0] in_3_o, in_2_o, in_1_o, in_0_o;
    assign in_3_o[7] = in_7[3];
    assign in_3_o[6] = in_6[3];
    assign in_3_o[5] = in_5[3];
    assign in_3_o[4] = in_4[3];
    assign in_3_o[3] = in_3[3];
    assign in_3_o[2] = in_2[3];
    assign in_3_o[1] = in_1[3];
    assign in_3_o[0] = in_0[3];

    assign in_2_o[7] = in_7[2];
    assign in_2_o[6] = in_6[2];
    assign in_2_o[5] = in_5[2];
    assign in_2_o[4] = in_4[2];
    assign in_2_o[3] = in_3[2];
    assign in_2_o[2] = in_2[2];
    assign in_2_o[1] = in_1[2];
    assign in_2_o[0] = in_0[2];

    assign in_1_o[7] = in_7[1];
    assign in_1_o[6] = in_6[1];
    assign in_1_o[5] = in_5[1];
    assign in_1_o[4] = in_4[1];
    assign in_1_o[3] = in_3[1];
    assign in_1_o[2] = in_2[1];
    assign in_1_o[1] = in_1[1];
    assign in_1_o[0] = in_0[1];

    assign in_0_o[7] = in_7[0];
    assign in_0_o[6] = in_6[0];
    assign in_0_o[5] = in_5[0];
    assign in_0_o[4] = in_4[0];
    assign in_0_o[3] = in_3[0];
    assign in_0_o[2] = in_2[0];
    assign in_0_o[1] = in_1[0];
    assign in_0_o[0] = in_0[0];

    mux4x8to4 mux (
        .in_3(in_3_o),
        .in_2(in_2_o),
        .in_1(in_1_o),
        .in_0(in_0_o),
        .select(select),
        .out(out)
    );
endmodule

module mux4x2to4_c(
    input [3:0] in_1,
    input [3:0] in_0,
    input select,
    output [3:0] out
)
;
    wire [3:0] in_muxed;
    mux2to1 mux1 (
        .in({in_1[3], in_0[3]}),
        .select(select),
        .out(in_muxed[3])
    );
    mux2to1 mux2 (
        .in({in_1[2], in_0[2]}),
        .select(select),
        .out(in_muxed[2])
    );
    mux2to1 mux3 (
        .in({in_1[1], in_0[1]}),
        .select(select),
        .out(in_muxed[1])
    );
    mux2to1 mux4 (
        .in({in_1[0], in_0[0]}),
        .select(select),
        .out(in_muxed[0])
    );
    assign out = in_muxed;
endmodule

module mux3x2to3_c(
    input [2:0] in_1,
    input [2:0] in_0,
    input select,
    output [2:0] out
);
    wire [2:0] in_muxed;
    mux2to1 mux1 (
        .in({in_1[2], in_0[2]}),
        .select(select),
        .out(in_muxed[2])
    );
    mux2to1 mux2 (
        .in({in_1[1], in_0[1]}),
        .select(select),
        .out(in_muxed[1])
    );
    mux2to1 mux3 (
        .in({in_1[0], in_0[0]}),
        .select(select),
        .out(in_muxed[0])
    );
    assign out = in_muxed;
endmodule