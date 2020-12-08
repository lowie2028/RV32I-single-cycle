`timescale 1ns/10ps

module core_tb;
reg clock, reset;
parameter XLEN = 32;

core #(.XLEN(XLEN)) DUT (.clock(clock), .reset(reset));

always #5 clock <= ~clock;

initial begin
    clock <= 0;
    reset <= 1;
    #10 reset <=0;
end

endmodule