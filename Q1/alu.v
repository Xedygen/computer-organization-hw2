module alu (
    input [31:0] a, b,
    input [2:0] alucontrol,
    output reg [31:0] result,
    output zero
);
    always @(*) begin
        case (alucontrol)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b101: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // slt
            default: result = 32'bx;
        endcase
    end
    assign zero = (result == 32'b0);
endmodule
