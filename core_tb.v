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