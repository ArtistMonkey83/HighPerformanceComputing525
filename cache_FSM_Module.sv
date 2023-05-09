// Cache Finite State Machine, Slide 72
module dm_cache_fsm(input bit clk,                  // Write clock
                    input bit rst,                  // Reset
                    input cpu_req_type cpu_req,     // CPU request input (CPU -> Cache) has 32-bits addr & data, 1-bit rw & valid
                    input mem_data_type mem_data,   // Memory response (Memory -> Cache) has 256-bits data, 1-bit ready
                    output mem_req_type mem_req,    // Memory request (Cache -> Memory) has 32-bits addr, 256-bits data, 1-bit rw & valid
                    output cpu_result_type cpu_res  // Cache result (Cache -> CPU) has 32-bits data, 1-bit ready
);
      timeunit 1ns;
      timeprescision 1ps;

      // Write clock
      typedef enum{ idle, compare_tag, allocate, write_back} cache_state_type;

      //FSM state register
      cache_state_type vstate,    // Next state
                       rstate;    // Current state

      // Interface signals to tag memory
      cache_tag_type tag_read;    // Tag read result, has 1-bit valid & dirty, tag from bits 31-14
      cache_tag_type tag_write;   // Tag write data, has 1-bit valid & dirty, tag from bits 31-14
      cache_req_type tag_req;     // Data request, has 10-bit index, 1-bit W/E

      // Temporary variable for cache controller result
      cpu_result_type v_cpu_res;  // Has 32-bit data and 1-bit ready

      // Temporary variable for memory controller request
      mem_req_type v_mem_req;     // Has 32-bits addr, 256-bits data, 1-bit rw & valid

      assign mem_req = v_mem_req; // Connect to output ports
      assign cpu_res = v_cpu_res; // Connect to output ports

// Default values for all signals, no state change by default, Slide 73
    always_comb begin

      vstate = rstate;
      v_cpu_res = '{0,0};
      tag_write = '{0,0,0};

      tag_req.we = '0;                    // Read tag by Default, 1-bit
      tag_req.index = cpu_req.addr[13:4]; // Direct map index for tag 10-bits

      data_req.we = '0;                   // Read current cache line by Default
      data_req.index = cpu_req.addr[13:4] // Direct map index for cache data

      // Modify correct word based on address, 32-bits
      data_write = data_read;
      case(cpu_req.addr[3:21])    // [3:21] is the block offset
          2'b00: data_write[31:0] = cpu_req.data;    // First word
          2'b01: data_write[63:32] = cpu_req.data;   // Second word
          2'b10: data_write[95:64] = cpu_req.data;   // Third word
          2'b11: data_write[127:96] = cpu_req.data;  // Fourth word
      endcase

      // Read out correct word from Cache -> CPU, 32-bits
      case(cpu_req.addr[3:21])    // [3:21] is the block offset
          2'b00: v_cpu_res.data = data_read[31:0];    // First word
          2'b01: v_cpu_res.data = data_read[63:32];   // Second word
          2'b10: v_cpu_res.data = data_read[95:64];   // Third word
          2'b11: v_cpu_res.data = data_read[127:96];  // Fourth word
      endcase

      v_mem_req.addr =  cpu_req.addr;   // Memory request address sampled from CPU Request, 32-bits
      v_mem_req.data = data_read;       // Memory request data used in write, 256-bits
      v_mem_req.rw = '0;

// Cache FSM Slide 74
      case(rstate)
      // Idle state
          idle: begin
            if(cpu_req.valid)       // If there is a CPU request, then compare the cache tag
              vstate = compare_tag; // Next state
          end

      // Compare Tag state
          compare_tag: begin
            if(cpu_req.addr[TAGMSB:TAGLSB] == tag_read.tag && tag_read.valid) begin
              v_cpu_res.ready = '1; // Ready is 1-bit cpu_result_type struct

              if(cpu_req.rw) begin    // Write hit, rw == 0  read, == 1 write, cpu_req_type struct
                tag_req.we = '1;      // Read cache line, we == read, == write, cache_req_type struct
                data_req.we = '1;     // Modify cache line, we == read, == write, cache_req_type struct
                tag_write.tag = tag_read.tag; // No change in tag, bits [TAGMSB:TAGLSB] 31-14, cache_tag_type struct
                tag_write.valid = '1; // No change in tag
                tag_write.dirty = '1; // Cache line is now dirty!
              end
              vstate = idle;  // xaction is finished, next state
            end

      // Cache miss state
          else begin      // Generate a new tag
            tag_req.we = '1;
            tag_write.valid = '1;                         // 1-bit, cache_tag_type struct
            tag_write.tag = cpu_req.addr[TAGMSB:TAGLSB];  // New tag using bits 31-14
            tag_write.dirty = cpu_req.rw;                 // Cache line is dirty if write!

            v_mem_req.valid = '1;                         // Generate memory request on miss!
            if (tag_read.valid == 1'b0 || tag_read.dirty == 1'b0)   // Compulsory miss or miss with clean block
              vstate = allocate;                          // Wait till a new block is allocated, next State

              else begin      // Miss with a dirty cache line, write back address
                v_mem_req.addr = {tag_read.tag, cpu_req.addr[ TAGLSB-1:0]};    // v_mem_req.addr is 32-bits, mem_req_type struct, cpu_req.addr is 32-bits, cpu_req_type struct
                v_mem_req.rw = '1;
                vstate =  write_back;   // Next state
              end
            end
          end

      // Allocate state, waiting for allocating a new cache line
          allcate: begin
            if (mem_data.ready) begin     // Memory controller has responded
              vstate = compare_tag;       // Re-compare tag for write miss, need to modify correct word, next State
              data_write = mem_data.data; //data is 256-bits, mem_req_type struct
              data_req.we = '1;           // Update cache line data
            end
          end

      // Writeback state, waiting for writing back dirty cache line
          write_back: begin
            if (mem_data.ready) begin     // Write back is completed, issue new memory request, allocating a new line
              v_mem_req.valid = '1;
              v_mem_req.rw = '0;

              vstate = allocate;          // Next state
            end
          end
      endcase
    end

    always_ff @(posedge(clk)) begin
      if (rst)
        rstate <= idle;   // Reset to idle state
      else
        rstate <= vstate;
    end

    // Connect Cache tag and data memory
    dm_cache_tag ctag(.*);
    dm_cache_data cdata (.*);

endmodule
