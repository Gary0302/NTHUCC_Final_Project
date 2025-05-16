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

    // FSM States
    parameter S_IDLE = 2'd0;
    parameter S_WAIT_DATA = 2'd1;
    parameter S_PROCESS_DATA = 2'd2;
    parameter S_OUTPUT_RESULT = 2'd3;

    reg [1:0] current_state, next_state; // 2-bit for 4 states

    // Registers
    reg [7:0] stored_count;
    reg [7:0] op_counter;
    reg [7:0] max1, max2, max3;
    reg [7:0] data_A_reg, data_B_reg;
    reg [3:0] instruction_reg;

    wire [7:0] alu_result_wire;

    // Instantiate ALU
    ALU u_alu (
        .A(data_A_reg),
        .B(data_B_reg),
        .Instruction(instruction_reg),
        .F(alu_result_wire)
    );

    // Sequential logic: FSM state transitions and register updates
    always @(posedge clk) begin
        if (!rst_n) begin // Synchronous reset
            current_state <= S_IDLE;
            stored_count <= 8'h0;
            op_counter <= 8'h0;
            max1 <= 8'h0; max2 <= 8'h0; max3 <= 8'h0;
            data_A_reg <= 8'h0; data_B_reg <= 8'h0; instruction_reg <= 4'h0;
            third_largest <= 8'h0;
            finish <= 1'b0;
        end else begin
            current_state <= next_state; // Update current state based on combinational logic

            // Default output values (asserted for one cycle in S_OUTPUT_RESULT)
            finish <= 1'b0;
            // third_largest retains value until updated in S_OUTPUT_RESULT

            case (current_state) // Actions to perform IN the current state, or upon EXITING it
                S_IDLE:
                    if (start) begin // On receiving start pulse
                        stored_count <= count;       // Latch total number of operations
                        op_counter <= 8'h0;        // Reset processed operations counter
                        max1 <= 8'h0;              // Reset max values
                        max2 <= 8'h0;
                        max3 <= 8'h0;
                    end
                S_WAIT_DATA:
                    // If transitioning to S_PROCESS_DATA (because valid input is available)
                    if (valid && (op_counter < stored_count)) begin
                        data_A_reg <= data_A;
                        data_B_reg <= data_B;
                        instruction_reg <= instruction;
                    end
                S_PROCESS_DATA:
                    // data_A_reg, data_B_reg, instruction_reg were latched in the previous cycle.
                    // alu_result_wire is now stable based on these latched inputs.
                    op_counter <= op_counter + 1; // Increment processed operations counter
                    // Update max1, max2, max3
                    if (alu_result_wire >= max1) begin
                        max3 <= max2; max2 <= max1; max1 <= alu_result_wire;
                    end else if (alu_result_wire >= max2) begin
                        max3 <= max2; max2 <= alu_result_wire;
                    end else if (alu_result_wire > max3) begin // '>' to handle distinctness for third if values are same as max3
                        max3 <= alu_result_wire;
                    end
                S_OUTPUT_RESULT:
                    third_largest <= max3; // Output the calculated third largest value
                    finish <= 1'b1;        // Signal that the result is ready
            endcase
        end
    end

    // Combinational logic: Next state determination
    always @(*) begin
        next_state = current_state; // Default: stay in current state
        case (current_state)
            S_IDLE:
                if (start) begin
                    next_state = S_WAIT_DATA;
                end
            S_WAIT_DATA:
                // Check if all operations are done (op_counter has reached stored_count)
                // Ensure stored_count is not initial zero, and op_counter has caught up.
                // Since count >= 3, stored_count will be >= 3 after a valid start.
                if (op_counter == stored_count && stored_count != 0) begin 
                    next_state = S_OUTPUT_RESULT;
                end else if (valid && (op_counter < stored_count)) begin 
                    // If data is valid and more operations are pending
                    next_state = S_PROCESS_DATA;
                end
                // Else, stay in S_WAIT_DATA (waiting for valid data or for op_counter to complete)
            S_PROCESS_DATA:
                // After processing one data item, go back to wait for the next or finish
                next_state = S_WAIT_DATA;
            S_OUTPUT_RESULT:
                // After outputting, return to idle state to await next start signal
                next_state = S_IDLE;
        endcase
    end

endmodule