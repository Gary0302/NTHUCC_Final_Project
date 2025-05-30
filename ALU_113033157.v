module ALU (
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] Instruction,
    output reg [7:0] F
);

    always @(*) begin
        case (Instruction)
            4'b0000: F = A + B;                                    // Unsigned Addition
            4'b0001: F = A - B;                                    // Unsigned Subtraction
            4'b0010: F = A >> B[2:0];                              // Logical Shift Right
            4'b0011: F = A << B[2:0];                              // Logical Shift Left
            4'b0100: F = (A >> B[2:0]) | (A << (8 - B[2:0]));     // Right Rotate
            4'b0101: F = (A << B[2:0]) | (A >> (8 - B[2:0]));     // Left Rotate
            4'b0110: F = A & B;                                    // AND
            4'b0111: F = A | B;                                    // OR
            4'b1000: F = ~A;                                       // NOT (B unused)
            4'b1001: F = A ^ B;                                    // XOR
            default: F = 8'b0;                                     // Default to 0 instead of x
        endcase
    end

endmodule