`timescale 1ns/10ps

module core_tb;
    parameter XLEN = 32;
    parameter IO_INPUT_BUS_LEN = 14;
    parameter IO_OUTPUT_BUS_LEN = 52;
    parameter IO_BASE_ADDR = 'h60;

    reg clock, reset;
    wire [IO_INPUT_BUS_LEN-1:0] io_input_bus;
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
        clock <= 0;
        reset <= 1;
        #10 reset <=0;
    end
endmodule