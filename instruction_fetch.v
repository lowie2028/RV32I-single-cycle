module instruction_fetch (branch_offset, branch_enable, instruction, clock, reset);
    parameter XLEN = 32;

    input branch_enable, clock, reset;
    input [XLEN-1:0] branch_offset;
    output [XLEN-1:0] instruction;

    wire [XLEN-1:0] pc_in;
    reg [XLEN-1:0] pc_out;

    // Progam counter register
    always @ (posedge clock)
        if (reset)
            pc_out <= 0;
        else
            pc_out <= pc_in;
    
    // Program counter control
    assign pc_in = (branch_enable) ? (pc_out + (branch_offset << 2)) : (pc_out + 4);

    // Fetch instruction from register
    instruction_memory #(.XLEN(XLEN)) im (pc_out, instruction);
endmodule
