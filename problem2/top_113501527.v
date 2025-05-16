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
    output [7:0] third_largest,
    output finish
);
   
    wire [7:0] ALU_result;

    ALU u_ALU (
        .A(data_A),
        .B(data_B),
        .instruction(instruction),
        .F(ALU_result)
    );

   //TODO: write your design below

endmodule