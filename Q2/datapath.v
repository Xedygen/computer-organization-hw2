module datapath (
    input clk, reset,
    input [1:0] resultsrc,
    input pcsrc, alusrc,
    input regwrite,
    input [1:0] immsrc,
    input [2:0] alucontrol,
    output zero,
    output reg [31:0] pc,
    input [31:0] instr,
    output [31:0] aluout, writedata,
    input [31:0] readdata
);
    wire [31:0] pcnext, pcplus4, pctarget;
    wire [31:0] immext;
    wire [31:0] srca, srcb;
    wire [31:0] result;

    assign pcplus4 = pc + 4;
    assign pctarget = pc + immext;
    assign pcnext = pcsrc ? pctarget : pcplus4;

    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'b0;
        else pc <= pcnext;
    end

    regfile rf (
        .clk(clk),
        .we3(regwrite),
        .a1(instr[19:15]),
        .a2(instr[24:20]),
        .a3(instr[11:7]),
        .wd3(result),
        .rd1(srca),
        .rd2(writedata)
    );

    extend ext (
        .instr(instr[31:7]),
        .immsrc(immsrc),
        .immext(immext)
    );

    assign srcb = alusrc ? immext : writedata;

    alu alu_inst (
        .a(srca),
        .b(srcb),
        .alucontrol(alucontrol),
        .result(aluout),
        .zero(zero)
    );

    assign result = (resultsrc == 2'b00) ? aluout :
                    (resultsrc == 2'b01) ? readdata :
                    (resultsrc == 2'b10) ? pcplus4 : 32'bx;

endmodule
