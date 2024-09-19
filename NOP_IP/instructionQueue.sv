// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : instructionQueue.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-06-14   Lyu-Ming Ho     area without dual port ram inside,    2625.436776       0.8
//                                      num_instQ should think carefully
//                                      again.
//
// 1.0.1   2024-07-21                   area with real sram inside,           265055.342063
//                                      functionality remain the same.
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// instructionQueue (instruction fifo) with axi4 interface
// -----------------------------------------------------------------------------

 `include "ram.sv"
//`include "lm_mem_2p_512x512b.sv"

module instructionQueue #(
    parameter cycle = 3.0           ,
    parameter width = 512           ,
    parameter depth = 512           ,

    parameter AXI_ADDR_WIDTH = 64   ,
    parameter AXI_DATA_WIDTH = 512
) (
    input  logic                            clk     ,
    input  logic                            resetn  ,
    
    // Channel: address read
    output logic                            axi_arvalid  ,
    output logic [ AXI_ADDR_WIDTH  -1:0 ]   axi_araddr   ,
    output logic [                  7:0 ]   axi_arlen    ,
    input  logic                            axi_arready  ,

    // Channel: read data
    input  logic                            axi_rvalid   ,
    input  logic [ AXI_DATA_WIDTH  -1:0 ]   axi_rdata    ,
    input  logic                            axi_rlast    ,
    output logic                            axi_rready   ,

    // Control from Slave Registers
    input  logic [                 31:0 ]   instruction_base,   // base address of instruction in dram
    input  logic [                 31:0 ]   instruction_num ,   // total number of instructions
    input  logic                            user_start      ,
    output logic                            user_done       ,
    output logic                            user_idle       ,

    input  logic                            accelerator_busy,   // indicates that "CORE" is using the axi channel, so don't use axi channel when (accelerator_busy == 1)

    // instructionQueue connection to "CORE" design
    input  logic                            instruction_ready,
    output logic                            instruction_valid,
    output logic [            width-1:0 ]   instruction      
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////
typedef enum logic [2:0] { IDLE, EXE, DONE }        KRNL_STATE;
typedef enum logic [2:0] { FIDLE, FREAD, FOUT }     FIFO_STATE;
typedef enum logic [2:0] { RIDLE, RADDR, RDATA }    AXI_STATE;

//------------------------- Overall Config -------------------------

//------------------------- operation Type ------------------------- 

//--------------------------- fifo param ---------------------------
localparam  ASIZE = $clog2(depth);


/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////
KRNL_STATE krnl_state, krnl_nstate;
FIFO_STATE fifo_state, fifo_nstate;
AXI_STATE  axi_state, axi_nstate;

// axi related
logic ar_hs, r_hs;

logic [31:0]    core_read_inst_num;
logic [31:0]    axi_read_inst_num;
logic [31:0]    inst_offset;            // assume maximum instruction cost 2^31 byte
logic [31:0]    remain_inst;

// fifo controls
logic                            write_enable    ;   // 1: write
logic    [ $clog2(depth)-1:0 ]   waddr           ;
logic                            read_enable     ;   // 1: read
logic    [ $clog2(depth)-1:0 ]   raddr           ;
logic    [        width-1:0  ]   D               ;
logic    [        width-1:0  ]   Q               ;

logic [ ASIZE  :0 ]   rptr, n_rptr;
logic [ ASIZE  :0 ]   wptr, n_wptr;
logic [ ASIZE-1:0 ]   n_raddr;
logic [ ASIZE-1:0 ]   n_waddr;

logic                 winc  ;
logic                 wfull ;

logic                 rinc  ;
logic                 rempty;
logic                 rvalid;

logic [ $clog2(depth)-1:0 ] num_instQ;


/////////////////////////////////////////////////////////////////////////
// Macro instance
/////////////////////////////////////////////////////////////////////////

// behavioral dual port ram (for FPGA)
 two_port_ram #(.cycle(cycle), .width(width), .depth(depth)) ram (
     .clk            ( clk           ),
     .waddr          ( waddr         ),
     .raddr          ( raddr         ),
     .write_enable   ( write_enable  ),
     .read_enable    ( read_enable   ),
     .D              ( D             ),
     .Q              ( Q             )
 );

// real sram (for ASIC)
//lm_mem_2p_512x512b ram (
//    .CLK    ( clk           ),

//    // read port
//    .CENA   ( ~read_enable  ), // CENA: 0: read, 1: don't read
//    .AA     ( raddr         ),
//    .QA     ( Q             ),

//    // write port
//    .CENB   ( ~write_enable ), // CENB: 0: write, 1: don't write
//    .AB     ( waddr         ),
//    .DB     ( D             )
//);

/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

