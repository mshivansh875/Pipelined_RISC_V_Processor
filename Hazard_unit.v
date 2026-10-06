module Hazard_unit (
    input [4:0] A1_if,
    input [4:0] A2_if,
    input [4:0] A3_id,
    input [4:0] A1_ex,
    input [4:0] A2_ex,
    input [4:0] A3_m,
    input [4:0] A3_wb,
    input reg_write_m,
    input reg_write_wb,
    input PC_src_if,
    input [6:0] opcode_id,
    output reg [1:0] sel_A_ex,
    output reg [1:0] sel_B_ex,
    output reg en,
    output reg clr
);
    always @(*) begin
        if (A1_ex == A3_m && reg_write_m) sel_A_ex <= 2'd1;
        else if (A1_ex == A3_wb && reg_write_wb) sel_A_ex <= 2'd2;
        else sel_A_ex <= 2'd0;
        
        if (A2_ex == A3_m && reg_write_m) sel_B_ex <= 2'd1;
        else if (A2_ex == A3_wb && reg_write_wb) sel_B_ex <= 2'd2;
        else sel_B_ex <= 2'd0;
    end
    always @(*) begin
        if (opcode_id == 7'h03 && (A1_if == A3_id || A2_if == A3_id)) en <= 1'b0;
        else en <= 1'b1;
    end
    always @(*) begin
        if(PC_src_if) begin
            clr <= 1'b1;
            // en <= 1'b0;
        end
        else begin
            clr <= 1'b0;
            // en <= 1'b1;
        end
    end

endmodule