`timescale 1ns/10ps

module register_file_tb;

     task assert_eq(input a, b);
        if(!(a===b)) begin
            $display("Assertion error: %h != %h", a, b);
            $stop;
        end
    endtask

    parameter XLEN = 32;

    reg write_enable, clock, reset;
    reg [4:0] read_reg_0, read_reg_1, write_reg;
    reg [XLEN-1:0] write_data;
    wire [XLEN-1:0] read_data_0, read_data_1;

    register_file #(.XLEN(XLEN)) DUT (read_reg_0, read_reg_1, write_reg, write_data, write_enable, read_data_0, read_data_1, clock, reset);

    integer i;
    initial begin
        // Reset register file
        reset <= 1;
        // Rising edge clock
        clock <= 0;
        #1 clock <=1;
        #1 reset <=0;
        $display("Resetting register file: OK");

        // Write to all registers
        write_enable <= 1;
        for (i=0; i<32; i=i+1) begin
            // Set input
            write_reg <= i;
            write_data <= 32 - i;
            // Rising edge clock
            clock <= 0;
            #1 clock <=1;
            #1;
        end
        $display("Writing registers: OK");

        // Read all registers
        write_enable <= 0;
        for (i=0; i<32; i=i+2) begin
            read_reg_0 <= i;
            read_reg_1 <= i+1;
            #1;
            //$display ("%h:   %h", read_reg_0, read_data_0);
            //$display ("%h:   %h", read_reg_1, read_data_1);
            assert_eq(read_data_0, 32-i);
            assert_eq(read_data_1, 32-(i+1));
        end
        $display("Reading registers: OK");

        $display("Testbench has finished: EVERYTHING OK");
        $stop;
    end
endmodule
