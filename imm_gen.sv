module imm_gen (
    input  logic [31:0] data,
    output logic [31:0] imm_I,    // I-type immediate
    output logic [31:0] imm_LUI,  // U-type immediate (LUI)
    output logic [31:0] imm_AU,   // AUIPC-type immediate
    output logic [31:0] imm_S,    // S-type immediate
    output logic [31:0] imm_L,    // L-type immediate
    output logic [31:0] imm_B,    // B-type immediate
    output logic [31:0] imm_J,    // JAL-type immediate
    output logic [31:0] imm_JR    // JALR-type immediate
);

  logic [6:0] opcode;
  assign opcode = data[6:0];

  always_comb begin
    case (opcode)
      7'b0010011: imm_I = {{20{data[31]}}, data[31:20]};  // I-type instructions (12-bit immediate, sign-extended to 32 bits)
      7'b0110111: imm_LUI = {data[31:12], 12'b0};  // LUI instructions (20-bit immediate, extended to 32 bits)
      7'b0010111: imm_AU = {data[31:12], 12'b0};  //AUIPC instruction
      7'b0100011: imm_S = {{20{data[31]}}, data[31:25], data[11:7]};  // S-type instructions (12-bit immediate, sign-extended to 32 bits)
      7'b0000011: imm_L = {{20{data[31]}}, data[31:20]};  // Load-type instructions (12-bit immediate, sign-extended to 32 bits)
      7'b1100011: imm_B = {{19{data[31]}}, data[31], data[7], data[30:25], data[11:8], 1'b0};  // B-type (branch) instructions (13-bit immediate, sign-extended to 32 bits)
      7'b1101111: imm_J = {{11{data[31]}}, data[31], data[19:12], data[20], data[30:21], 1'b0};  // J-type JAL
      7'b1100111: imm_JR = {{20{data[31]}}, data[31:20]};  // J-type JALR
      default begin
        imm_I   = 32'b0;
        imm_LUI = 32'b0;
        imm_AU  = 32'b0;
        imm_S   = 32'b0;
        imm_L   = 32'b0;
        imm_B   = 32'b0;
        imm_J   = 32'b0;
        imm_JR  = 32'b0;
      end
    endcase
  end

endmodule