// AXI related
assign ar_hs    = axi_arvalid & axi_arready;
assign r_hs     = axi_rvalid  & axi_rready;

always @(*) begin
    case (axi_state)
        RIDLE:  axi_nstate = (krnl_state == EXE && axi_read_inst_num != instruction_num && (depth-num_instQ) >= 256) ? RADDR : RIDLE;        // prefetch when instructionQueue.size can accommodate next 256 values
        RADDR:  axi_nstate = (ar_hs)            ? RDATA : RADDR;
        RDATA:  axi_nstate = (axi_rlast & r_hs) ? RIDLE : RDATA;
        default:axi_nstate = axi_state;
    endcase
end

always @(posedge clk or negedge resetn) begin
    if (!resetn)    axi_state <= RIDLE;
    else            axi_state <= axi_nstate;
end

always @(*) begin
    remain_inst = instruction_num - axi_read_inst_num;
    axi_arvalid = (axi_state == RADDR);
    axi_araddr  = instruction_base + inst_offset;
    axi_arlen   = (remain_inst > 256) ? 255 : remain_inst - 1;
    axi_rready  = (axi_state == RDATA);
end

always @(posedge clk or negedge resetn) begin
    if (!resetn)    inst_offset <= 0;
    else begin
        if (krnl_state == IDLE)
            inst_offset <= 0;
        else if (ar_hs)
            inst_offset <= inst_offset + (AXI_DATA_WIDTH / 8 * 256);    // byte offset, (512/8) (byte/cycle) * burst_length
    end
end

// number of instruction in instructionQueue (Should think carefully here)
always @(*) begin
    if (wptr[ASIZE] == rptr[ASIZE])                         // same circle
        num_instQ = waddr - raddr;
    else                                                    // not the same circle
        num_instQ = {1'b1, waddr} - {1'b0, raddr};
end

// fifo address
always @(*) begin
    waddr = wptr[ASIZE-1:0];
    raddr = rptr[ASIZE-1:0];
end


always @(*) begin
    case (fifo_state)
        FIDLE:  fifo_nstate = (instruction_ready && ~rempty) ? FREAD : FIDLE;
        FREAD:  fifo_nstate = FOUT;
        FOUT :  fifo_nstate = FIDLE;
        default:fifo_nstate = fifo_state;
    endcase
end

always @(posedge clk or negedge resetn) begin
    if (!resetn)    fifo_state <= FIDLE;
    else            fifo_state <= fifo_nstate;
end

// connection
always @(*) begin
    instruction_valid   = (fifo_state == FOUT);
    instruction         = Q;
    D                   = axi_rdata;
end

// fifo read
always @(*) begin
    rinc        = (fifo_state == FREAD); 
    read_enable = (rinc & ~rempty);     // read will only be successful when (instruciton_ready & instructionQueue not empty)
    n_rptr      = rptr + read_enable;
end

always @(posedge clk or negedge resetn) begin
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

// fifo write
always @(*) begin
    winc            = r_hs;                 // write fifo when axi handshake
    write_enable    = (winc & ~wfull);      // 1 means write, 0 means don't write
    n_wptr          = wptr + write_enable;
end

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        wptr    <= 0;
        wfull   <= 0;
    end
    else begin
        wptr    <= n_wptr;
        wfull   <= (n_wptr[ASIZE] == ~rptr[ASIZE]) && (n_wptr[ASIZE-1:0] == rptr[ASIZE-1:0]);
    end
end


// kernel
always @(*) begin
    case (krnl_state)
        IDLE:   krnl_nstate = (user_start)                                                              ? EXE   : IDLE;
        EXE :   krnl_nstate = (instruction_ready && core_read_inst_num == instruction_num && rempty)    ? DONE  : EXE;  // when "CORE" is ready to process next instruction but "CORE" has already processed $(instruction_num) number of instructions.
        DONE:   krnl_nstate = IDLE;
        default:krnl_nstate = krnl_state;
    endcase
end

always @(posedge clk or negedge resetn) begin
    if (!resetn)    krnl_state <= IDLE;
    else            krnl_state <= krnl_nstate;
end

assign user_done = (krnl_state == DONE);
assign user_idle = (krnl_state == IDLE);

// instruction calculation
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        core_read_inst_num <= 0;
    end
    else begin
        if (user_done)
            core_read_inst_num <= 0;
        else if (instruction_valid & instruction_ready)
            core_read_inst_num <= core_read_inst_num + 1;
    end
end

always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        axi_read_inst_num <= 0;
    end
    else begin
        if (user_done) 
            axi_read_inst_num <= 0;
        else if (r_hs)
            axi_read_inst_num <= axi_read_inst_num + 1;
    end
end

endmodule