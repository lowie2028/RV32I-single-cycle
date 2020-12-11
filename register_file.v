module register_file (read_reg_0, read_reg_1, write_reg, write_data, write_enable, read_data_0, read_data_1, clock, reset);
    parameter XLEN = 32;

    input [4:0] read_reg_0, read_reg_1, write_reg;
    input [XLEN-1:0] write_data;
    input write_enable, clock, reset;
    output reg [XLEN-1:0] read_data_0, read_data_1;

    // Reg_file is 32 words deep for RV32I
    reg [XLEN-1:0] reg_file [31:0];

    // Process for reading
    always @ (*) begin
			if (read_reg_0 == 0)	// x0 is always zero
				read_data_0 <= 0;
			else
            read_data_0 <= reg_file [read_reg_0];
			if (read_data_1 == 0) // x0 is always zero
				read_data_1 <= 0;
			else
            read_data_1 <= reg_file [read_reg_1];
    end

    // Process for writing
    integer i;
    always @ (posedge clock) begin
        if (reset)
            for (i=0; i < 32; i=i+1)
                reg_file [i] <= 32'b0;
        else if (write_enable == 1) begin
            if (write_reg != 0) begin   // Write register != x0
                reg_file [write_reg] <= write_data;
            end
        end
    end
endmodule