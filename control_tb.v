`timescale 1ns/10ps

module control_tb;

    task assert_eq(input a, b);
        if(!(a===b)) begin
            $display("Assertion error: %h != %h", a, b);
            $stop;
        end
    endtask

    reg [31:0] instruction;
    wire branch_enable, mem_write_enable, reg_write_enable, mem_to_reg, ALU_imm, ill_instr;
    wire [3:0] ALU_op;

    `include "ALU_codes.h"

    control DUT (
        .instruction(instruction), 
        .branch_enable(branch_enable), 
        .mem_write_enable(mem_write_enable), 
        .reg_write_enable(reg_write_enable), 
        .mem_to_reg(mem_to_reg), 
        .ALU_op(ALU_op), 
        .ALU_imm(ALU_imm), 
        .ill_instr(ill_instr)
    );

    initial begin
        // -- Test Lui ---------------------------------------- TODO

        // -- Test Auipc -------------------------------------- TODO

        // -- Test Jal ---------------------------------------- TODO

        // -- Test Jalr --------------------------------------- TODO

        // -- Test Branch group ------------------------------- TODO
        // beq x0 x0 12
        instruction <= 'h00000663;
        #1;
        assert_eq(branch_enable, 1);
        assert_eq(ALU_op, ALU_SUB);
        #1;
        $display("Branch group test: OK");
        // -- Test Load group --------------------------------- TODO

        // -- Test Store group -------------------------------- TODO
        // lw x6 0(x9)
        instruction <= 'h0004A303;
        #1;

        // -- Test Arithmetic & logic immediate group --------- TODO

        // -- Test Arithmetic & logic R-type instructions------ TODO
        // add x5 x6 x7
        instruction <= 'h007302B3;
        #1;
        assert_eq(reg_write_enable, 1);
        assert_eq(ALU_imm, 0);
        assert_eq(ALU_op, ALU_ADD);
        #1;
        $display("Arithmetic & logic R-type instructions test: OK");

        // -- Stop testbench ----------------------------------
        $display("Testbench has finished: EVERYTHING OK");
        $stop;
    end

endmodule