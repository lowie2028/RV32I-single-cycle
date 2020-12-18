# Homework 5: single cycle RV32I

**With a limited instruction set** 

*Lowie Deferme*

## Core modules

### Schematic

![Schematic of the core](./resources/core.png)

As seen in the schematic above, the core consists of 6 modules:

* instruction_fetch: fetches the correct instruction each a rising edge on the clock is detected
* control: sets control signals based on the instruction.
* register_file: contains 32 registers of 32-bit long words.
* immediate_generator: generates a number based on the instruction.
* ALU: this is the Arithmetic Logic Unit.
* data_memory: stores 32-bit words, some addresses are mapped to IO's.

All modules that contain some sort of memory also have a clock and a reset signal input. This is not drawn on the schematic.

### Verilog code

```verilog
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
```

## Testing the design

In the design phase, testing was done by simulating with Modelsim. Afterwards, the design was synthesized with Quartus. In order to be able to test the core an assembly program was written. It tests all the desired instructions.

### Assembly program

```assembly
.text
    # Set registers
    addi t0, zero, 0x00000003
    addi t1, zero, 0x00000005
    addi t5, zero, 0x00000060 # use as io base address
    addi t6, zero, 0x00000015 # use as data segment address
    addi s0, zero, 0x00000001 # skip delay loops if set to 0

    ### Show t0 ###############################################
    # Show t0
    sw t0, 0(t5)    # write t2 to leds

    ### Show t1 ###############################################
    # Show t1
    sw t1, 0(t5)    # write t2 to leds

    ### Test add instruction ##################################
    # Show add(t0, t1)
    add t2, t1, t0
    sw t2, 0(t5)    # write t2 to leds

    ### Test sub instruction ##################################
    # Show sub(t0, t1)
    sub t2, t0, t1
    sw t2, 0(t5)    # write t2 to leds

    ### Test and instruction ##################################
    # Show and(t0, t1)
    and t2, t0, t1
    sw t2, 0(t5)    # write t2 to leds

    ### Test or instruction ###################################
    # Show or(t0, t1)
    or t2, t0, t1
    sw t2, 0(t5)    # write t2 to leds

    ### Test lw instruction and memory mapping of keys ########
    # Show key's at io_base_address + 8
    lw t2, 8(t5)
    sw t2, 0(t5)    # write t2 to leds

    ### Test memory mapping of switches and hex displays ######
    # Show switches at io_base_address + 7
    lw t2, 7(t5)
    sw t2, 1(t5)    # write t2 to hex0 at io_base_address + 1
    sw t2, 2(t5)    # write t2 to hex1 at io_base_address + 2
    sw t2, 3(t5)    # write t2 to hex2 at io_base_address + 3
    sw t2, 4(t5)    # write t2 to hex3 at io_base_address + 4
    sw t2, 5(t5)    # write t2 to hex4 at io_base_address + 5
    sw t2, 6(t5)    # write t2 to hex5 at io_base_address + 6

    ### Loop forever ##########################################
    beq zero, zero, 0
```

This program tests all the instructions except the `beq` instruction. However, because the clock frequency on the FPGA way to large is to observe any changes at the IO.A construction, witch uses the `beq` instruction, between each test was made to make sure there was enough time for the IO's to change (and be observable). This construction consists out of two pieces, the first one increments `t3` to `0x1fe0000`. The second block then simply counts `t3` down till it reaches `zero`, that takes `0x1fe0000 / 50MHz = 0.668s` and should be enough to observe a change in the IO.

```assembly
# t3 = 0xff * 2^17 = 0x1FE0000
    beq s0, zero, exita0    # skip if s0 == zero
    addi t4, zero, 0x00000011
    addi t3, zero, 0x000000ff
    add0:
        add t3, t3, t3
        addi t4, t4, -1
        beq t4, zero, exita0
        beq zero, zero, add0
    exita0:
    
##########################################
#          TEST INSTRUCTION              #
##########################################

# Wait for t3 (0x1FE0000) clockcycli
    beq s0, zero, exit1
    loop0:
        addi t3, t3, -1
        beq t3, zero, exit0
        beq zero, zero, loop0
    exit0:
```



### Simulation

Simulation in Modelsim was done using testbenches. The code below shows the testbench for the `core` module.

