module immediate_generator (
    instruction,
    immediate_out
);
parameter XLEN = 32;

input [31:0] instruction;
output [XLEN-1:0] immediate_out;

wire [2:0] instruction_format;

// Instruction format coding
parameter R = 3'b000;  // R-Type: Register operations
parameter I = 3'b001;  // I-Type: Immediates and Loads
parameter S = 3'b010;  // S-Type: Stores
parameter B = 3'b011;  // B-Type: Conditional branches
parameter U = 3'b100;  // U-Type: Upper immediates
parameter J = 3'b101;  // J-Type: Unconditional jumps
parameter ILLEGAL = 3'b111; // ILLEGAL format

// Determine instruction format
`include "opcodes.h"
always @(*) begin
    case (instruction[6:0])
        lui_gr: instruction_format = U;
        aui_gr: instruction_format = U;
        jal_gr: instruction_format = J;
        jlr_gr: instruction_format = I;
        bra_gr: instruction_format = B;
        loa_gr: instruction_format = I;
        sto_gr: instruction_format = S;
        rim_gr: instruction_format = I;
        reg_gr: instruction_format = R;
        fen_gr: instruction_format = I;
        csr_gr: instruction_format = I;
        default: instruction_format = ILLEGAL;
    endcase  
end

// Set generate immediate based on format
// https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf Figure 2.4
always @(*) begin
    case (instruction_format)
        I: immediate_out = {{(XLEN - 11){instruction[31]}}, instruction[30:20]};
        S: immediate_out = {{(XLEN - 11){instruction[31]}}, instruction[30:25], instruction[11:7]};
        B: immediate_out = {{(XLEN - 12){instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        U: immediate_out = {{(XLEN - 31){instruction[31]}}, instruction[30:20], instruction[19:12], 12'b0};
        J: immediate_out = {{(XLEN - 20){instruction[31]}}, instruction[19:12], instruction[20], instruction[30:25], instruction[24:21], 1'b0};
        default: immediate_out = XLEN{1'b0};  // Happens in case of ILLEGAL or R-Type
    endcase
end    
endmodule