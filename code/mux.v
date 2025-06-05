`timescale 1ps / 1fs

module mux5to1(
    input [4:0] in,
    input [2:0] select,
    output out
);
    mux8to1 mux (
        .in({0, 0, 0, in[4:0]}),
        .select(select),
        .out(out)
    );
endmodule

module mux6to1(
    input [5:0] in,
    input [2:0] select,
    output out
);
    mux8to1 mux (
        .in({0, 0, in[5:0]}),
        .select(select),
        .out(out)
    );
endmodule

module mux2to1(
    input [1:0] in,
    input select,
    output out
);
    assign out = select & in[1] | ~select & in[0];
endmodule

module mux8to1(
    input [7:0] in,
    input [2:0] select,
    output out
);
    assign out =   select[2] &  select[1] &  select[0] & in[7]
                |  select[2] &  select[1] & ~select[0] & in[6]
                |  select[2] & ~select[1] &  select[0] & in[5]
                |  select[2] & ~select[1] & ~select[0] & in[4]
                | ~select[2] &  select[1] &  select[0] & in[3]
                | ~select[2] &  select[1] & ~select[0] & in[2]
                | ~select[2] & ~select[1] &  select[0] & in[1]
                | ~select[2] & ~select[1] & ~select[0] & in[0];
endmodule

module mux3x8to3(
    input [7:0] in_2,
    input [7:0] in_1,
    input [7:0] in_0,
    input [2:0] select,
    output [2:0] out
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