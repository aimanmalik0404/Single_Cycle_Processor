module tb_processor ();
  logic clk;
  logic rst;

  processor dut (
      .clk(clk),
      .rst(rst)
  );

  // Clock Generator
  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end

  //reset generator
  initial begin
    rst = 1;
    #1;
    rst = 0;
    #1000;
    $finish;
  end

  // initializing memory
  initial begin
    $readmemb("instruction_memory", dut.imem.mem);
    $readmemb("register_file", dut.reg_file_inst.reg_mem);
    $readmemb("data_memory", dut.data_mem_inst.memory_array); 
    $readmemb("csr_register_file", dut.csr_inst.csr_mem); 
    #100;
  end

  //dumping output
  initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0, tb_processor);
  end
endmodule
