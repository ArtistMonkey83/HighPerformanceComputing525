`timescale 1ns / 1ps

module dm_cache_fsm_tb();
    // Inputs
    logic clk;
    logic rst;
    logic [255:0] data;
    logic ready;
    cpu_req_type cpu_req;
    mem_req_type mem_req;

    // Outputs
    mem_data_type mem_data;
    cpu_result_type cpu_res;

    dm_cache_fsm dut (
        .clk(clk),
        .rst(rst),
        .cpu_req(cpu_req),
        .mem_data(mem_data),
        .cpu_res(cpu_res)
    );

    initial begin
        clk = 0;
        forever ##5 clk = ~clk;
    end

    initial begin
        // Initialize inputs
        rst = 1;
        cpu_req.valid = 0;
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 0;

        // Wait for some time to let the reset settle
        ##10 rst = 0;

        // Test case 1: Read hit
        cpu_req.valid = 1;
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 32'h80004000;
        ##10;
        cpu_req.valid = 0;
        ##100;

        // Test case 2: Write hit
        cpu_req.valid = 1;
        cpu_req.rw = 1;
        cpu_req.data = 32'h01234567;
        cpu_req.addr = 32'h80004004;
        ##10;
        cpu_req.valid = 0;
        ##100;

        // Test case 3: Read miss
        cpu_req.valid = 1;
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 32'h80004010;
        ##10;
        cpu_req.valid = 0;
        ##100;

        // Test case 4: Write miss
        cpu_req.valid = 1;
        cpu_req.rw = 1;
        cpu_req.data = 32'h89ABCDEF;
        cpu_req.addr = 32'h80004008;
        ##10;
        cpu_req.valid = 0;
        ##100;

        // Test case 5: Write-back
        cpu_req.valid = 1;
        cpu_req.rw = 0;
        cpu_req.data = 0;
        cpu_req.addr = 32'h80004000;
        ##10;
        cpu_req.valid = 0;
        ##100;
    end

endmodule
