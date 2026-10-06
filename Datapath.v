`include "Register_file.v"
`include "sign_extend.v"
`include "data_mem.v"
`include "ALU.v"
`include "Hazard_unit.v"

module Datapath (
    input clk,
    input rst,
    input reg_write_id,
    input mem_write_id,
    input PC_src_if,
    input sel_srcA_id,
    input sel_srcB_id,
    input [1:0] wb_sel_id,
    input [2:0] imm_sel_id,
    output reg comparator_result,
    output reg [31:0] ALUResult_ex,
    output reg [31:0] instruction_id,
    output reg [6:0] opcode_ex,
    input [3:0] ALUControl_id
);

wire clr;

wire [4:0] A1_if, A2_if;
reg [31:0] PC_if;
reg [31:0] instr_mem [0:7];
reg [31:0] PC_mux_0_if, PC_mux_1_if, ALUResult_if, instruction_if;


wire [4:0] A1_id, A2_id, A3_id;
wire [31:0] read_data1_id, read_data2_id, SignImm_id;
reg [4:0] rd_id;
reg [31:0] PC_id, PC_mux_0_id;
reg reg_write_ex, mem_write_ex, sel_srcA_ex, sel_srcB_ex;
reg [1:0] wb_sel_ex;
reg [2:0] imm_sel_ex;
reg [3:0] ALUControl_ex;
reg [4:0] A1_ex, A2_ex, rd_ex;
reg [31:0] new_rd1_data_ex, new_rd2_data_ex, read_data1_ex, read_data2_ex, SignImm_ex;
reg [31:0] PC_ex, PC_mux_0_ex, SrcB_ex, SrcA_ex;


wire [31:0] RD_m;
reg reg_write_m, mem_write_m;
reg [1:0] wb_sel_m;
reg [4:0] rd_m;
reg [31:0] ALUResult_m, PC_mux_0_m, new_rd2_data_m;

reg reg_write_wb;
reg [1:0] wb_sel_wb;
reg [4:0] rd_wb;
reg [31:0] ALUResult_wb, PC_mux_0_wb, RD_wb, write_back_wb;


    initial begin
        instr_mem[0]  <= 32'h00100093; // addi x1,  x0, 1
instr_mem[1]  <= 32'h00100113; // addi x2,  x0, 1

instr_mem[2]  <= 32'h00208263; // beq  x1, x2, +4
instr_mem[3]  <= 32'h06F00513; // addi x10, x0, 111   // MUST be flushed
instr_mem[4]  <= 32'h0DE00513; // addi x10, x0, 222   // MUST be flushed
instr_mem[5]  <= 32'h14D00513; // addi x10, x0, 333   // MUST be flushed

instr_mem[6]  <= 32'h00A00513; // addi x10, x0, 10

        // instr_mem[0] <= 32'h02A00293;
        // instr_mem[1] <= 32'h00552023;
        // instr_mem[2] <= 32'h00052283;
        // instr_mem[3] <= 32'h00A28313;

        // instr_mem[0] <= 32'h00500513;
        // instr_mem[1] <= 32'h00700593;
        // instr_mem[2] <= 32'h00000013;
        // instr_mem[3] <= 32'h00000013;
        // instr_mem[4] <= 32'h00000013;
        // instr_mem[2] <= 32'h00B50633;
        // instr_mem[2] <= 32'h00B50163;
        // instr_mem[3] <= 32'h00A50163;
        // instr_mem[5] <= 32'h06300613;
        // instr_mem[7] <= 32'hFFFFF0EF;
    end

    wire en;

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            PC_if <= 32'd0;
        end
        else if (!en) PC_if <= PC_if;
        else begin
            if (PC_src_if) PC_if <= PC_mux_1_if;
            else PC_if <= PC_mux_0_if;
            
        end
    end


    always @(*) begin
        PC_mux_0_if <= PC_if + 1;
        PC_mux_1_if <= ALUResult_ex;
        instruction_if <= instr_mem[PC_if];
    end


    assign A1_if = instruction_if[19:15];
    assign A2_if = instruction_if[24:20];

    assign A1_id = instruction_id[19:15];
    assign A2_id = instruction_id[24:20];
    assign A3_id = instruction_id[11:7];

    wire [1:0] sel_A_ex, sel_B_ex;

    always @(*) begin
        // comparator_result <= (new_rd1_data_ex == new_rd2_data_ex);
        if (new_rd1_data_ex == new_rd2_data_ex) comparator_result <= 1'b1;
        else comparator_result <= 1'b0;
    end

    always @(*) begin
        if (sel_A_ex == 2'd1) new_rd1_data_ex <= ALUResult_m;
        else if(sel_A_ex == 2'd2) new_rd1_data_ex <= write_back_wb;
        else new_rd1_data_ex <= read_data1_ex;
    end

    always @(*) begin
        if (sel_B_ex == 2'd1) new_rd2_data_ex <= ALUResult_m;
        else if(sel_B_ex == 2'd2) new_rd2_data_ex <= write_back_wb;
        else new_rd2_data_ex <= read_data2_ex;
    end

    always @(*) begin
        if (sel_srcA_ex) SrcA_ex = new_rd1_data_ex;
        else SrcA_ex = PC_ex;
    end

    always @(*) begin
        if (sel_srcB_ex) SrcB_ex = new_rd2_data_ex;
        else SrcB_ex = SignImm_ex;
    end

    always @(*) begin
        if (wb_sel_wb == 2'd0) write_back_wb = RD_wb;
        else if (wb_sel_wb == 2'd1) write_back_wb = ALUResult_wb;
        else write_back_wb = PC_mux_0_wb;
    end


// IF -> ID

    always @(posedge clk or negedge rst) begin
        if(!rst || clr) begin
            instruction_id <= 32'd0;
            PC_id <= 32'd0;
            PC_mux_0_id <= 32'd0;
        end
        else if (!en) begin
            instruction_id <= 32'h00000013;
        end
        else begin
            instruction_id <= instruction_if;
            PC_mux_0_id <= PC_mux_0_if;
            PC_id <= PC_if;
        end
    end

// ID -> Ex

    always @(posedge clk or negedge rst) begin
        if(!rst || clr) begin
            read_data1_ex <= 32'd0;
            read_data2_ex <= 32'd0;
            rd_ex <= 5'd0;
            SignImm_ex <= 32'd0;
            PC_ex <= 32'd0;
            sel_srcA_ex <= 1'b0;
            sel_srcB_ex <= 1'b0;
            PC_mux_0_ex <= 32'd0;
            reg_write_ex <= 1'b0;
            mem_write_ex <= 1'b0;
            wb_sel_ex <= 2'd0;
            imm_sel_ex <= 3'd0;
            ALUControl_ex <= 4'd0;
            A1_ex <= 5'd0;
            A2_ex <= 5'd0;
            opcode_ex <= 7'd0;
        end
        else begin
            read_data1_ex <= read_data1_id;
            read_data2_ex <= read_data2_id;
            rd_ex <= A3_id;
            SignImm_ex <= SignImm_id;
            PC_ex <= PC_id;
            sel_srcA_ex <= sel_srcA_id;
            sel_srcB_ex <= sel_srcB_id;
            PC_mux_0_ex <= PC_mux_0_id;
            reg_write_ex <= reg_write_id;
            mem_write_ex <= mem_write_id;
            wb_sel_ex <= wb_sel_id;
            imm_sel_ex <= imm_sel_id;
            ALUControl_ex <= ALUControl_id;
            A1_ex <= A1_id;
            A2_ex <= A2_id;
            opcode_ex <= opcode_id;
        end
    end

// Ex t0 M

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ALUResult_m <= 32'd0;
            new_rd2_data_m <= 32'd0;
            rd_m <= 5'd0;
            reg_write_m <= 1'b0;
            PC_mux_0_m <= 32'd0;
            mem_write_m <= 1'b0;
            wb_sel_m <= 2'd0;
        end
        else begin
            ALUResult_m <= ALUResult_ex;
            new_rd2_data_m <= new_rd2_data_ex;
            rd_m <= rd_ex;
            PC_mux_0_m <= PC_mux_0_ex;
            reg_write_m <= reg_write_ex;
            mem_write_m <= mem_write_ex;
            wb_sel_m <= wb_sel_ex;
        end
    end

// M to Wb

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ALUResult_wb <= 32'd0;
            RD_wb <= 32'd0;
            rd_wb <= 5'd0;
            PC_mux_0_wb <= 32'd0;
            reg_write_wb <= 1'b0;
            wb_sel_wb <= 2'd0;
        end
        else begin
            ALUResult_wb <= ALUResult_m;
            RD_wb <= RD_m;
            rd_wb <= rd_m;
            PC_mux_0_wb <= PC_mux_0_m;
            reg_write_wb <= reg_write_m;
            wb_sel_wb <= wb_sel_m;
        end
    end


    Register_file r1 (
        .clk(clk),
        .rst(rst),
        .A1(A1_id),
        .A2(A2_id),
        .A3(rd_wb),
        .WE3(reg_write_wb),
        .WD3(write_back_wb),
        .RD1(read_data1_id),
        .RD2(read_data2_id)
    );
    wire [31:0] instruction_id_1;
    assign instruction_id_1 = instruction_id;

    sign_extend s1 (
        .instruction(instruction_id_1),
        .imm_sel(imm_sel_id),
        .SignImm(SignImm_id)
    );
    wire [31:0] ALUResult_ex_1;
    assign ALUResult_ex_1 = ALUResult_ex;
    ALU a1 (
        .ALUControl(ALUControl_ex),
        .SrcA(SrcA_ex),
        .SrcB(SrcB_ex),
        .ALUResult(ALUResult_ex_1)
    );

    data_mem dm1 (
        .clk(clk),
        .rst(rst),
        .WE(mem_write_m),
        .A(ALUResult_m[7:0]),
        .RD(RD_m),
        .WD(new_rd2_data_m)
    );
    
    wire [6:0] opcode_id;
    assign opcode_id = instruction_id[6:0];

    Hazard_unit h1 (
        .A1_if(A1_if),
        .A2_if(A2_if),
        .A3_id(A3_id),
        .A1_ex(A1_ex),
        .A2_ex(A2_ex),
        .A3_m(rd_m),
        .A3_wb(rd_wb),
        .PC_src_if(PC_src_if),
        .clr(clr),
        .reg_write_m(reg_write_m),
        .reg_write_wb(reg_write_wb),
        .sel_A_ex(sel_A_ex),
        .sel_B_ex(sel_B_ex),
        .en(en),
        .opcode_id(opcode_id)
    );
    
endmodule