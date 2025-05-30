`timescale 1ns/1ps

module ALU (
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] instruction,
    output reg [7:0] F
);

    always @(*) begin
        case (instruction)
            4'b0000: F = A + B;                                    
            4'b0001: F = A - B;                                    
            4'b0010: F = A >> B;                                   
            4'b0011: F = A << B;                                   
            4'b0100: F = (A >> B) | (A << (8 - B));               
            4'b0101: F = (A << B) | (A >> (8 - B));               
            4'b0110: F = A & B;                                    
            4'b0111: F = A | B;                                    
            4'b1000: F = ~A;                                       
            4'b1001: F = A ^ B;                                    
            default: F = 8'h00;                                    
        endcase
    end

endmodule
