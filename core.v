module core (
    clock,
    reset,
    io_input_bus,
    io_output_bus
);
parameter XLEN = 32;
parameter IO_INPUT_BUS_LEN = 14;
parameter IO_OUTPUT_BUS_LEN = 52;
parameter IO_BASE_ADDR = 100;

input clock, reset;
input [IO_INPUT_BUS_LEN-1:0] io_input_bus;
output [IO_OUTPUT_BUS_LEN-1:0] io_output_bus;

// Control outputs
wire branch_enable, mem_write_enable, reg_write_enable, mem_to_reg, alu_imm, ill_instr;
wire [3:0] alu_op;
// Instruction fetch output
wire [31:0] instruction;
// Register file outputs
wire [XLEN-1:0] reg_data_0, reg_data_1;
// Immediate generator output
wire [XLEN-1:0] immediate_out;
// ALU outputs
wire [XLEN-1:0] alu_out;
wire zero;
// Data memory output
wire [XLEN-1:0] mem_data;


control CONTROL (
    .instruction(instruction), 
    .branch_enable(branch_enable), 
    .mem_write_enable(mem_write_enable), 
    .reg_write_enable(reg_write_enable), 
    .mem_to_reg(mem_to_reg), 
    .ALU_op(alu_op),
    .ALU_imm(alu_imm), 
    .ill_instr(ill_instr)
);

instruction_fetch IF (
    .branch_offset(immediate_out),
    .branch_enable(branch_enable && zero),
    .instruction(instruction),
    .clock(clock), 
    .reset(reset)
);

register_file RF (
    .read_reg_0(instruction[19:15]), 
    .read_reg_1(instruction[24:20]), 
    .write_reg(instruction[11:7]), 
    .write_data((mem_to_reg) ? mem_data : alu_out),
    .write_enable(reg_write_enable), 
    .read_data_0(reg_data_0), 
    .read_data_1(reg_data_1), 
    .clock(clock), 
    .reset(reset)
);

immediate_generator IG (
    .instruction(instruction),
    .immediate_out(immediate_out)
);

ALU ALU (
    .in_0(reg_data_0),
    .in_1((alu_imm) ? immediate_out : reg_data_1),
    .operation(alu_op),
    .out(alu_out),
    .zero(zero)
);

parameter DATA_DEPTH = 128;
data_memory #(
    .XLEN(XLEN), 
    .DEPTH(DATA_DEPTH), 
    .IO_OUTPUT_BUS_LEN(IO_OUTPUT_BUS_LEN), 
    .IO_INPUT_BUS_LEN(IO_INPUT_BUS_LEN), 
    .IO_BASE_ADDR(IO_BASE_ADDR)
    ) DM (
    .address(alu_out), 
    .write_data(reg_data_1), 
    .write_enable(mem_write_enable), 
    .read_data(mem_data), 
    .clock(clock), 
    .reset(reset),
    .io_input_bus(io_input_bus),
    .io_output_bus(io_output_bus)
);
    
endmodule