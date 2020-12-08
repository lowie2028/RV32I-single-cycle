// Instruction opcode groups
parameter lui_gr = 7'b0110111; // Lui
parameter aui_gr = 7'b0010111; // Auipc
parameter jal_gr = 7'b1101111; // Jal
parameter jlr_gr = 7'b1100111; // Jalr
parameter bra_gr = 7'b1100011; // Branch group
parameter loa_gr = 7'b0000011; // Load group
parameter sto_gr = 7'b0100011; // Store group
parameter rim_gr = 7'b0010011; // Arithmetic & logic immediate group
parameter reg_gr = 7'b0110011; // Arithmetic & logic R-type instructions
parameter fen_gr = 7'b0001111; // Fence instructions group
parameter csr_gr = 7'b1110011; // Csr instructions group