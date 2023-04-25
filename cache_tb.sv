module testbench();
    logic clk;
    logic rst;
    logic [65:0] cpu_req; // 32 bit address, 32 bit data, 1 bit rw, 1 bit valid
    logic [256:0] mem_data; //256 (128 in class) bit read back data, 1 bit ready
    logic [32:0] mem_req; // 32 bit address, 256 data, 1 bit rw, 1 bit valid
    logic [32:0]cpu_res; //32 bit data, 1 bit ready

    //instantiate device to be tested
    dm_cache_fsm dut(
      .clk (clk),
      .rst (rst),
      .cpu_req (cpu_req),
      .mem_data(mem_data),
      .mem_req(mem_req),
      .cpu_res(cpu_res)
    );

    //initialize test
    initial
        begin
        // CPU Request: CPU -> Cache
        cpu_req = 66'b00000000;
        // Cache Result: Cache -> CPU
        cpu_res = 257'b00000000;
        // Memory Response: Memory -> Cache
        mem_data = 33'b00000000;
        // Memory Request: Cache -> Memory
        mem_req = 33'b00000000;

        end

    //generate clock to sequence tests
    always
        begin
            clk <= 1; #5; clk<= 0; #5;
        end

    //check results

    //A CPU request to the cache comes in
        //Does the cache contain what CPU is requesting?
          //?Yes, return the appropriate value to CPU
          //?No,  send a (read?) request to memory
        //Does Memory contain what the CPU is requesting?
          //?Yes Memory responds (write?) with appropriate value to populate cache
              //take from cache the value to be replaced and save it in memory?
          //?No, memory doesn't have the value CPU is requesting

    always@(posedge clk)
        begin
          if (rst == 1 )begin // Cache was reset
            //clear the cache of all values? Set the valid bit 

          else if(cpu_req != 66'h00000000) // cpu_req has a value different from what it was set at initialization, a valid cpu_req exists
            begin

            end

          end

        end


endmodule
