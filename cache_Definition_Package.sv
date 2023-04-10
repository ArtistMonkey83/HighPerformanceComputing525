package cache_def;
// Data structures for cache tag and Data Slide 66

parameter int TAGMSB = 31; // Tag most significant bit
parameter int TAGLSB = 14; // Tag least significant bit

// Data structure for cache tag
typedef struct packed {
  bit valid;               // Valid bit
  bit dirty;               // Dirty bit
  bit [TAGMSB:TAGLSB]tag;  // Tag bits
}cache_tag_type;

// Data structure for cache memory request
typedef struct {
  bit [9:0]index;         // 10-bit index
  bit we;                 // Write/Enable bit
}cache_req_type;

// 128-bit cach line data
typedef bit [127:0]cache_data_type;

// Data structures for CPU <-> Cache Controller interface Slide 67

// CPU request (CPU -> Cache controller)
typedef struct {
    bit [31:0]addr;    // 32-bit request address
    bit[31:0]data;     // 32-bit request data, used for writing
    bit rw;            // Request type 0 == Read, 1 == Write
    bit valid;         // Request is valid
}cpu_req_type;

// Cache result (Cache Controller -> CPU)
typedef struct {
    bit [31:0]data;   // 32-bit data
    bit ready;        // The result is ready
}cpu_result_type;

// Data structure for Cache Controller <-> Memory Interface Slide 68

// Memory request (Cache Controller -> Memory)
typedef struct{
    bit[31:0]addr;     // Request byte address
    bit[127:0]data;    // 128-bit request data, used for writing
    bit rw;            // Request type 0 == Read, 1 == Write
    bit valid;         // Request is valid
}mem_req_type;

// Memory Controller response (Memory -> Cache Controller)
typedef struct{
    cache_data_type data;   // 128-bit read back data
    bit ready;              // The data is ready
}mem_data_type;

endpackage
