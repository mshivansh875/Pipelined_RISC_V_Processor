module ALU (
    input [3:0] ALUControl,
    input [31:0] SrcA,
    input [31:0] SrcB,
    output reg zero,
    output reg [31:0] ALUResult
);
    always @(*) begin
        case (ALUControl)
            4'd0: ALUResult <= SrcA & SrcB;
            4'd1: ALUResult <= SrcA | SrcB;
            3'd2: ALUResult <= SrcA + SrcB;
            4'd6: ALUResult <= SrcA - SrcB;
            4'd7: begin
                if (SrcA < SrcB) begin
                    ALUResult <= 32'd1;
                end
                else begin
                    ALUResult <= 32'd0;
                end
            end
            default: ALUResult <= 32'd0;
        endcase
    end
    always @(*) begin
        zero <= (ALUResult == 32'd0);
    end
endmodule