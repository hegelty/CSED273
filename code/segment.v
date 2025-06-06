`timescale 1ns / 1ps

module display_segment(
    input  [2:0] val,
    output [6:0] seg,
    output [3:0] an
);
  // 8-bit look-up with a 8-to-1 mux, then drop the DP bit
  wire [7:0] seg8;
  mux8x8to8_c mux_seg (
    .in_0(8'b11000000),
    .in_1(8'b11111001),
    .in_2(8'b10100100),
    .in_3(8'b10110000),
    .in_4(8'b10011001),
    .in_5(8'b10010010),
    .in_6(8'b10000010),
    .in_7(0),  // blank for 7
    .select(val),
    .out(seg8)
  );
  assign seg = seg8[6:0];
  // use only the first 4 bits
  // do not display when the value is 0
  assign an   = {1'b1, 1'b1, 1'b1, ~val[2] & ~val[1] & ~val[0]};

endmodule