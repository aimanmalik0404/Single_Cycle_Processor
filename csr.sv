module csr (
    input logic [31:0 ] inst,
    input logic [31:0] wdata,
    input logic [31:0] pc,
    output logic [31:0] rdata,
    input logic csr_rd,  
    input logic csr_wr,
    input logic rst,
    input logic clk

);
  logic [31:0] csr_mem[6];

  //asynchronous read
  always_comb begin
    if (csr_rd)
    begin
        case (inst[31:20])
        12'h300: rdata = csr_mem[0];
        12'h304: rdata = csr_mem[1];
        12'h305: rdata = csr_mem[2];
        12'h341: rdata = csr_mem[3];
        12'h342: rdata = csr_mem[4];
        12'h344: rdata = csr_mem[5];
        endcase
    end
    else begin
        rdata = 32'b0;
    end
  end

  //synchronous write
  always_ff @(posedge clk) begin
    if (rst) begin
      csr_mem[0] <= 32'b0;
      csr_mem[1] <= 32'b0;
      csr_mem[2] <= 32'b0;
      csr_mem[3] <= 32'b0;
      csr_mem[4] <= 32'b0;
      csr_mem[5] <= 32'b0;
    end
    else if (csr_wr) begin
        case (inst[31:20])
            12'h300: csr_mem[0] <= wdata;
            12'h304: csr_mem[1] <= wdata;
            12'h305: csr_mem[2] <= wdata;
            12'h341: csr_mem[3] <= wdata;
            12'h342: csr_mem[4] <= wdata;
            12'h344: csr_mem[5] <= wdata;
        endcase
    end
  end

endmodule
