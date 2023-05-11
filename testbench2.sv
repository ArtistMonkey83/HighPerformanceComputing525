`timescale 1ns / 1ps

module dm_cache_fsm_tb();
    // Inputs
    logic clk;
    logic rst;
    cpu_req_type cpu_req;
    mem_req_type mem_req;
    mem_data_type read_data;

    // Outputs
    mem_data_type mem_data;
    cpu_result_type cpu_res;

    mem memory(.clk(clk), .mem_req(mem_req), .read_data(read_data));

    dm_cache_fsm dut (
        .clk(clk),
        .rst(rst),
        .cpu_req(cpu_req),
        .mem_data(mem_data),
        .mem_req(mem_req),
        .cpu_res(cpu_res)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize inputs
        rst = 1;
        cpu_req.valid = 0;
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 0;

        // Wait for some time to let the reset settle
        #10 rst = 0;

        // Test case 1: Read (compulsory miss)
        $display("Test Case 1: Read (compulsory miss)");
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 32'h00014024;
        cpu_req.valid = 1;
        # 10;
        $display("CPU Request Address: %h", cpu_req.addr);
        $display("Memory Request Address: %h", mem_req.addr);
        $display("Data: %h", read_data.data);
        cpu_req.valid = 0;
        #10;
        
        // Test Case 2: Read (hit clean line)
        $display("\nTest Case 2: Read (hit clean line)");
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 32'h00014024;
        cpu_req.valid = 1;
        # 10;
        $display("CPU Request Address: %h", cpu_req.addr);
        $display("Memory Request Address: %h", mem_req.addr);
        $display("Data: %h", read_data.data);
        cpu_req.valid = 0;
        #10;
        
        // Test Case 3: Write (hit clean line (cache line is dirty afterwards))
        $display("\nTest Case 3: Write (hit clean line (cache line is dirty afterwards))");
        cpu_req.rw = 1;
        cpu_req.data = 32'hAAAAAAAA;
        cpu_req.addr = 32'h00014024;
        cpu_req.valid = 1;
        # 10;
        $display("CPU Request Address: %h", cpu_req.addr);
        $display("Memory Request Address: %h", mem_req.addr);
        $display("Memory Request RW: %h", mem_req.rw);
        $display("Data: %h", read_data.data);
        cpu_req.valid = 0;
        #10;
        
        // Test Case 4: Write (conflict miss (write back then allocate, cache line dirty))
        $display("\nTest Case 4: Write (conflict miss (write back then allocate, cache line dirty))");
        cpu_req.rw = 1;
        cpu_req.data = 32'hAAAAAAAA;
        cpu_req.addr = 32'h0001C024;
        cpu_req.valid = 1;
        # 10;
        $display("CPU Request Address: %h", cpu_req.addr);
        $display("Memory Request Address: %h", mem_req.addr);
        $display("Memory Request RW: %h", mem_req.rw);
        $display("Data: %h", read_data.data);
        cpu_req.valid = 0;
        #10;
        
        // Test Case 5: Read (hit dirty line)
        $display("\nTest Case 5: Read (hit dirty line)");
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 32'h0001C024;
        cpu_req.valid = 1;
        # 10;
        $display("CPU Request Address: %h", cpu_req.addr);
        $display("Memory Request Address: %h", mem_req.addr);
        $display("Data: %h", read_data.data);
        cpu_req.valid = 0;
        #10;
        
        // Test case 6: Read (conflict miss dirty line (write back then allocate, cache line is clean))
        $display("\nTest case 6: Read (conflict miss dirty line (write back then allocate, cache line is clean))");
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 32'h00014024;
        cpu_req.valid = 1;
        # 10;
        $display("CPU Request Address: %h", cpu_req.addr);
        $display("Memory Request Address: %h", mem_req.addr);
        $display("Data: %h", read_data.data);
        cpu_req.valid = 0;
        #10; 
        
    end

endmodule
