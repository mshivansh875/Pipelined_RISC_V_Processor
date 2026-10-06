`include "Control_unit.v"
`include "Datapath.v"
`timescale 1ps/1ps
module Processor (
    // input clk,
    // input rst
);

    wire reg_write, mem_write, PC_src_if, sel_srcA_id, sel_srcB_id, comparator_result;
    wire [1:0] wb_sel;
    wire [2:0] imm_sel;
    reg clk, rst;
    wire [3:0] ALUControl;
    wire [31:0] instruction;
    wire [6:0] opcode_ex;

    Control_unit cu1 (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .wb_sel(wb_sel),
        .imm_sel(imm_sel),
        .comparator_result(comparator_result),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .ALUControl(ALUControl),
        .opcode_ex(opcode_ex),
        .PC_src_if(PC_src_if),
        .sel_srcA_id(sel_srcA_id),
        .sel_srcB_id(sel_srcB_id)
    );
    Datapath dp1(
        .clk(clk),
        .rst(rst),
        .instruction_id(instruction),
        .wb_sel_id(wb_sel),
        .imm_sel_id(imm_sel),
        .comparator_result(comparator_result),
        .reg_write_id(reg_write),
        .mem_write_id(mem_write),
        .ALUControl_id(ALUControl),
        .opcode_ex(opcode_ex),
        .PC_src_if(PC_src_if),
        .sel_srcA_id(sel_srcA_id),
        .sel_srcB_id(sel_srcB_id)
    );
    initial begin
        $dumpfile("Processor.vcd");
        $dumpvars(0,Processor);
        #200 $finish;
    end
    initial begin
        rst = 0;
        #10 rst = 1'b1;
    end
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~ clk;
        end
    end



endmodule