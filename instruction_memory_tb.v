`timescale 1ns/10ps

module instruction_memory_tb;

    task assert_eq(input a, b);
        if(!(a===b)) begin
            $display("Assertion error: %h != %h", a, b);
            $finish(2);
        end
    endtask

    parameter XLEN = 32;
    parameter DEPTH = 32;

    reg [XLEN-1:0] read_address;
    wire [XLEN-1:0] instruction;
    reg [XLEN-1:0] test_mem [DEPTH-1:0];

    instruction_memory #(.XLEN(XLEN), .DEPTH(DEPTH)) DUT (.read_address(read_address), .instruction(instruction));

    integer i;
    initial begin
        $readmemh ("../Source/instruction_memory.mem", test_mem);
        for (i=0; i<DEPTH; i=i+1) begin
            read_address <= i<<2;
            #1 
            //$display ("%h:   %h", read_address, instruction);
            assert_eq(instruction, test_mem [i]);
        end
        $display("Testbench has finished: EVERYTHING OK");
    end
    
endmodule
