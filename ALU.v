module ALU (
    in_0,
    in_1,
    operation,
    out,
    zero
);
parameter XLEN = 32;

input [XLEN-1:0] in_0, in_1;
input [3:0] operation;
output [XLEN-1:0] out;
output zero;

`include "ALU_codes.h"
always @(*) begin
    case (operation)
        ALU_AND: out <= in_0 & in_1;
        ALU_OR: out <= in_0 | in_1;
        ALU_ADD: out <= in_0 + in_1;
        ALU_SUB: out <= in_0 - in_1;
        default: out <= {XLEN{1'b0}};
    endcase
    zero <= (out == XLEN`b0);
end
    
endmodule