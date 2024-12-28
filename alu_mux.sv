module alu_mux (
    output  logic [31:0] opr_b,
    input  logic imm_en,
    input logic [ 6:0] opcode,
    input logic [31:0] imm_I,    // I-type immediate
    input logic [31:0] imm_LUI,  // U-type immediate (LUI)
    input logic [31:0] imm_AU,   // AUIPC-type immediate
    input logic [31:0] imm_S,    // S-type immediate
    input logic [31:0] imm_L,    // L-type immediate
    input logic [31:0] imm_B,    // B-type immediate
    input logic [31:0] imm_J,    // JAL-type immediate
    input logic [31:0] imm_JR,    // JALR-type immediate
    input logic [31:0] rdata2
);

  always_comb begin
    if (imm_en) begin
      case (opcode)
      7'b0010011: opr_b = imm_I;
      7'b0110111: opr_b = imm_LUI;
      7'b0010111: opr_b = imm_AU;
      7'b0000011: opr_b = imm_L;
      7'b0100011: opr_b = imm_S;
      7'b1100011: opr_b = imm_B;
      7'b1101111: opr_b = imm_J;
      7'b1100111: opr_b = imm_JR;
      default:    opr_b = 32'b0;
      endcase
    end
    else begin
        opr_b = rdata2;
    end
  end
endmodule
