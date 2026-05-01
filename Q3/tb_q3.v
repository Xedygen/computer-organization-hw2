`timescale 1ns/1ps

module tb_q3;
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
        $dumpfile("tb_q3.vcd");
        $dumpvars(0, tb_q3);
        reset <= 1;
        #22; reset <= 0;
        #200;
        
        $display("Checking Q3 Results (lh test):");
        if (dut.dmem_inst.RAM[104/4] === 32'hffffffff) begin
            $display("  [PASS] lh (negative): dmem[104] = -1");
        end else begin
            $display("  [FAIL] lh (negative): dmem[104] = %h (expected ffffffff)", dut.dmem_inst.RAM[104/4]);
        end

        if (dut.dmem_inst.RAM[112/4] === 32'h000000ff) begin
            $display("  [PASS] lh (positive): dmem[112] = 255");
        end else begin
            $display("  [FAIL] lh (positive): dmem[112] = %h (expected 000000ff)", dut.dmem_inst.RAM[112/4]);
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
