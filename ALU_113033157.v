// Add this debug version to check if files are being read correctly
`timescale 1ns/1ps
`define DELAY 10
`define NUM_OF_PAT 400

module tb;
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] instruction;
    wire [7:0] F;

    // Module instantiation
    ALU fu(
        .instruction(instruction), 
        .A(A),
        .B(B),
        .F(F)
    );

    // load patterns
    reg [7:0] patterns [0:`NUM_OF_PAT-1];
    reg [7:0] golden [0:(`NUM_OF_PAT/2)-1];
    reg [3:0] instruct [0:(`NUM_OF_PAT/2)-1];
    
    initial begin
        $readmemh("./data1/pattern", patterns);     
        $readmemh("./data1/golden", golden);       
        $readmemb("./data1/instruction", instruct);
        
        // Debug: Check if files were read correctly
        $display("Debug: First few patterns:");
        $display("patterns[0] = %h, patterns[1] = %h", patterns[0], patterns[1]);
        $display("instruct[0] = %b", instruct[0]);
        $display("golden[0] = %h", golden[0]);
    end
    
    initial begin
        A = 8'dx;
        B = 8'dx;
        instruction = 4'dx;
        
        // Debug: Check initial ALU output
        #1;
        $display("Debug: Initial ALU output F = %b", F);
    end

    integer i;
    initial begin
        for(i = 0; i < (`NUM_OF_PAT/2); i = i + 1) begin
            #(`DELAY);
            A = patterns[i<<1];
            B = patterns[(i<<1)+1];
            instruction = instruct[i];
            
            // Debug: Print first few assignments
            if(i < 3) begin
                $display("Debug: Time %0t, i=%0d, A=%h, B=%h, instruction=%b", 
                         $time, i, A, B, instruction);
                #1; // Small delay to let ALU respond
                $display("Debug: ALU output F = %b (%h)", F, F);
            end
        end
    end

    integer j, error;
    initial begin
        error = 0;
        #(`DELAY/2);
        for(j = 0; j < (`NUM_OF_PAT/2); j = j + 1) begin
            #(`DELAY);
            if(golden[j] !== F) begin
                error = error + 1;
                $display("\n-------------------------------------------------------");
                $display("[ERROR] Test %0d at time %0t", j, $time);
                $display("A = 8'b%b (8'h%h)", A, A);
                $display("B = 8'b%b (8'h%h)", B, B);
                $display("instruction = 4'b%b", instruct[j]);
                $display("Your answer = 8'b%b (8'h%h), but the golden = 8'b%b (8'h%h)", F, F, golden[j], golden[j]);
                $display("-------------------------------------------------------\n");
                
                // Stop after first few errors for debugging
                if(error >= 3) begin
                    $display("Stopping after 3 errors for debugging...");
                    $finish;
                end
            end
        end

        if(error == 0) begin
            $display("\n[success] You can start doing Problem 2.\n");
        end else begin
            $display("\n[FAIL] There are %3d errors.\n", error);
        end
        $finish;
    end
endmodule