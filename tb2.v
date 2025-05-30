`timescale 1ns/1ps
`define NUM_OF_PAT 3

module tb2;
  reg clk;
  reg rst_n;
  reg start;
  reg valid;
  reg [7:0] A;
  reg [7:0] B;
  reg [3:0] instruction;
  reg [7:0] count;
  wire [7:0] third_largest;
  wire finish;

  // Module instantiation
  top top(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .valid(valid),
        .data_A(A),
        .data_B(B),
        .instruction(instruction),
        .count(count),
        .third_largest(third_largest),
        .finish(finish)
      );

  // load patterns
  reg [7:0] patterns [0:`NUM_OF_PAT*30*2];
  reg [7:0] golden [0:`NUM_OF_PAT*30*2];
  reg [3:0] instruct [0:`NUM_OF_PAT*30];
  reg [7:0] count_reg [0:`NUM_OF_PAT];

  initial
  begin
    $readmemh("./data2/pattern", patterns);
    $readmemh("./data2/golden", golden);
    $readmemb("./data2/instruction", instruct);
    $readmemb("./data2/count", count_reg);
  end

  always #(`DELAY) clk = ~clk;

  integer cnt;
  integer pattern_idx;
  integer inst_idx;
  integer numTest;
  integer error;
  integer wait_finish = 0;
  integer last_round;
  initial
  begin
    error = 0;
    pattern_idx = 0;
    inst_idx = 0;
    clk = 0;
    rst_n = 1;
    start = 0;
    valid = 0;
    A = 8'dx;
    B = 8'dx;
    instruction = 8'dx;
    count = 8'dx;

    #(`DELAY*4);
    rst_n = 0;
    #(`DELAY*4);
    rst_n = 1;
    #(`DELAY*4);
    for(numTest = 0; numTest < `NUM_OF_PAT; numTest = numTest + 1)
    begin
      start = 1;
      count = count_reg[numTest];
      #(`DELAY*2);
      start = 0;
      count = 8'd0;
      for(cnt = 0; cnt < count_reg[numTest]; cnt = cnt + 1)
      begin
        A = patterns[pattern_idx*2];
        B = patterns[pattern_idx*2+1];
        instruction = instruct[inst_idx];
        inst_idx = inst_idx + 1;
        pattern_idx = pattern_idx + 1;
        valid = 1;
        #(`DELAY*2);
        if(numTest > 1)begin
          valid = 0;
          #(`DELAY*2);
          valid = 1;
        end
      end
      valid = 0;
      wait_finish = 1;
      wait (finish);
      wait_finish = 0;
      $display("Finish signal received. third_largest = %d.", third_largest);
      if(golden[numTest] !== third_largest)
      begin
        error = error + 1;
        $display("\n-------------------------------------------------------");
        $display("[ERROR]");
        $display("Round %d, your answer = %d, but the golden = %d.", numTest, third_largest, golden[numTest]);
        $display("-------------------------------------------------------\n");
      end
      #(`DELAY*7);
    end

    if(error == 0)
    begin
      $display("\n[success] You can submit to eeclass.\n");
    end
    else
    begin
      $display("\n[FAIL] There are %3d errors.\n", error);
    end
    $finish;
  end

  initial
  begin
    #(`DELAY*2*200);
    $finish;
  end

  always
  begin
    forever
      if(wait_finish == 1)begin
        last_round = numTest;
        #(`DELAY * 40);
        if(wait_finish == 1 && last_round == numTest)begin
          $display("\n[FAIL] waiting for finish flag timeout.\n");
          $finish;
        end
      end else begin
        #(`DELAY);
      end
  end

  always
  begin
    forever
      if(finish)begin
          #(`DELAY*0.2);
          if(clk == 0)begin
            $display("-------------------------------------------------------\n");
            $display("[ERROR]");
            $display("Round %d, finish flag does not rise at positive edge", numTest);
            $display("-------------------------------------------------------\n");
            error = error + 1;
          end
          #(`DELAY*2+1);
          if(finish == 1)begin
            $display("-------------------------------------------------------\n");
            $display("[ERROR]");
            $display("Round %d, finish flag rise more than one cycle", numTest);
            $display("-------------------------------------------------------\n");
            error = error + 1;
          end
      end else begin
        #(`DELAY * 0.1);
      end
  end

  initial
  begin
    //dump fsdb
    $dumpfile("tb2.vcd");
    $dumpvars;
  end

endmodule
