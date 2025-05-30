module ALU (
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] instruction,
    output reg [7:0] F
);

    always @(A or B or instruction) begin
        case (instruction)
            4'b0000: F = A + B;                                              // Unsigned Addition
            4'b0001: F = A - B;                                              // Unsigned Subtraction  
            4'b0010: F = A >> B;                                             // Logical Shift Right
            4'b0011: F = A << B;                                             // Logical Shift Left
            4'b0100: begin                                                   // Right Rotate
                if (B < 8)
                    F = (A >> B) | (A << (8 - B));
                else
                    F = A; // No rotation if B >= 8
            end
            4'b0101: begin                                                   // Left Rotate
                if (B < 8)
                    F = (A << B) | (A >> (8 - B));
                else
                    F = A; // No rotation if B >= 8
            end
            4'b0110: F = A & B;                                              // AND
            4'b0111: F = A | B;                                              // OR
            4'b1000: F = ~A;                                                 // NOT (B unused)
            4'b1001: F = A ^ B;                                              // XOR
            default: F = 8'h00;                                              // Default case
        endcase
    end

endmodule