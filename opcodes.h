// Instruction opcode groups
    wire lui_gr = 'b0110111; // Lui
    wire aui_gr = 'b0010111; // Auipc
    wire jal_gr = 'b1101111; // Jal
    wire jlr_gr = 'b1100111; // Jalr
    wire bra_gr = 'b1100011; // Branch group
    wire loa_gr = 'b0000011; // Load group
    wire sto_gr = 'b0100011; // Store group
    wire rim_gr = 'b0010011; // Arithmetic & logic immediate group
    wire reg_gr = 'b0110011; // Arithmetic & logic R-type instructions
    wire fen_gr = 'b0001111; // Fence instructions group
    wire csr_gr = 'b1110011; // Csr instructions group