```verilog
`timescale 1ns/10ps

module core_tb;
    parameter XLEN = 32;
    parameter IO_INPUT_BUS_LEN = 14;
    parameter IO_OUTPUT_BUS_LEN = 52;
    parameter IO_BASE_ADDR = 'h60;

    reg clock, reset;
    reg [IO_INPUT_BUS_LEN-1:0] io_input_bus;
    wire [IO_OUTPUT_BUS_LEN-1:0] io_output_bus;

    core #(
        .XLEN(XLEN), 
        .IO_OUTPUT_BUS_LEN(IO_OUTPUT_BUS_LEN), 
        .IO_INPUT_BUS_LEN(IO_INPUT_BUS_LEN), 
        .IO_BASE_ADDR(IO_BASE_ADDR)
    ) DUT (
        .clock(clock), 
        .reset(reset), 
        .io_input_bus(io_input_bus),
        .io_output_bus(io_output_bus)
    );

    always #5 clock <= ~clock;

    initial begin
        // Set to known state
        clock <= 0;
        reset <= 1;
        #10 reset <=0;
        // Set inputs                       // --------------------
        #20 io_input_bus[13:10] = 'b0101;   // |13 10|9          0|
        io_input_bus[9:0] = 'b001001110;    // | KEY |     SW     |
        // Stop simulation
        #370 $stop();
    end

    // Simulation output (inspired by Luc's example)
    always begin // Print header line every 20 lines
        $display ("|Time [   PC   ] Instruct |                     Outputs (IO)                     |  Inputs  (IO)  |");
        $display ("|-------------------------|------------------------------------------------------|----------------|");
        #200 $display ("");
    end

    always 
        #10 $display ("|%4d [%8h] %8h | %52b | %14b |", 
            ($time/10), 
            DUT.IF.pc_out, 
            DUT.instruction,
            io_output_bus,
            io_input_bus
        );
