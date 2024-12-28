module alu (
    input  logic [31:0] opr_a,
    input  logic [31:0] opr_b,
    input  logic [4:0] rs1,
    input  logic [ 3:0] aluop,
    input logic [31:0] pc_out,
    output logic [31:0] opr_res
);

  always_comb begin
    case (aluop)
      //write 10 operations of alu
      4'b0000: opr_res = opr_a + opr_b;
      4'b0001: opr_res = opr_a - opr_b;
      4'b0010: opr_res = opr_a << opr_b[4:0];  // SLL (Shift Left Logical)
      4'b0011: opr_res = (opr_a < opr_b) ? 32'b1 : 32'b0;  // SLT (Set Less Than)
      4'b0100:
      opr_res = ($unsigned(opr_a) < $unsigned(opr_b)) ? 32'b1 :
          32'b0;  // SLTU (Set Less Than Unsigned)
      4'b0101: opr_res = opr_a ^ opr_b;  // XOR
      4'b0110: opr_res = opr_a >> opr_b[4:0];  // SRL (Shift Right Logical)
      4'b0111: opr_res = opr_a >>> opr_b[4:0];  // SRA (Shift Right Arithmetic)
      4'b1000: opr_res = opr_a | opr_b;  // OR
      4'b1001: opr_res = opr_a & opr_b;  // AND
      4'b1010: opr_res = opr_b;  // LUI: Load immediate into upper bits
      4'b1011: opr_res = pc_out + opr_b;  // AUIPC: Add immediate to PC
      4'b1110: opr_res = rs1 + opr_b;  // Load/Store address calculation
      default: opr_res = 32'b0;  // Default case

    endcase

  end
  initial begin
    $monitor("Time: %0t | opr_a: %b | opr_b: %b | aluop: %b | opr_res: %b", $time, opr_a, opr_b,
             aluop, opr_res);
  end

endmodule
