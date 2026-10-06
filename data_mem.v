module data_mem (
    input clk,
    input rst,
    input WE,
    input [7:0] A,
    input [31:0] WD,
    output reg [31:0] RD
);
    reg [31:0] memory [0:256];
    reg [8:0] i;

    always @(*) begin
        RD <= memory[A];
    end
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0;i<256;i=i+1) begin
                memory[i] <= 32'd0;
            end
        end
        else if (WE) begin
            memory[A] <= WD;
        end
    end
endmodule