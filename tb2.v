`timescale 1ns/1ps

module top (
    input clk,
    input rst_n,
    input start,
    input valid,
    input [7:0] data_A,
    input [7:0] data_B,
    input [3:0] instruction,
    input [7:0] count,
    output reg [7:0] third_largest,
    output reg finish
);

    // 內部信號
    wire rst = ~rst_n;
    
    // ALU 實例化
    wire [7:0] alu_result;
    ALU alu_inst (
        .A(data_A),
        .B(data_B),
        .instruction(instruction),
        .F(alu_result)
    );

    // FSM 狀態編碼
    localparam [1:0] IDLE = 2'b00,
                     WAIT_DATA = 2'b01,
                     COLLECT = 2'b10,
                     DONE = 2'b11;

    // 狀態暫存器
    reg [1:0] current_state, next_state;
    
    // 數據儲存暫存器
    reg [7:0] largest, second_largest, third_largest_temp;
    reg [7:0] data_counter;
    reg [7:0] total_data_count;
    reg start_detected;

    // FSM 狀態轉換 (時序邏輯)
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // FSM 下一狀態邏輯 (組合邏輯)
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (start)
                    next_state = WAIT_DATA;
                else
                    next_state = IDLE;
            end
            WAIT_DATA: begin
                if (!start && valid)
                    next_state = COLLECT;
                else
                    next_state = WAIT_DATA;
            end
            COLLECT: begin
                if (data_counter >= total_data_count)
                    next_state = DONE;
                else
                    next_state = COLLECT;
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // 數據路徑邏輯 (時序邏輯)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            largest <= 8'h00;
            second_largest <= 8'h00;
            third_largest_temp <= 8'h00;
            data_counter <= 8'h00;
            total_data_count <= 8'h00;
            third_largest <= 8'h00;
            finish <= 1'b0;
            start_detected <= 1'b0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    finish <= 1'b0;
                    if (start) begin
                        largest <= 8'h00;
                        second_largest <= 8'h00;
                        third_largest_temp <= 8'h00;
                        data_counter <= 8'h00;
                        total_data_count <= count;
                        start_detected <= 1'b1;
                    end
                    else begin
                        start_detected <= 1'b0;
                    end
                end
                
                WAIT_DATA: begin
                    finish <= 1'b0;
                    // 等待start變低且valid變高
                end
                
                COLLECT: begin
                    finish <= 1'b0;
                    if (valid) begin
                        data_counter <= data_counter + 8'h01;
                        
                        // 更新前三大數值
                        if (alu_result > largest) begin
                            third_largest_temp <= second_largest;
                            second_largest <= largest;
                            largest <= alu_result;
                        end
                        else if ((alu_result > second_largest) && (alu_result != largest)) begin
                            third_largest_temp <= second_largest;
                            second_largest <= alu_result;
                        end
                        else if ((alu_result > third_largest_temp) && 
                                (alu_result != largest) && 
                                (alu_result != second_largest)) begin
                            third_largest_temp <= alu_result;
                        end
                    end
                end
                
                DONE: begin
                    third_largest <= third_largest_temp;
                    finish <= 1'b1;  // 只在這個週期拉高
                end
                
                default: begin
                    finish <= 1'b0;
                end
            endcase
        end
    end

endmodule