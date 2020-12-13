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
    output reg [IO_OUTPUT_BUS_LEN-1:0] io_output_bus;

    reg [XLEN-1:0] mem [DEPTH-1:0];

    // Process for reading
    always @ (*) begin
        if (address >= 0 && address < DEPTH)
            read_data <= mem [address];
        else
            read_data <= {XLEN-1{1'b0}};
    end
    // -------------------------------------------------------
    // Process for writing
    // -------------------------------------------------------
    integer i;
    always @ (posedge clock) begin
        if (reset)
            for (i=0; i < DEPTH; i=i+1)
                    mem [i] <= {XLEN{1'b0}};
        else if (write_enable == 1) begin
            if (address >= 0 && address < DEPTH) begin   // Only write when within bounds and not driven by IO
                if (address < IO_BASE_ADDR + 7 || address > IO_BASE_ADDR + 8) begin
                    mem [address] <= write_data;
                end
            end
        end
        // Write memory mapped inputs
        // --------------------
        // |13   |9          0|
        // | KEY |     SW     |
        // --------------------
        mem [IO_BASE_ADDR + 7] <= io_input_bus[9:0];
        mem [IO_BASE_ADDR + 8] <= io_input_bus[13:10];
    end

    // -------------------------------------------------------
    // Read memory mapped outputs
    // -------------------------------------------------------
    // |51    |44    |37    |30    |23    |16    |9         0|
    // | HEX5 | HEX4 | HEX3 | HEX2 | HEX1 | HEX0 |    LED    |
    // -------------------------------------------------------
    // Create binary to 7-segment convertors
    wire [7*6-1:0] seg_data;
    wire [4*6-1:0] bin_data;
    assign bin_data = mem [IO_BASE_ADDR + 1];
    bin2seg seg_convert0 (bin_data[3:0], seg_data[6:0]);
    bin2seg seg_convert1 (bin_data[7:4], seg_data[13:7]);
    bin2seg seg_convert2 (bin_data[11:8], seg_data[20:14]);
    bin2seg seg_convert3 (bin_data[15:12], seg_data[27:21]);
    bin2seg seg_convert4 (bin_data[19:16], seg_data[34:28]);
    bin2seg seg_convert5 (bin_data[23:20], seg_data[41:35]);
    always @(*) begin
		  // Set leds
		  io_output_bus[9:0] <= mem [IO_BASE_ADDR];
		  // Set 7-segment displays
        if (io_input_bus[9] == 1) begin // SW9 toggles between binary and hexadecimal mode
            io_output_bus[16:10] <= seg_data[6:0];
            io_output_bus[23:17] <= seg_data[13:7];
            io_output_bus[30:24] <= seg_data[20:14];
            io_output_bus[37:31] <= seg_data[27:21];
            io_output_bus[44:38] <= seg_data[34:28];
            io_output_bus[51:45] <= seg_data[41:35];
        end else begin
            io_output_bus[16:10] <= mem [IO_BASE_ADDR + 1][6:0];
            io_output_bus[23:17] <= mem [IO_BASE_ADDR + 2][6:0];
            io_output_bus[30:24] <= mem [IO_BASE_ADDR + 3][6:0];
            io_output_bus[37:31] <= mem [IO_BASE_ADDR + 4][6:0];
            io_output_bus[44:38] <= mem [IO_BASE_ADDR + 5][6:0];
            io_output_bus[51:45] <= mem [IO_BASE_ADDR + 6][6:0];
        end
    end
endmodule