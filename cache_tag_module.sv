import cache_def::*;
// Cache: tag memory, single port, 512 blocks Slide 71
module dm_cache_tag(input bit clk,                   // Write clock
                    input cache_req_type tag_req,    // Tag request/command, 10-bits (R/W, valid, etc..)
                    input cache_tag_type tag_write,  // Write port, bits 31-14 bits line
                    output cache_tag_type tag_read   // Read port, bits 31-14 line
);
      timeunit 1ns;
      timeprecision 1ps;

      cache_data_type tag_mem[0:511];   // cache_data_type is a 256-bit line

      initial begin
        for (int i = 0; i < 512; i++)
        tag_mem[i] = '0;
      end

      assign tag_read = tag_mem[tag_req.index]; // tag_req.index is 10 bits

      always_ff @(posedge(clk)) begin
        if (tag_req.we)    // Can be read at any time, writes on +edge of clock & if tag_req.we == 1
        tag_mem[tag_req.index] <= tag_write;
      end
endmodule
