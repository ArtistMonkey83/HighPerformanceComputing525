import cache_def::*;

module mem (input bit clk,
            input mem_req_type mem_req,
            output mem_data_type read_data
);
    
      timeunit 1ns;
      timeprecision 1ps;

      cache_data_type data_mem[0:1048575];   // cache_data_type is a 256-bit line
      

      initial begin
        //for (int i = 0; i < 1048576; i++) begin
        //data_mem[i] = '0;
        //end
        data_mem[32'h00014024] <= 256'h1111111122222222333333334444444455555555666666667777777788888888;
        data_mem[32'h0001C024] <= 256'h2222222233333333444444445555555566666666777777778888888899999999;
      end

      assign read_data.data = data_mem[mem_req.addr[19:0]];
      assign read_data.ready = 1'b1;

      always_ff @(posedge(clk)) begin
        if (mem_req.rw)    // Can be read at any time, writes on +edge of clock & if mem_req.rw == 1
        data_mem[mem_req.addr[19:0]] <= mem_req.data;
      end
    
endmodule
