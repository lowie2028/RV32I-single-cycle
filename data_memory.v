module data_memory (address, write_data, write_enable, read_data, clock, reset, io_input_bus, io_output_bus);
    parameter XLEN = 32;
    parameter DEPTH = 64;

    parameter IO_INPUT_BUS_LEN = 14;
    parameter IO_OUTPUT_BUS_LEN = 52;
    parameter IO_BASE_ADDR = 64;
    
    input write_enable, clock, reset;
    input [XLEN-1:0] address, write_data;
    output reg [XLEN-1:0] read_data;

    input [IO_INPUT_BUS_LEN-1:0] io_input_bus;
    output [IO_OUTPUT_BUS_LEN-1:0] io_output_bus;

    reg [XLEN-1:0] mem [DEPTH-1:0];

    // Process for reading
    always @ (*) begin
        if (address >= 0 && address < DEPTH)
            read_data <= mem [address];
        else
            read_data <= {XLEN-1{1'b0}};
    end

    // Process for writing
    integer i;
    always @ (posedge clock) begin
        if (reset)
            for (i=0; i < DEPTH; i=i+1)
                mem [i] <= {XLEN{1'b0}};
        else if (write_enable == 1) begin
            if (address >= 0 && address < DEPTH) begin   // Only write when within bounds
                mem [address] <= write_data;
            end
        end
    end

    // Io mapping
    // -------------------------------------------------------
    // |51    |44    |37    |30    |23    |16    |9         0|
    // | HEX5 | HEX4 | HEX3 | HEX2 | HEX1 | HEX0 |    LED    |
    // -------------------------------------------------------
    assign io_output_bus[9:0] = mem [IO_BASE_ADDR];
    assign io_output_bus[16:10] = mem [IO_BASE_ADDR + 1];
    assign io_output_bus[23:17] = mem [IO_BASE_ADDR + 2];
    assign io_output_bus[30:24] = mem [IO_BASE_ADDR + 3];
    assign io_output_bus[37:31] = mem [IO_BASE_ADDR + 4];
    assign io_output_bus[44:38] = mem [IO_BASE_ADDR + 5];
    assign io_output_bus[51:45] = mem [IO_BASE_ADDR + 6];
    // --------------------
    // |13   |9          0|
    // | KEY |     SW     |
    // --------------------
    always @(posedge clock) begin
        mem [IO_BASE_ADDR + 7] <= io_input_bus[9:0];
        mem [IO_BASE_ADDR + 8] <= io_input_bus[13:10];
    end
endmodule