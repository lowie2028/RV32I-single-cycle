module control (
    instruction, 
    branch_enable, 
    mem_write_enable, 
    reg_write_enable, 
    mem_to_reg, 
    ALU_op, 
    ALU_imm, 
    ill_instr
);

    // IO
    input [31:0] instruction;
    output reg branch_enable, mem_write_enable, reg_write_enable, mem_to_reg, ALU_imm, ill_instr;
    output reg [3:0] ALU_op;

    // -- Include definitions ---------------------------------
    `include "ALU_codes.h"
    `include "opcodes.h"

    // -- Extract opcode --------------------------------------
    wire [6:0] opcode;
    assign opcode = instruction[6:0];

    // -- Extract funct3 ---------------------------------------
    wire [2:0] funct3;
    assign funct3 = instruction[14:12];

    // -- Extract funct7 ---------------------------------------
    wire [6:0] funct7;
    assign funct7 = instruction[31:25];

    // -- Determine instruction -------------------------------
    // Lui
    wire lui_inst = (opcode == lui_gr);
    // Auipc
    wire auipc_inst = (opcode == aui_gr);
    // Jal
    wire jal_inst = (opcode == jal_gr);
    // Jalr
    wire jalr_inst = (opcode == jlr_gr) && (funct3 == 3'b000);
    // Branch group
    wire beq_inst = (opcode == bra_gr) && (funct3 == 3'b000);
    wire bne_inst = (opcode == bra_gr) && (funct3 == 3'b001);
    wire blt_inst = (opcode == bra_gr) && (funct3 == 3'b100);
    wire bge_inst = (opcode == bra_gr) && (funct3 == 3'b101);
    wire bltu_inst = (opcode == bra_gr) && (funct3 == 3'b110);
    wire bgeu_inst = (opcode == bra_gr) && (funct3 == 3'b111);
    // Load group
    wire lb_inst = (opcode == loa_gr) && (funct3 == 3'b000);
    wire lh_inst = (opcode == loa_gr) && (funct3 == 3'b001);
    wire lw_inst = (opcode == loa_gr) && (funct3 == 3'b010);
    wire ld_inst = (opcode == loa_gr) && (funct3 == 3'b011);
    wire lbu_inst = (opcode == loa_gr) && (funct3 == 3'b100);
    wire lhu_inst = (opcode == loa_gr) && (funct3 == 3'b101);
    wire lwu_inst = (opcode == loa_gr) && (funct3 == 3'b110);
    // Store group
    wire sb_inst = (opcode == sto_gr) && (funct3 == 3'b000);
    wire sh_inst = (opcode == sto_gr) && (funct3 == 3'b001);
    wire sw_inst = (opcode == sto_gr) && (funct3 == 3'b010);
    wire sd_inst = (opcode == sto_gr) && (funct3 == 3'b011);
    // Arithmetic & logic immediate group
    wire addi_inst = (opcode == rim_gr) && (funct3 == 3'b000);
    wire slli_inst = (opcode == rim_gr) && (funct3 == 3'b001);
    wire slti_inst = (opcode == rim_gr) && (funct3 == 3'b010);
    wire sltiu_inst = (opcode == rim_gr) && (funct3 == 3'b011);
    wire xori_inst = (opcode == rim_gr) && (funct3 == 3'b100);
    wire srli_inst = (opcode == rim_gr) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
    wire srai_inst = (opcode == rim_gr) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
    wire ori_inst = (opcode == rim_gr) && (funct3 == 3'b110);
    wire andi_inst = (opcode == rim_gr) && (funct3 == 3'b111);
    // Arithmetic & logic R-type instructions
    wire add_inst = (opcode == reg_gr) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
    wire sub_inst = (opcode == reg_gr) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
    wire sll_inst = (opcode == reg_gr) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
    wire slt_inst = (opcode == reg_gr) && (funct3 == 3'b010) && (funct7 == 7'b0000000);
    wire sltu_inst = (opcode == reg_gr) && (funct3 == 3'b011) && (funct7 == 7'b0000000);
    wire xor_inst = (opcode == reg_gr) && (funct3 == 3'b100) && (funct7 == 7'b0000000);
    wire srl_inst = (opcode == reg_gr) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
    wire sra_inst = (opcode == reg_gr) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
    wire or_inst = (opcode == reg_gr) && (funct3 == 3'b110) && (funct7 == 7'b0000000);
    wire and_inst = (opcode == reg_gr) && (funct3 == 3'b111) && (funct7 == 7'b0000000);
    // Fence instructions group NOT IMPLEMENTED
    // Csr instructions group NOT IMPLEMENTED

    // -- Set control signals --------------------------------- TODO
    always @(*) begin
        // Reset all signals
        branch_enable <= 0;
        mem_write_enable <= 0;
        reg_write_enable <= 0;
        mem_to_reg <= 0;
        ALU_imm <= 0;
		ALU_op <= 4'b0;
        ill_instr <= 0;
        // Set signal if needed for instruction
        case (1'b1)
            //lui_inst:
            //auipc_inst:
            //jal_inst:
            //jalr_inst: 
            // Branch group
            beq_inst: begin ALU_op <= ALU_SUB; branch_enable <= 1; end
            //bne_inst: 
            //blt_inst: 
            //bge_inst: 
            //bltu_inst: 
            //bgeu_inst: 
            // Load group
            //lb_inst: 
            //lh_inst: 
            lw_inst: begin ALU_op <= ALU_ADD; ALU_imm <= 1; reg_write_enable <= 1; mem_to_reg <= 1; end
            //ld_inst: 
            //lbu_inst: 
            //lhu_inst: 
            //lwu_inst: 
            // Store group
            //sb_inst: 
            //sh_inst: 
            sw_inst: begin ALU_op <= ALU_ADD; ALU_imm <= 1; mem_write_enable <= 1; end
            //sd_inst: 
            // Arithmetic & logic immediate group
            //addi_inst:
            //slli_inst:
            //slti_inst: 
            //sltiu_inst: 
            //xori_inst:
            //srli_inst:
            //srai_inst:
            //ori_inst: 
            //andi_inst:
            // Arithmetic & logic R-type instructions
            add_inst: begin ALU_op <= ALU_ADD; reg_write_enable <= 1; end
            sub_inst: begin ALU_op <= ALU_SUB; reg_write_enable <= 1; end
            //sll_inst: 
            //slt_inst: 
            //sltu_inst: 
            //xor_inst: 
            //srl_inst: 
            //sra_inst: 
            or_inst: begin ALU_op <= ALU_OR; reg_write_enable <= 1; end
            and_inst: begin ALU_op <= ALU_AND; reg_write_enable <= 1; end
            default: ill_instr <= 1;
        endcase
    end
    
endmodule
