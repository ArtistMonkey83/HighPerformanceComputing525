module test_dm_cache_fsm;

    // Test inputs
    logic clk;
    logic rst;
    logic [31:0] cpu_req_addr;
    logic [31:0] cpu_req_data;
    logic cpu_req_rw;
    logic cpu_req_valid;
    logic mem_data_ready;
    logic [127:0] mem_data;
    
    // Test outputs
    logic [31:0] mem_req_addr;
    logic [127:0] mem_req_data;
    logic mem_req_rw;
    logic mem_req_valid;
    logic [31:0] cpu_res_data;
    logic cpu_res_ready;
    
    // Instantiate the DUT
    dm_cache_fsm dut (
        .clk(clk),
        .rst(rst),
        .cpu_req({.addr(cpu_req_addr), .data(cpu_req_data), .rw(cpu_req_rw), .valid(cpu_req_valid)}),
        .mem_data({.data(mem_data), .ready(mem_data_ready)}),
        .mem_req({.addr(mem_req_addr), .data(mem_req_data), .rw(mem_req_rw), .valid(mem_req_valid)}),
        .cpu_res({.data(cpu_res_data), .ready(cpu_res_ready)})
    );
    
    // Clock generator
    always #5 clk = ~clk;

    // Reset generator
    initial begin
        rst = 1;
        #10;
        rst = 0;
    end
    
    // Test scenario
    initial begin
        // Wait for the FSM to be in idle state
        while (dut.vstate != dut.idle) begin
            #1;
        end
        
        // Make a CPU request
        cpu_req_addr = 32'h12345678;
        cpu_req_data = 32'hdeadbeef;
        cpu_req_rw = 1;
        cpu_req_valid = 1;
        #1;
        cpu_req_valid = 0;
        
        // Wait for the FSM to transition to compare_tag state
        while (dut.vstate != dut.compare_tag) begin
            #1;
        end
        
        // Make the memory response available
        mem_data = 128'h112233445566778899aabbccddeeff;
        mem_data_ready = 1;
        #1;
        mem_data_ready = 0;
        
        // Wait for the FSM to return to idle state
        while (dut.vstate != dut.idle) begin
            #1;
        end
        
        // Check the CPU result
        if (dut.cpu_res.data !== 32'h11223344) begin
            $error("Unexpected CPU result");
        end
        if (!dut.cpu_res.ready) begin
            $error("CPU result not ready");
        end
    end
endmodule
