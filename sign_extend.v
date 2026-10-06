module sign_extend (
    input [31:0] instruction,
    input [2:0] imm_sel,
    output reg [31:0] SignImm
);

    localparam  I = 3'd1,
                S = 3'd2,
                B = 3'd3,
                U = 3'd4,
                J = 3'd5;

    always @(*) begin
        case (imm_sel)
            I: SignImm <= {{20{instruction[31]}}, instruction[30:20]};
            S: SignImm <= {{20{instruction[31]}}, instruction[30:25]};
            B: SignImm <= {{19{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            U: SignImm <= {instruction[31:12], 12'd0};
            J: SignImm <= {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default: SignImm <= 31'd0;
        endcase
    end
endmodule