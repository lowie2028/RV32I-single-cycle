// Instruction opcode groups
    wire [6:0] lui_gr = 'b0110111; // Lui
    wire [6:0] aui_gr = 'b0010111; // Auipc
    wire [6:0] jal_gr = 'b1101111; // Jal
    wire [6:0] jlr_gr = 'b1100111; // Jalr
    wire [6:0] bra_gr = 'b1100011; // Branch group
    wire [6:0] loa_gr = 'b0000011; // Load group
    wire [6:0] sto_gr = 'b0100011; // Store group
    wire [6:0] rim_gr = 'b0010011; // Arithmetic & logic immediate group
    wire [6:0] reg_gr = 'b0110011; // Arithmetic & logic R-type instructions
    wire [6:0] fen_gr = 'b0001111; // Fence instructions group
    wire [6:0] csr_gr = 'b1110011; // Csr instructions group