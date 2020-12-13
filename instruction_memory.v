module instruction_memory (read_address, instruction);
    parameter XLEN = 32;
    parameter DEPTH = 265;
    
    input [XLEN-1:0] read_address;
    output reg [XLEN-1:0] instruction;

    reg [XLEN-1:0] mem [DEPTH-1:0];
    initial begin
        $readmemh ("../Source/instruction_memory.mem", mem); // Is this synthesizable ?
    end

    always @ (*) begin
        if (read_address >= 0 && read_address[31:2] < DEPTH)
            instruction <= mem [read_address[31:2]];
        else
            instruction <= {XLEN-1{1'b0}};
    end
endmodule
