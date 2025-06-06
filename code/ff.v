`timescale 1ns / 1ps

/* Negative edge triggered JK flip-flop */
module edge_trigger_JK_FF(input reset_n, input j, input k, input clk, output reg q, output reg q_);  
    initial begin
      q = 0;
      q_ = ~q;
    end
    
    always @(negedge clk or negedge reset_n) begin
        if (!reset_n) begin
            q  <= 0;
            q_ <= 1;
        end else begin
            q  <= (j & ~q) | (~k & q);
            q_ <= ~q;
        end
    end

endmodule

module edge_trigger_D_FF(input reset_n, input d, input clk, output q, output q_);   

    wire j, k;
    assign j = d;
    assign k = ~d;
    edge_trigger_JK_FF jk_ff(reset_n, j, k, clk, q, q_);
 
endmodule

module edge_trigger_JK_FF_reset_as_1(input reset_n, input j, input k, input clk, output reg q, output reg q_);  
    initial begin
      q = 1;
      q_ = ~q;
    end

    always @(negedge clk or negedge reset_n) begin
        if (!reset_n) begin
            q  <= 1;
            q_ <= 0;
        end else begin
            q  <= (j & ~q) | (~k & q);
            q_ <= ~q;
        end
    end
endmodule

module edge_trigger_D_FF_reset_as_1(input reset_n, input d, input clk, output q, output q_);   

    wire j, k;
    assign j = d;
    assign k = ~d;
    edge_trigger_JK_FF_reset_as_1 jk_ff(reset_n, j, k, clk, q, q_);
endmodule