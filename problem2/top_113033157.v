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

    
    wire rst = ~rst_n;  
    
    
    wire [7:0] alu_result;
    ALU alu_inst (
        .A(data_A),
        .B(data_B),
        .instruction(instruction),
        .F(alu_result)
    );

    
    localparam IDLE = 2'b00;
    localparam COLLECT = 2'b01;
    localparam PROCESS = 2'b10;
    localparam DONE = 2'b11;

    reg [1:0] state, next_state;
    
    
    reg [7:0] largest, second_largest, third_largest_reg;
    
    
    reg [7:0] data_counter;
    reg [7:0] total_count;

    
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    
    always @(*) begin
        case (state)
            IDLE: begin
                if (start)
                    next_state = COLLECT;
                else
                    next_state = IDLE;
            end
            COLLECT: begin
                if (data_counter >= total_count)
                    next_state = PROCESS;
                else
                    next_state = COLLECT;
            end
            PROCESS: begin
                next_state = DONE;
            end
            DONE: begin
                if (!start)
                    next_state = IDLE;
                else
                    next_state = DONE;
            end
            default: next_state = IDLE;
        endcase
    end

    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            largest <= 0;
            second_largest <= 0;
            third_largest_reg <= 0;
            data_counter <= 0;
            total_count <= 0;
            finish <= 0;
            third_largest <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    finish <= 0;
                    if (start) begin
                        largest <= 0;
                        second_largest <= 0;
                        third_largest_reg <= 0;
                        data_counter <= 0;
                        total_count <= count;
                    end
                end
                
                COLLECT: begin
                    if (valid && data_counter < total_count) begin
                        data_counter <= data_counter + 1;
                        
                        
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
                    
                    third_largest <= third_largest_reg;
                end
                
                DONE: begin
                    finish <= 1;
                end
            endcase
        end
    end

endmodule
