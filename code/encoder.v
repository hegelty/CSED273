`timescale 1ns / 1ps

module encoder8to3(
    input [7:0] in,
    output [2:0] out
);
    assign out[2] = in[7] | in[6] | in[5] | in[4];
    assign out[1] = in[7] | in[6] | in[3] | in[2];
    assign out[0] = in[7] | in[5] | in[3] | in[1];
endmodule

// encoder that encodes the highest priority input
module priority_encoder8to3(
    input [7:0] in,
    output [2:0] out
);
    wire h7 = 1'b0;                            
    wire h6 = in[7];
    wire h5 = in[7] | in[6];
    wire h4 = in[7] | in[6] | in[5];
    wire h3 = in[7] | in[6] | in[5] | in[4];
    wire h2 = in[7] | in[6] | in[5] | in[4] | in[3];
    wire h1 = in[7] | in[6] | in[5] | in[4] | in[3] | in[2];
    wire h0 = in[7] | in[6] | in[5] | in[4] | in[3] | in[2] | in[1];

    // 우선순위 신호 y_i = in[i] & ~H_i
    wire y7 = in[7] & ~h7;  // = in[7]
    wire y6 = in[6] & ~h6;
    wire y5 = in[5] & ~h5;
    wire y4 = in[4] & ~h4;
    wire y3 = in[3] & ~h3;
    wire y2 = in[2] & ~h2;
    wire y1 = in[1] & ~h1;
    wire y0 = in[0] & ~h0;

    encoder8to3 encoder_inst (
        .in({y7, y6, y5, y4, y3, y2, y1, y0}),
        .out(out)
    );
endmodule