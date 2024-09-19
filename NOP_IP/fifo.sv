// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : fifo.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          VERSION     DESCRIPTION                             SYN_AREA        SYN_CLK_PERIOD
// 1.0     2024-07-21   Lyu-Ming Ho     v1.0        create this file
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// Provides 2 kinds of fifo
// No.1: Standard fifo, data comes in next cycle after being requested.                 (lmho_fifo_std)
// No.2: First-Word-Fall-Through fifo, data comes in same cycle in which it's requested (lmho_fifo_fwft)
// -----------------------------------------------------------------------------



///////////////////////////////////////////////////////////////////////////////////////////////////////////
// The standard read mode provides the user data on the cycle after it was requested.
///////////////////////////////////////////////////////////////////////////////////////////////////////////
module lmho_fifo_std #(WIDTH=512, WORDS=4) (
    input                           clk,
    input                           resetn,
    input                           winc,
    input           [WIDTH-1:0]     wdata,
    output reg                      wfull,

    input                           rinc,
    output reg      [WIDTH-1:0]     rdata,
    output reg                      rempty,
    output reg                      rvalid
);

localparam      ASIZE = $clog2(WORDS);
reg [ASIZE:0]   rptr, n_rptr;
reg [ASIZE:0]   wptr, n_wptr;
reg [ASIZE-1:0] raddr, n_raddr;
reg [ASIZE-1:0] waddr, n_waddr;
reg             write_enable;
reg             read_enable;

// Memory (could use bram instead)
reg [WIDTH-1:0] mem [0:WORDS-1];
always @(posedge clk) begin
    if (write_enable)
        mem[waddr] <= wdata;
end

// address
always @(*) begin
    waddr = wptr[ASIZE-1:0];
    raddr = rptr[ASIZE-1:0];
end

// read
always @(*) begin
    read_enable = (rinc & ~rempty);
    n_rptr      = rptr + read_enable;
end

always @(posedge clk, negedge resetn) begin
    if (!resetn) begin
        rptr    <= 0; 
        rdata   <= 0;
        rvalid  <= 0;
        rempty  <= 1;
    end 
    else begin
        rptr    <= n_rptr;
        rdata   <= mem[raddr];
        rvalid  <= read_enable;
        rempty  <= (n_rptr == wptr);        // next pointer where i'm gonna read == next pointer where i'm gonna write 
    end
end

// write
always @(*) begin
    write_enable    = (winc & ~wfull);      // 1 means write, 0 means don't write
    n_wptr          = wptr + write_enable;
end

always @(posedge clk, negedge resetn) begin
    if (!resetn) begin
        wptr    <= 0;
        wfull   <= 0;
    end
    else begin
        wptr    <= n_wptr;
        wfull   <= (n_wptr[ASIZE] == ~rptr[ASIZE]) && (n_wptr[ASIZE-1:0] == rptr[ASIZE-1:0]);
    end
end

endmodule




///////////////////////////////////////////////////////////////////////////////////////////////////////////
// The First-Word-Fall-Through read mode provides the user data on the same cycle in which it is requested.
///////////////////////////////////////////////////////////////////////////////////////////////////////////
module lmho_fifo_fwft #(WIDTH=512, WORDS=4) (
    input                           clk,
    input                           resetn,
    input                           winc,
    input           [WIDTH-1:0]     wdata,
    output reg                      wfull,

    input                           rinc,
    output reg      [WIDTH-1:0]     rdata,
    output reg                      rempty,
    output reg                      rvalid
);

localparam      ASIZE = $clog2(WORDS);
reg [ASIZE:0]   rptr, n_rptr;
reg [ASIZE:0]   wptr, n_wptr;
reg [ASIZE-1:0] raddr, n_raddr;
reg [ASIZE-1:0] waddr, n_waddr;
reg             write_enable;
reg             read_enable;

// Memory (could use bram instead)
reg [WIDTH-1:0] mem [0:WORDS-1];
always @(posedge clk) begin
    if (write_enable)
        mem[waddr] <= wdata;
end

// address
always @(*) begin
    waddr = wptr[ASIZE-1:0];
    raddr = rptr[ASIZE-1:0];
end

// read
always @(*) begin
    read_enable = (rinc & ~rempty);
    n_rptr      = rptr + read_enable;
end

always @(posedge clk, negedge resetn) begin
    if (!resetn) begin
        rptr    <= 0; 
        rvalid  <= 0;
        rempty  <= 1;
    end 
    else begin
        rptr    <= n_rptr;
        rvalid  <= read_enable;
        rempty  <= (n_rptr == wptr);        // next pointer where i'm gonna read == next pointer where i'm gonna write 
    end
end

assign rdata = mem[raddr];

// write
always @(*) begin
    write_enable    = (winc & ~wfull);      // 1 means write, 0 means don't write
    n_wptr          = wptr + write_enable;
end

always @(posedge clk, negedge resetn) begin
    if (!resetn) begin
        wptr    <= 0;
        wfull   <= 0;
    end
    else begin
        wptr    <= n_wptr;
        wfull   <= (n_wptr[ASIZE] == ~rptr[ASIZE]) && (n_wptr[ASIZE-1:0] == rptr[ASIZE-1:0]);
    end
end

endmodule