import cache_def::*;

module mem (input bit clk,
            input mem_req_type mem_data,
            output mem_data_type read_data
);
    
      timeunit 1ns;
      timeprecision 1ps;

      cache_data_type data_mem[0:1048575];   // cache_data_type is a 256-bit line

      initial begin
        for (int i = 0; i < 1048576; i++)
        data_mem[i] = '0;
      end

      assign read_data.data = data_mem[mem_data.addr[31:11]];
      assign read_data.ready = 1'b1;

      always_ff @(posedge(clk)) begin
        if (mem_data.rw)    // Can be read at any time, writes on +edge of clock & if data_req.we == 1
        data_mem[mem_data.addr[31:11]] <= mem_data.data;
      end
    
endmodule
