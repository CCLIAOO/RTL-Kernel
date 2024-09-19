// This is just the behavioral model of "sram in asic" and "bram or uram in fpga" =>
// replace this module when needed. 
// This module could only be synthesized in vivado flow. Not ASIC!!

module single_port_ram #(
    parameter cycle = 1.0   ,       // for behavioral simulation use
    parameter width = 512   ,
    parameter depth = 4096
) (
    input                                   clk             ,
    input           [ $clog2(depth)-1:0 ]   addr            ,
    input                                   write_enable    ,   // 1: write, 0: read
    input           [        width-1:0  ]   D               ,
    output logic    [        width-1:0  ]   Q           
);

// (* ram_style = "auto" *) logic [width-1:0] mem [0:depth-1];
logic [width-1:0] mem [0:depth-1];

always @(posedge clk) begin
    if (write_enable) 
        mem[addr] <= D  ;
end

always @(posedge clk) begin
    Q = 'hx;
    Q = #(cycle / 2.0) mem[addr];
end

endmodule



module two_port_ram #(
    parameter cycle = 1.0   ,       // for behavioral simulation use
    parameter width = 512   ,
    parameter depth = 4096
) (
    input                                   clk             ,
    input           [ $clog2(depth)-1:0 ]   waddr           ,
    input                                   write_enable    ,
    input           [ $clog2(depth)-1:0 ]   raddr           ,
    input                                   read_enable     ,
    input           [        width-1:0  ]   D               ,
    output logic    [        width-1:0  ]   Q           
);

// (* ram_style = "auto" *) logic [width-1:0] mem [0:depth-1];
logic [width-1:0] mem [0:depth-1];

always @(posedge clk) begin
    if (write_enable) 
        mem[waddr] <= D  ;
end

always @(posedge clk) begin
    if (read_enable) begin
        Q = 'hx;
        Q = #(cycle / 2.0) mem[raddr];
    end
end

endmodule