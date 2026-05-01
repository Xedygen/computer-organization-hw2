`timescale 1ns/1ps

module tb_q2;
    reg clk;
    reg reset;
    wire [31:0] writedata, dataadr;
    wire memwrite;

    riscv_core dut (
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );

    initial begin
        $dumpfile("tb_q2.vcd");
        $dumpvars(0, tb_q2);
        reset <= 1;
        #22; reset <= 0;
        #200;
        
        $display("Checking Q2 Results (srai test):");
        if (dut.dmem_inst.RAM[100/4] === 32'hfffffffc) begin
            $display("  [PASS] srai (negative): dmem[100] = -4");
        end else begin
            $display("  [FAIL] srai (negative): dmem[100] = %h (expected fffffffc)", dut.dmem_inst.RAM[100/4]);
        end

        if (dut.dmem_inst.RAM[104/4] === 32'd4) begin
            $display("  [PASS] srai (positive): dmem[104] = 4");
        end else begin
            $display("  [FAIL] srai (positive): dmem[104] = %d (expected 4)", dut.dmem_inst.RAM[104/4]);
        end

        $finish;
    end

    always begin
        clk <= 1; #5; clk <= 0; #5;
    end

    always @(negedge clk) begin
        if (memwrite) begin
            $display("  [WRITE] cycle=%0t : MEM[0x%08h] <= 0x%08h", $time, dataadr, writedata);
        end
    end
endmodule
