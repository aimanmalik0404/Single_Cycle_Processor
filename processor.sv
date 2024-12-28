module processor (
    input logic clk,
    input logic rst
);
  // Internal signals
  logic [31:0] pc_out;
  logic [31:0] inst;
  logic [ 6:0] opcode;
  logic [31:0] csr_rdata;
  logic [31:0] read_data;  // Data read from data memory
  logic [31:0] write_data;  // Data to write to data memory
  logic [ 2:0] func3;
  logic [ 6:0] func7;
  logic [ 4:0] rs1;
  logic [ 4:0] rs2;
  logic [ 4:0] rd;
  logic [31:0] alu_result;  // ALU output
  logic [31:0] rdata1;
  logic [31:0] rdata2;
  logic [31:0] opr_b;
  logic [31:0] wdata;
  logic [ 3:0] aluop;
  logic [31:0] imm_I;    // I-type immediate
  logic [31:0] imm_AU;   // AUIPC-type immediate
  logic [31:0] imm_LUI;  // LUI-type immediate
  logic [31:0] imm_S;    // S-type immediate
  logic [31:0] imm_L;    // L-type immediate
  logic [31:0] imm_B;    // B-type immediate
  logic [31:0] imm_J;    // JAL-type immediate
  logic [31:0] imm_JR;    // JALR-type immediate
  logic rf_en, imm_en, mem_read, mem_write,csr_rd,csr_wr;
  logic [ 1:0] wb_sel;  // Write-back select signal from controller
  logic        br_true;
  logic [31:0] next_pc;  // Next PC value for JAL, JALR, and branches

  // Program Counter instance
  pc pc_inst (
      .clk   (clk),
      .rst   (rst),
      .pc_in (next_pc),
      .pc_out(pc_out)
  );

  // Instruction Memory Instance
  inst_mem imem (
      .addr(pc_out),
      .data(inst)
  );

  // Instruction Decoder
  inst_dec inst_instance (
      .inst  (inst),
      .rs1   (rs1),
      .rs2   (rs2),
      .rd    (rd),
      .opcode(opcode),
      .func3 (func3),
      .func7 (func7)
  );

  // Register File
  reg_file reg_file_inst (
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .rf_en(rf_en),
      .clk(clk),
      .rdata1(rdata1),
      .rdata2(rdata2),
      .wdata(wdata)  // Write data from ALU or memory
  );

  csr csr_inst (
    .csr_rd (csr_rd),
    .csr_wr (csr_wr),
    .inst (inst),
    .pc (next_pc),
    .rdata (csr_rdata),
    .wdata (write_data),
    .rst (rst),
    .clk (clk)
  );

  // Controller
  controller contr_inst (
      .opcode(opcode),
      .func3(func3),
      .func7(func7),
      .rf_en(rf_en),
      .csr_rd (csr_rd),
      .csr_wr (csr_wr),
      .aluop(aluop),
      .imm_en(imm_en),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .sel_A (sel_A),
      .wb_sel(wb_sel)  // Write-back select signal
  );

  // ALU
  alu alu_inst (
      .opr_a(sel_A ? pc_out : rdata1),  // Selection based on sel_A signal
      .opr_b(opr_b),
      .aluop(aluop),
      .rs1(rs1),
      .pc_out(pc_out),
      .opr_res(alu_result)  // ALU result
  );

  // Immediate Generator
  imm_gen imm_gen_inst (
      .data(inst),
      .imm_I(imm_I),
      .imm_AU(imm_AU),
      .imm_LUI(imm_LUI),
      .imm_B(imm_B),
      .imm_S(imm_S),
      .imm_L(imm_L),
      .imm_J(imm_J),
      .imm_JR(imm_JR)
  );

  // ALU Multiplexer
  alu_mux alu_mux_inst (
      .imm_en(imm_en),
      .opr_b(opr_b),
      .imm_I(imm_I),
      .imm_AU(imm_AU),
      .imm_LUI(imm_LUI),
      .imm_B(imm_B),
      .imm_S(imm_S),
      .imm_L(imm_L),
      .imm_J(imm_J),
      .imm_JR(imm_JR),
      .opcode(opcode),
      .rdata2(rdata2)
  );

  // Data Memory Instance
  data_mem data_mem_inst (
      .clk       (clk),         // Clock signal for memory
      .addr      (alu_result),  // Address for load/store (from ALU result)
      .write_data(rdata2),      // Data to write to memory (from rdata2)
      .mem_read  (mem_read),    // Memory read enable
      .mem_write (mem_write),   // Memory write enable
      .func3     (func3),
      .rdata     (read_data)    // Data read from memory
  );

  // Branch Condition Generator
  branch_cond_gen branch_cond_gen_inst (
      .func3  (func3),
      .rdata1 (rdata1),
      .rdata2 (rdata2),
      .aluop (aluop),
      .br_true(br_true)
  );

  // Logic for Write Data (Load/Store)
  always_ff @(posedge clk) begin
    if (rst) begin
      wdata <= 32'b0;  // Reset write data to 0
    end else if (rf_en) begin
      // Write-back to register file based on wb_sel
      case (wb_sel)
        2'b00:   wdata <= alu_result;  // ALU result
        2'b01:   wdata <= read_data;  // Memory read data
        2'b10:   wdata <= pc_out + 32'd4;  // PC + 4 for JAL, JALR
        default: wdata <= 32'b0;
      endcase
    end
  end

  // Next PC Logic for Branches and Jumps
  always_comb begin
    if (opcode == 7'b1101111) begin  // JAL instruction
      next_pc = pc_out + imm_J;  // Jump to the target address
    end else if (opcode == 7'b1100111) begin  // JALR instruction
      next_pc = (rdata1 + imm_JR) & 32'hFFFFFFFE;  // Align to even address
    end else if (br_true) begin  // B-type branch taken
      next_pc = pc_out + imm_B;  // Branch to target address
    end else begin
      next_pc = pc_out + 32'd4;  // Default: PC increment by 4 (sequential execution)
    end
  end

endmodule
