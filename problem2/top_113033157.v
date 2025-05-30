module top (
    input clk,
    input rst,
    input [7:0] A,
    input [7:0] B,
    input [3:0] instruction,
    input data_valid,
    input last_data,
    output reg [7:0] third_largest,
    output reg result_valid
);

    // ALU 實例化
    wire [7:0] alu_result;
    ALU alu_inst (
        .A(A),
        .B(B),
        .instruction(instruction),
        .F(alu_result)
    );

    // FSM 狀態定義
    localparam IDLE = 2'b00;
    localparam COLLECT = 2'b01;
    localparam PROCESS = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] state, next_state;
    
    // 儲存前三大數值的暫存器
    reg [7:0] largest, second_largest, third_largest_reg;
    reg [7:0] current_result;
    
    // 計數器
    reg [7:0] data_count;
    reg processing_done;

    // FSM 狀態轉換
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM 下一狀態邏輯
    always @(*) begin
        case (state)
            IDLE: begin
                if (data_valid)
                    next_state = COLLECT;
                else
                    next_state = IDLE;
            end
            COLLECT: begin
                if (last_data && data_valid)
                    next_state = PROCESS;
                else
                    next_state = COLLECT;
            end
            PROCESS: begin
                next_state = DONE;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // 數據處理邏輯
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            largest <= 0;
            second_largest <= 0;
            third_largest_reg <= 0;
            data_count <= 0;
            result_valid <= 0;
            third_largest <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    result_valid <= 0;
                    if (data_valid) begin
                        largest <= 0;
                        second_largest <= 0;
                        third_largest_reg <= 0;
                        data_count <= 0;
                    end
                end
                
                COLLECT: begin
                    if (data_valid) begin
                        current_result <= alu_result;
                        data_count <= data_count + 1;
                        
                        // 即時更新前三大數值
                        if (alu_result > largest) begin
                            third_largest_reg <= second_largest;
                            second_largest <= largest;
                            largest <= alu_result;
                        end
                        else if (alu_result > second_largest && alu_result != largest) begin
                            third_largest_reg <= second_largest;
                            second_largest <= alu_result;
                        end
                        else if (alu_result > third_largest_reg && 
                                alu_result != largest && 
                                alu_result != second_largest) begin
                            third_largest_reg <= alu_result;
                        end
                    end
                end
                
                PROCESS: begin
                    // 處理完成，準備輸出
                    third_largest <= third_largest_reg;
                end
                
                DONE: begin
                    result_valid <= 1;
                end
            endcase
        end
    end

endmodule