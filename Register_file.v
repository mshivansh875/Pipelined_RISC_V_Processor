module Register_file (
    input clk,
    input rst,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,
    output reg [31:0] RD1,
    output reg [31:0] RD2
);
    reg [31:0] reg_file [0:31];
    reg [5:0] i;
    always @(*) begin
        RD1 = reg_file[A1];
        RD2 = reg_file[A2];
    end
    initial begin
        reg_file[17] <= 8;
    end
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            for (i=0;i<32 && i != 17;i=i+1) begin
                reg_file[i] <= 32'd0;
            end
        end
        else if(WE3) begin
            reg_file[A3] <= WD3;
        end
    end
endmodule