endmodule
```

Running this testbench together with the assembly program in memory gives the following text output:
*A pdf of the waveform can be found [here](./resources/Core_tb_wave_15_12_2020.pdf)*

```
# |Time [   PC   ] Instruct |                     Outputs (IO)                     |  Inputs  (IO)  |
# |-------------------------|------------------------------------------------------|----------------|
# |   1 [00000000] 00300293 | 0000000000000000000000000000000000000000000000000000 | xxxxxxxxxxxxxx |
# |   2 [00000004] 00500313 | 0000000000000000000000000000000000000000000000000000 | xxxxxxxxxxxxxx |
# |   3 [00000008] 06000f13 | 0000000000000000000000000000000000000000000000000000 | 01010001001110 |
# |   4 [0000000c] 01500f93 | 0000000000000000000000000000000000000000000000000000 | 01010001001110 |
# |   5 [00000010] 00000413 | 0000000000000000000000000000000000000000000000000000 | 01010001001110 |
# |   6 [00000014] 00040e63 | 0000000000000000000000000000000000000000000000000000 | 01010001001110 |
# |   7 [00000030] 005f2023 | 0000000000000000000000000000000000000000000000000000 | 01010001001110 |
# |   8 [00000034] 04040063 | 0000000000000000000000000000000000000000000000000011 | 01010001001110 |
# |   9 [00000074] 00040e63 | 0000000000000000000000000000000000000000000000000011 | 01010001001110 |
# |  10 [00000090] 005303b3 | 0000000000000000000000000000000000000000000000000011 | 01010001001110 |
# |  11 [00000094] 007f2023 | 0000000000000000000000000000000000000000000000000011 | 01010001001110 |
# |  12 [00000098] 00040863 | 0000000000000000000000000000000000000000000000001000 | 01010001001110 |
# |  13 [000000a8] 00040e63 | 0000000000000000000000000000000000000000000000001000 | 01010001001110 |
# |  14 [000000c4] 406283b3 | 0000000000000000000000000000000000000000000000001000 | 01010001001110 |
# |  15 [000000c8] 007f2023 | 0000000000000000000000000000000000000000000000001000 | 01010001001110 |
# |  16 [000000cc] 00040863 | 0000000000000000000000000000000000000000001111111110 | 01010001001110 |
# |  17 [000000dc] 00040e63 | 0000000000000000000000000000000000000000001111111110 | 01010001001110 |
# |  18 [000000f8] 0062f3b3 | 0000000000000000000000000000000000000000001111111110 | 01010001001110 |
# |  19 [000000fc] 007f2023 | 0000000000000000000000000000000000000000001111111110 | 01010001001110 |
# 
# |Time [   PC   ] Instruct |                     Outputs (IO)                     |  Inputs  (IO)  |
# |-------------------------|------------------------------------------------------|----------------|
# |  20 [00000100] 00040863 | 0000000000000000000000000000000000000000000000000001 | 01010001001110 |
# |  21 [00000110] 00040e63 | 0000000000000000000000000000000000000000000000000001 | 01010001001110 |
# |  22 [0000012c] 0062e3b3 | 0000000000000000000000000000000000000000000000000001 | 01010001001110 |
# |  23 [00000130] 007f2023 | 0000000000000000000000000000000000000000000000000001 | 01010001001110 |
# |  24 [00000134] 00040863 | 0000000000000000000000000000000000000000000000000111 | 01010001001110 |
# |  25 [00000144] 00040e63 | 0000000000000000000000000000000000000000000000000111 | 01010001001110 |
# |  26 [00000160] 008f2383 | 0000000000000000000000000000000000000000000000000111 | 01010001001110 |
# |  27 [00000164] 007f2023 | 0000000000000000000000000000000000000000000000000111 | 01010001001110 |
# |  28 [00000168] 00040863 | 0000000000000000000000000000000000000000000000000101 | 01010001001110 |
# |  29 [00000178] 00040e63 | 0000000000000000000000000000000000000000000000000101 | 01010001001110 |
# |  30 [00000194] 007f2383 | 0000000000000000000000000000000000000000000000000101 | 01010001001110 |
# |  31 [00000198] 007f20a3 | 0000000000000000000000000000000000000000000000000101 | 01010001001110 |
# |  32 [0000019c] 007f2123 | 0000000000000000000000000000000000010011100000000101 | 01010001001110 |
# |  33 [000001a0] 007f21a3 | 0000000000000000000000000000100111010011100000000101 | 01010001001110 |
# |  34 [000001a4] 007f2223 | 0000000000000000000001001110100111010011100000000101 | 01010001001110 |
# |  35 [000001a8] 007f22a3 | 0000000000000010011101001110100111010011100000000101 | 01010001001110 |
# |  36 [000001ac] 007f2323 | 0000000100111010011101001110100111010011100000000101 | 01010001001110 |
# |  37 [000001b0] 00040863 | 1001110100111010011101001110100111010011100000000101 | 01010001001110 |
# |  38 [000001c0] 00000063 | 1001110100111010011101001110100111010011100000000101 | 01010001001110 |
# |  39 [000001c0] 00000063 | 1001110100111010011101001110100111010011100000000101 | 01010001001110 |
# ** Note: $stop    : C:/Users/lowie/Documents/IIW/S5/COMAR/RiscVCore/SingleCycleCore/Source/core_tb.v(36)
#    Time: 400 ns  Iteration: 0  Instance: /core_tb
```



## Synthesizing

After all these tests, synthesizing the design is quite straightforward. The only thing that is left to map all the external signals from the SoCLab board to the `core` module. The "mapping" code is shown below. 


```verilog

//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module SingleCycle(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);



//===Structure===========================================

    parameter XLEN = 32;
    parameter IO_INPUT_BUS_LEN = 14;
    parameter IO_OUTPUT_BUS_LEN = 52;
    parameter IO_BASE_ADDR = 'h60;

    wire [IO_INPUT_BUS_LEN-1:0] io_input_bus;
	assign io_input_bus = {~KEY, SW};
    wire [IO_OUTPUT_BUS_LEN-1:0] io_output_bus;
	assign {HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR} = io_output_bus;

    core #(
        .XLEN(XLEN), 
        .IO_OUTPUT_BUS_LEN(IO_OUTPUT_BUS_LEN), 
        .IO_INPUT_BUS_LEN(IO_INPUT_BUS_LEN), 
        .IO_BASE_ADDR(IO_BASE_ADDR)
    ) C (
        .clock(CLOCK_50), 
        .reset(~KEY[0]), 
        .io_input_bus(io_input_bus),
        .io_output_bus(io_output_bus)
    );


endmodule
```

