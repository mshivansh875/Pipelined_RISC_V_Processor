module Control_unit (
    input clk,
    input rst,
    input [31:0] instruction,
    input comparator_result,
    input [6:0] opcode_ex,
    output reg reg_write,
    output reg mem_write,
    output reg PC_src_if,
    output reg sel_srcA_id,
    output reg sel_srcB_id,
    output reg [1:0] wb_sel,
    output reg [3:0] ALUControl, 
    output reg [2:0] imm_sel
);

    localparam  R = 7'H33,
                I = 7'H13,
                L = 7'H03,
                S = 7'H23,
                B = 7'H63,
                J = 7'H6F,
                U = 7'H37;

    reg [1:0] ALUop;

    wire [6:0] instr;
    assign instr = instruction[6:0];
    always @(*) begin
        case (instr)
            R: begin
                reg_write <= 1'b1;
                mem_write <= 1'b0;
                imm_sel <= 2'd0;
                wb_sel <= 2'd1;
                ALUop <= 2'd2;
                sel_srcA_id <= 1'b1;
                sel_srcB_id <= 1'b1;
            end
            I: begin
                reg_write <= 1'b1;
                mem_write <= 1'b0;
                imm_sel <= 3'd1;
                wb_sel <= 2'd1;
                ALUop <= 2'd2;
                sel_srcA_id <= 1'b1;
                sel_srcB_id <= 1'b0;
            end
            L: begin
                reg_write <= 1'b1;
                mem_write <= 1'b0;
                imm_sel <= 3'd1;
                wb_sel <= 2'd0;
                ALUop <= 2'd0;
                sel_srcA_id <= 1'b1;
                sel_srcB_id <= 1'b0;
            end
            S: begin
                reg_write <= 1'b0;
                mem_write <= 1'b1;
                imm_sel <= 3'd2;
                ALUop <= 2'd0;
                sel_srcA_id <= 1'b1;
                sel_srcB_id <= 1'b0;

            end
            B: begin
                reg_write <= 1'b0;
                mem_write <= 1'b0;
                imm_sel <= 3'd3;
                ALUop <= 2'd0;
                sel_srcA_id <= 1'b0;
                sel_srcB_id <= 1'b0;
            end
            U: begin
                imm_sel <= 3'd4;
            end
            J: begin
                reg_write <= 1'b1;
                mem_write <= 1'b0;
                imm_sel <= 3'd5;
                wb_sel <= 2'd2;
                ALUop <= 2'd0;
                sel_srcA_id <= 1'b0;
                sel_srcB_id <= 1'b0;
            end
            default: begin
                
            end
        endcase
    end

    always @(*) begin
        case (ALUop)
            2'd0: ALUControl <= 4'd2;
            2'd1: ALUControl <= 4'd6;
            2'd2: begin
                case (instruction[14:12])
                    3'd0: begin
                        if(instruction[31:25] == 7'd0) ALUControl <= 4'd2;
                        else if (instruction[31:25] == 7'd32) ALUControl <= 4'd6;
                        else ALUControl <= 4'd2;
                    end
                    3'd6: ALUControl <= 4'd1;
                    3'd7: ALUControl <= 4'd0;
                endcase
            end
            default: ALUControl <= 4'd15;
        endcase
    end

    always @(*) begin
        case (opcode_ex)
            B: begin
                if (comparator_result) PC_src_if <= 1'b1;
                else PC_src_if <= 1'b0;
            end
            J: begin
                PC_src_if <= 1'b1;
            end
            default: PC_src_if <= 1'b0;
        endcase
    end

endmodule