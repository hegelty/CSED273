`timescale 1ns/1ps

module tb_mux4x8to4_c;

    // Inputs to the DUT
    reg  [3:0] in_7;
    reg  [3:0] in_6;
    reg  [3:0] in_5;
    reg  [3:0] in_4;
    reg  [3:0] in_3;
    reg  [3:0] in_2;
    reg  [3:0] in_1;
    reg  [3:0] in_0;
    reg  [2:0] select;

    // Output from the DUT
    wire [3:0] out;

    // Instantiate the device under test (DUT)
    mux4x8to4_c uut (
        .in_7    (in_7),
        .in_6    (in_6),
        .in_5    (in_5),
        .in_4    (in_4),
        .in_3    (in_3),
        .in_2    (in_2),
        .in_1    (in_1),
        .in_0    (in_0),
        .select  (select),
        .out     (out)
    );

    initial begin
        // Initialize all inputs
        in_0 = 4'b000;
        in_1 = 4'b001;
        in_2 = 4'b010;
        in_3 = 4'b011;
        in_4 = 4'b100;
        in_5 = 4'b101;
        in_6 = 4'b110;
        in_7 = 4'b111;

        select = 3'd0;
        #10;

        // Cycle through all select values 0..7
        repeat (8) begin
            $display("select = %0d > out = %b", select, out);
            #10 select = select + 1;
        end

        // End simulation
        #10 $finish;
    end

endmodule
