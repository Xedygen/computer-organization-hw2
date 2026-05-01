`timescale 1ns/1ps

// ============================================================================
// tb_q1.v  –  Full Testbench for RISC-V Single-Cycle Processor (Q1)
// Tests ALL 13 supported instructions:
//   R-type : add, sub, slt, or, and
//   I-type : addi, slti, ori, andi, lw
//   S-type : sw
//   B-type : beq
//   J-type : jal
//
// The test program is loaded from memfile.hex.
// After execution, the testbench reads back values stored in data memory
// by the program and compares them against expected results.
// ============================================================================

module tb_q1;

    // ------------------------------------------------------------------
    // Signals
    // ------------------------------------------------------------------
    reg         clk;
    reg         reset;
    wire [31:0] writedata, dataadr;
    wire        memwrite;

    // ------------------------------------------------------------------
    // DUT instantiation
    // ------------------------------------------------------------------
    riscv_core dut (
        .clk       (clk),
        .reset     (reset),
        .writedata (writedata),
        .dataadr   (dataadr),
        .memwrite  (memwrite)
    );

    // ------------------------------------------------------------------
    // Clock generation – 10 ns period (100 MHz)
    // ------------------------------------------------------------------
    always begin
        clk <= 1; #5;
        clk <= 0; #5;
    end

    // ------------------------------------------------------------------
    // Test counters
    // ------------------------------------------------------------------
    integer pass_count;
    integer fail_count;
    integer test_num;

    // ------------------------------------------------------------------
    // Task: check a data-memory word against an expected value
    // ------------------------------------------------------------------
    task check_dmem;
        input [31:0] addr;       // byte address
        input [31:0] expected;
        input [255:0] test_name; // label for display
        begin
            test_num = test_num + 1;
            if (dut.dmem_inst.RAM[addr[31:2]] === expected) begin
                $display("  [PASS] Test %0d : %-20s | dmem[%0d] = 0x%08h (expected 0x%08h)",
                         test_num, test_name, addr, expected, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Test %0d : %-20s | dmem[%0d] = 0x%08h (expected 0x%08h)",
                         test_num, test_name, addr,
                         dut.dmem_inst.RAM[addr[31:2]], expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ------------------------------------------------------------------
    // Monitor: trace every memory write as it happens
    // ------------------------------------------------------------------
    always @(negedge clk) begin
        if (memwrite)
            $display("  [WRITE] cycle=%0t : MEM[0x%08h] <= 0x%08h",
                     $time, dataadr, writedata);
    end

    // ------------------------------------------------------------------
    // Main stimulus
    // ------------------------------------------------------------------
    initial begin
        // VCD dump for GTKWave
        $dumpfile("tb_q1.vcd");
        $dumpvars(0, tb_q1);

        pass_count = 0;
        fail_count = 0;
        test_num   = 0;

        // ---- Apply reset ----
        reset <= 1;
        #22;
        reset <= 0;

        // ---- Let program execute ----
        // The memfile.hex program has ~30 instructions.
        // 30 instructions × 10 ns/cycle = 300 ns. Allow generous margin.
        #500;

        // ==============================================================
        // Verify results stored in data memory by the test program
        // ==============================================================
        $display("");
        $display("==========================================================");
        $display("  RISC-V Single-Cycle Processor – Testbench Results (Q1)");
        $display("==========================================================");
        $display("");

        // ---- addi  : x1 = 10                  → store x1 to dmem[100] ----
        check_dmem(100, 32'd10,   "addi            ");

        // ---- addi  : x2 = 15                  → store x2 to dmem[104] ----
        check_dmem(104, 32'd15,   "addi            ");

        // ---- add   : x3 = x1 + x2 = 25        → store x3 to dmem[108] ----
        check_dmem(108, 32'd25,   "add             ");

        // ---- sub   : x4 = x2 - x1 = 5         → store x4 to dmem[112] ----
        check_dmem(112, 32'd5,    "sub             ");

        // ---- and   : x5 = x1 & x2 = 10&15=10  → store x5 to dmem[116] ----
        check_dmem(116, 32'd10,   "and             ");

        // ---- or    : x6 = x1 | x2 = 10|15=15  → store x6 to dmem[120] ----
        check_dmem(120, 32'd15,   "or              ");

        // ---- slt   : x7 = (x1 < x2) = 1       → store x7 to dmem[124] ----
        check_dmem(124, 32'd1,    "slt             ");

        // ---- andi  : x8 = x1 & 0x7 = 10&7=2   → store x8 to dmem[128] ----
        check_dmem(128, 32'd2,    "andi            ");

        // ---- ori   : x9 = x1 | 0x5 = 10|5=15  → store x9 to dmem[132] ----
        check_dmem(132, 32'd15,   "ori             ");

        // ---- slti  : x10 = (x1 < 20) = 1      → store x10 to dmem[136] ----
        check_dmem(136, 32'd1,    "slti            ");

        // ---- sw/lw : store x3(25) to dmem[200], load back into x11
        //              → store x11 to dmem[140], expect 25 ----
        check_dmem(140, 32'd25,   "sw & lw         ");

        // ---- beq   : x12 = 99 if beq NOT taken (x1 != x2)
        //              beq skips over "addi x12,x0,99" → x12 should be 0
        //              then x12 = 42 after the branch target
        //              → store x12 to dmem[144], expect 42 ----
        check_dmem(144, 32'd42,   "beq (not taken) ");

        // ---- jal   : x14 = return address (PC+4 at jal site)
        //              at the jal target: x13 = 77
        //              → store x13 to dmem[148], expect 77 ----
        check_dmem(148, 32'd77,   "jal             ");

        // ==============================================================
        // Summary
        // ==============================================================
        $display("");
        $display("----------------------------------------------------------");
        $display("  Total: %0d tests | Passed: %0d | Failed: %0d",
                 pass_count + fail_count, pass_count, fail_count);
        $display("----------------------------------------------------------");

        if (fail_count == 0)
            $display("  >>> ALL TESTS PASSED – Simulation succeeded <<<");
        else
            $display("  >>> SOME TESTS FAILED – Simulation FAILED <<<");

        $display("==========================================================");
        $display("");

        $finish;
    end

endmodule
