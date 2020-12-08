module data_memory (address, write_data, write_enable, read_data, clock, reset);
    parameter XLEN = 32;
    parameter DEPTH = 64;
    
    input write_enable, clock, reset;
    input [XLEN-1:0] address, write_data;
    output reg [XLEN-1:0] read_data;

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
endmodule