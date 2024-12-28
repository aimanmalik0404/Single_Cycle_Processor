module data_mem (
    input  logic        clk,
    input  logic [31:0] addr,        // Base address from ALU for load/store
    input  logic [31:0] write_data,  // Data to be written to memory for store
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [ 2:0] func3,       // ALU operation code
    output logic [31:0] rdata // Data read from memory for load
);

  logic [31:0] memory_array[40];  // 40 rows of 32-bit words

  // Read operation for Load
  always_comb begin
    if (mem_read) begin
      case (func3)
        3'b000:  // LB (Load Byte)
        rdata = {{24{memory_array[addr][7]}}, memory_array[addr][7:0]};  // Sign-extend byte
        3'b001:  // LH (Load Halfword)
        rdata = {{16{memory_array[addr][15]}}, memory_array[addr][15:0]};  // Sign-extend halfword
        3'b010:  // LW (Load Word)
        rdata = memory_array[addr];  // Load full word
        default: rdata = 32'b0;
      endcase
    end else begin
      rdata = 32'b0;
    end
  end

  // Write operation for Store
  always_ff @(posedge clk) begin
    if (mem_write) begin
      case (func3)
        3'b000:  // SB (Store Byte)
        memory_array[addr][7:0] <= write_data[7:0];  // Store only the lower byte
        3'b001:  // SH (Store Halfword)
        memory_array[addr][15:0] <= write_data[15:0];  // Store only the lower halfword
        3'b10:  // SW (Store Word)
        memory_array[addr] <= write_data;  // Store full word
      endcase
    end
  end

endmodule
