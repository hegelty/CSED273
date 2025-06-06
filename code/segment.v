`timescale 1ns / 1ps

module display_segment(
    input  wire [2:0] val,
    output wire [6:0] seg,
    output wire [3:0] an
);

    wire eq1 = (~val[2] & ~val[1] &  val[0]); 
    wire eq2 = (~val[2] &  val[1] & ~val[0]); 
    wire eq3 = (~val[2] &  val[1] &  val[0]);
    wire eq4 = ( val[2] & ~val[1] & ~val[0]); 
    wire eq5 = ( val[2] & ~val[1] &  val[0]); 
    wire eq6 = ( val[2] &  val[1] & ~val[0]); 

    wire val_zero = (~val[2] & ~val[1] & ~val[0]);

    wire sa = ~( eq2 | eq3 | eq5 | eq6 );
    wire sb = ~( eq1 | eq2 | eq3 | eq4 );
    wire sc = ~( eq1 | eq3 | eq4 | eq5 | eq6 );
    wire sd = ~( eq2 | eq3 | eq5 | eq6 );
    wire se = ~( eq2 | eq6 );
    wire sf = ~( eq4 | eq5 | eq6 );
    wire sg = ~( eq2 | eq3 | eq4 | eq5 | eq6 );

    assign seg = { sa, sb, sc, sd, se, sf, sg };

    wire an0 =  val_zero;
    assign an   = {1'b1, 1'b1, 1'b1, an0};

endmodule