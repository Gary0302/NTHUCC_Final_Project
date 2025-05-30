module ALU (
    input  [7:0] A,
    input  [7:0] B,
    input  [3:0] instruction,
    output reg [7:0] F
);

    always @(*) begin
        case (instruction)
            4'b0000: F = A + B;                                    // 無符號加法
            4'b0001: F = A - B;                                    // 無符號減法
            4'b0010: F = A >> B;                                   // 邏輯右移
            4'b0011: F = A << B;                                   // 邏輯左移
            4'b0100: F = (A >> B) | (A << (8 - B));               // 右旋轉
            4'b0101: F = (A << B) | (A >> (8 - B));               // 左旋轉
            4'b0110: F = A & B;                                    // AND
            4'b0111: F = A | B;                                    // OR
            4'b1000: F = ~A;                                       // NOT (B未使用)
            4'b1001: F = A ^ B;                                    // XOR
            default: F = 8'h00;                                    // 預設值
        endcase
    end

endmodule