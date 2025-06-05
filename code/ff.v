`timescale 1ps / 1fs

/* Negative edge triggered JK flip-flop */
module edge_trigger_JKFF(input reset_n, input j, input k, input clk, output reg q, output reg q_);  
    initial begin
      q = 0;
      q_ = ~q;
    end
    
    always @(negedge clk) begin
        q = reset_n & (j&~q | ~k&q);
        q_ = ~reset_n | ~q;
    end

endmodule

module edge_trigger_D_FF(input reset_n, input d, input clk, output q, output q_);   

    ////////////////////////
    /* Add your code here */
    wire j, k;
    assign j = d;
    assign k = ~d;
    edge_trigger_JKFF jk_ff(reset_n, j, k, clk, q, q_);
    ////////////////////////
 
endmodule