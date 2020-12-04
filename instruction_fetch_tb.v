`timescale 1ns/10ps

module instruction_fetch_tb;

    task assert_eq(input a, b);
        if(!(a===b)) begin
            $display("Assertion error: %h != %h", a, b);
            $stop;
        end
    endtask

    parameter XLEN = 32;

    reg branch_enable, reset, clock;
    reg [XLEN-1:0] branch_offset;
    wire [XLEN-1:0] instruction;

    instruction_fetch #(XLEN) DUT (.branch_offset(branch_offset), .branch_enable(branch_enable), .instruction(instruction), .clock(clock), .reset(reset));

    integer instr_addr;
    reg [XLEN-1:0] test_instr_mem [31:0];

    // Process for generating clock
    always #5 clock <= ~clock;

    // Instruction memory is initialized with instruction_memory.mem
    initial begin
        // Initialize clock
        clock <= 0;

        // Load test memory
        $readmemh ("../Source/instruction_memory.mem", test_instr_mem);

        //------------------------------------------------------------------------

        // Test normal increment mode
        branch_enable <=0;
        reset <= 1;
        #10;
        reset <= 0;

        for (instr_addr=0; instr_addr < 32; instr_addr=instr_addr+1) begin
            assert_eq(instruction, test_instr_mem[instr_addr]);
            #10;
        end
        $display("Normal increment mode: OK");

        //------------------------------------------------------------------------

        // Test branch mode
        instr_addr <= 0;
        branch_enable <= 1;
        reset <= 1;
        #10;
        reset <= 0;

        assert_eq(instruction, test_instr_mem[instr_addr]);
        branch_offset <= 3;
        instr_addr <= instr_addr + 3;
        #10
        assert_eq(instruction, test_instr_mem[instr_addr]);
        branch_offset <= -2;
        instr_addr <= instr_addr + -2;
        #10
        assert_eq(instruction, test_instr_mem[instr_addr]);
        $display("Branch mode: OK");  

        //------------------------------------------------------------------------

        // Stop testbench
        $display("Testbench has finished: EVERYTHING OK");
        $stop;
    end

endmodule
