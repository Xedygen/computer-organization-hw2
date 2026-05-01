module riscv_core (
    input clk, reset,
    output [31:0] writedata, dataadr,
    output memwrite
);
    wire [31:0] pc, instr, readdata;
    wire [1:0] resultsrc;
    wire pcsrc, alusrc, regwrite, jump, zero;
    wire [1:0] immsrc;
    wire [2:0] alucontrol;

    controller c (
        .op(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7_5(instr[30]),
        .zero(zero),
        .resultsrc_0(resultsrc[0]),
        .resultsrc_1(resultsrc[1]),
        .memwrite(memwrite),
        .pcsrc(pcsrc),
        .alusrc(alusrc),
        .regwrite(regwrite),
        .jump(jump),
        .immsrc(immsrc),
        .alucontrol(alucontrol)
    );

    datapath dp (
        .clk(clk),
        .reset(reset),
        .resultsrc(resultsrc),
        .pcsrc(pcsrc),
        .alusrc(alusrc),
        .regwrite(regwrite),
        .immsrc(immsrc),
        .alucontrol(alucontrol),
        .zero(zero),
        .pc(pc),
        .instr(instr),
        .aluout(dataadr),
        .writedata(writedata),
        .readdata(readdata)
    );

    imem imem_inst (
        .a(pc),
        .rd(instr)
    );

    dmem dmem_inst (
        .clk(clk),
        .we(memwrite),
        .a(dataadr),
        .wd(writedata),
        .rd(readdata)
    );
endmodule
