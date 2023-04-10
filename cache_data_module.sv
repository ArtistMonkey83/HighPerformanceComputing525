// Cache : data memory, single port, 1024 blocks Slide 70
module dm_cache_data(input bit clk,                     // Write clock
                     input cache_req_type data_req,     // Data request/command, 10 bits (R/W, valid,etc..)
                     input cache_data_type data_write,  // Write port, a 128-bit line
                     output cache_data_type data_read   // Read port, a 128-bit line
);
      timeunit 1ns;
      timeprescision 1ps;

      cache_data_type data_mem[0:1023];   // cache_data_type is a 128-bit line

      initial begin
        for (int i = 0; i < 1024; i++)
        data_mem[i] = * 0; // is it * or ' ? 
      end

      assign data_read = data_mem[data_req.index]; // data_req.index is 10 bits

      always_ff @(posedge(clk)) begin
        if (data_req.we)    // Can be read at any time, writes on +edge of clock & if data_req.we == 1
        data_mem[data_req.index] <= data_write;
      end
endmodule
