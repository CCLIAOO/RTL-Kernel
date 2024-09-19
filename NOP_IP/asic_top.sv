// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : asic_top.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-07-01   Lyu-Ming Ho     
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// -----------------------------------------------------------------------------

`include "ram.sv"
`include "fifo.sv"
`include "controller.sv"
`include "instructionQueue.sv"
`include "vectorEngine.sv"
`include "accumulator.sv"
//`include "highPrecEngine.sv"
// `include "UniActivation.sv"
`include "core.sv"
`include "read_bridge.sv"
`include "write_bridge.sv"


module asic_top #(
    parameter NUM_BRDG              = 32    ,
    parameter C_M_AXI_ADDR_WIDTH    = 64    ,
    parameter C_M_AXI_DATA_WIDTH    = 512
) (
    input  logic                                            clk                 ,
    input  logic                                            resetn              ,

    // AXI4 master interface would be connected to actual HBM
    output logic [NUM_BRDG-1:0]                             maxi_awvalid        ,   //
    input  logic [NUM_BRDG-1:0]                             maxi_awready        ,   //
    output logic [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]     maxi_awaddr         ,   //
    output logic [NUM_BRDG-1:0][8-1:0]                      maxi_awlen          ,   //
    output logic [NUM_BRDG-1:0]                             maxi_wvalid         ,   //
    input  logic [NUM_BRDG-1:0]                             maxi_wready         ,   //
    output logic [NUM_BRDG-1:0][C_M_AXI_DATA_WIDTH-1:0]     maxi_wdata          ,   //
    output logic [NUM_BRDG-1:0][C_M_AXI_DATA_WIDTH/8-1:0]   maxi_wstrb          ,   // no use
    output logic [NUM_BRDG-1:0]                             maxi_wlast          ,   //
    input  logic [NUM_BRDG-1:0]                             maxi_bvalid         ,   // no use
    output logic [NUM_BRDG-1:0]                             maxi_bready         ,   // no use
    output logic [NUM_BRDG-1:0]                             maxi_arvalid        ,   //
    input  logic [NUM_BRDG-1:0]                             maxi_arready        ,   //
    output logic [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]     maxi_araddr         ,   //
    output logic [NUM_BRDG-1:0][8-1:0]                      maxi_arlen          ,   //
    input  logic [NUM_BRDG-1:0]                             maxi_rvalid         ,   //
    output logic [NUM_BRDG-1:0]                             maxi_rready         ,   //
    input  logic [NUM_BRDG-1:0][C_M_AXI_DATA_WIDTH-1:0]     maxi_rdata          ,   //
    input  logic [NUM_BRDG-1:0]                             maxi_rlast          ,   //

    // Slave Control Signals
    input  logic                                            user_start          ,
    output logic                                            user_idle           ,
    output logic                                            user_done           ,
    output logic                                            user_ready          ,

    input logic [32-1:0]                                    instruction_base    ,   // fixme need to check bit num
    input logic [32-1:0]                                    instruction_num     ,
    input logic [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]      hbm_read_base_addr  ,
    input logic [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]      hbm_write_base_addr
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------
localparam ADDR_WIDTH = C_M_AXI_ADDR_WIDTH;
localparam DATA_WIDTH = C_M_AXI_DATA_WIDTH;
localparam NUM_R_BRDG = 32;
localparam NUM_W_BRDG = 16;


/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////

// instructionQueue
logic                               instruction_ready;
logic                               instruction_valid;
logic [ C_M_AXI_DATA_WIDTH-1:0 ]    instruction;
logic                               instQ_arvalid;
logic [ C_M_AXI_ADDR_WIDTH-1:0 ]    instQ_araddr;
logic [                  8-1:0 ]    instQ_arlen;
logic                               instQ_arready;
logic                               instQ_rvalid; 
logic [ C_M_AXI_DATA_WIDTH-1:0 ]    instQ_rdata;
logic                               instQ_rlast;
logic                               instQ_rready;

// core: llama batch [0]
logic                                                    ctrl_arvalid   ;
logic [ ADDR_WIDTH-1:0 ]                                 ctrl_araddr    ;
logic [          8-1:0 ]                                 ctrl_arlen     ;
logic                                                    ctrl_arready   ;
logic                                                    ctrl_rvalid    ;
logic [NUM_R_BRDG-1:0][DATA_WIDTH-1:0]                   ctrl_rdata     ;
logic                                                    ctrl_rlast     ;
logic                                                    ctrl_awvalid   ;
logic [ ADDR_WIDTH-1:0 ]                                 ctrl_awaddr    ;
logic [          8-1:0 ]                                 ctrl_awlen     ;
logic                                                    ctrl_awready   ;
logic                                                    ctrl_wvalid    ;
logic [NUM_W_BRDG-1:0][DATA_WIDTH-1:0]                   ctrl_wdata     ;
logic                                                    ctrl_wready    ;



/////////////////////////////////////////////////////////////////////////
// Macro Instantiations
/////////////////////////////////////////////////////////////////////////

instructionQueue u_instructionQueue (
    .clk                ( clk    ),
    .resetn             ( resetn ),

    .axi_arvalid        (instQ_arvalid),
    .axi_araddr         (instQ_araddr),
    .axi_arlen          (instQ_arlen),
    .axi_arready        (instQ_arready),

    .axi_rvalid         (instQ_rvalid),
    .axi_rdata          (instQ_rdata),
    .axi_rlast          (instQ_rlast),
    .axi_rready         (instQ_rready),

    .instruction_base   (instruction_base),
    .instruction_num    (instruction_num),
    .user_start         (user_start),
    .user_done          (user_done),
    .user_idle          (user_idle),

    .accelerator_busy   (), // no use for now

    .instruction_ready  (instruction_ready),        // shoudld be batch0_instruction_ready && batch1_instruction_ready then
    .instruction_valid  (instruction_valid),
    .instruction        (instruction)               // 512 bit
);

read_bridge axi_read_bridge (
    .clk                ( clk    ),
    .resetn             ( resetn ),

    .instQ_arvalid      (instQ_arvalid),
    .instQ_araddr       (instQ_araddr),
    .instQ_arlen        (instQ_arlen),
    .instQ_arready      (instQ_arready),
    .instQ_rvalid       (instQ_rvalid),
    .instQ_rdata        (instQ_rdata),
    .instQ_rlast        (instQ_rlast),
    .instQ_rready       (instQ_rready),

    .ctrl_arvalid       (ctrl_arvalid),
    .ctrl_araddr        (ctrl_araddr),
    .ctrl_arlen         (ctrl_arlen),
    .ctrl_arready       (ctrl_arready),
    .ctrl_rvalid        (ctrl_rvalid),
    .ctrl_rdata         (ctrl_rdata),
    .ctrl_rlast         (ctrl_rlast),

    .arvalid            (maxi_arvalid),
    .araddr             (maxi_araddr),
    .arlen              (maxi_arlen),
    .arready            (maxi_arready),
    .rvalid             (maxi_rvalid),
    .rdata              (maxi_rdata),
    .rlast              (maxi_rlast),
    .rready             (maxi_rready),

    .read_base_addr     (hbm_read_base_addr)
);

core core_0 (
    .clk                ( clk    ),
    .resetn             ( resetn ),

    .instruction        ( instruction[255:0]    ),  // 256 bit
    .instruction_valid  ( instruction_valid     ),
    .instruction_ready  ( instruction_ready     ),

    // 32 pairs combined AXI4 master "read" interface, will be connected to "read_bridge"
    .ctrl_arvalid       (ctrl_arvalid),
    .ctrl_araddr        (ctrl_araddr),
    .ctrl_arlen         (ctrl_arlen),
    .ctrl_arready       (ctrl_arready),
    .ctrl_rvalid        (ctrl_rvalid),
    .ctrl_rdata         (ctrl_rdata),
    .ctrl_rlast         (ctrl_rlast),

    // 16 pairs of AXI4 master "write" interface, will be connected to "write_bridge"
    .ctrl_awvalid       (ctrl_awvalid),
    .ctrl_awaddr        (ctrl_awaddr),
    .ctrl_awlen         (ctrl_awlen),
    .ctrl_awready       (ctrl_awready),
    .ctrl_wvalid        (ctrl_wvalid),
    .ctrl_wdata         (ctrl_wdata),
    .ctrl_wready        (ctrl_wready)
);

write_bridge axi_write_bridge_0 (
    .clk                ( clk    ),
    .resetn             ( resetn ),

    .ctrl_awvalid       (ctrl_awvalid),
    .ctrl_awaddr        (ctrl_awaddr),
    .ctrl_awlen         (ctrl_awlen),
    .ctrl_awready       (ctrl_awready),
    .ctrl_wvalid        (ctrl_wvalid),
    .ctrl_wdata         (ctrl_wdata),
    .ctrl_wready        (ctrl_wready),

    .awvalid            (maxi_awvalid[15:0]),
    .awaddr             (maxi_awaddr[15:0]),
    .awlen              (maxi_awlen[15:0]),
    .awready            (maxi_awready[15:0]),
    .wvalid             (maxi_wvalid[15:0]),
    .wdata              (maxi_wdata[15:0]),
    .wlast              (maxi_wlast[15:0]),
    .wready             (maxi_wready[15:0]),

    .write_base_addr    (hbm_write_base_addr[15:0])
);

// core 2

// write bridge 2

/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

assign user_ready = user_idle;
//------------------------ axi connections ------------------------


//------------------------ control registers ------------------------


endmodule
