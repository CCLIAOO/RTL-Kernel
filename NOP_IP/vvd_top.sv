// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : vvd_top.sv (vivado top)
// AUTHOR       : Cheng-Chia Liao
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-09-12   Cheng-Chia Liao   
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// -----------------------------------------------------------------------------


`include "control_s_axi.sv"
`include "asic_top.sv"



module vvd_top#(
    parameter   NUM_BRDG                = 32    ,
    parameter   C_M_AXI_ADDR_WIDTH      = 64    ,   // for ASIC top
    parameter   C_M_AXI_DATA_WIDTH      = 512   ,   // for ASIC top
    parameter   C_S_AXI_ADDR_WIDTH      = 12    ,   // for control_s_axi
    parameter   C_S_AXI_DATA_WIDTH      = 32        // for control_s_axi
)(

// System Signals
    input                                          ap_clk               ,
    input                                          ap_resetn            ,
    // AXI4 master interface m00_axi
    output logic                                   m00_axi_awvalid      ,
    input                                          m00_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m00_axi_awaddr       ,
    output logic [8-1:0]                           m00_axi_awlen        ,
    output logic                                   m00_axi_wvalid       ,
    input                                          m00_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m00_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m00_axi_wstrb        ,
    output logic                                   m00_axi_wlast        ,
    input                                          m00_axi_bvalid       ,
    output logic                                   m00_axi_bready       ,
    output logic                                   m00_axi_arvalid      ,
    input                                          m00_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m00_axi_araddr       ,
    output logic [8-1:0]                           m00_axi_arlen        ,
    input                                          m00_axi_rvalid       ,
    output logic                                   m00_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m00_axi_rdata        ,
    input                                          m00_axi_rlast        ,

    // AXI4 master interface m01_axi
    output logic                                   m01_axi_awvalid      ,
    input                                          m01_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m01_axi_awaddr       ,
    output logic [8-1:0]                           m01_axi_awlen        ,
    output logic                                   m01_axi_wvalid       ,
    input                                          m01_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m01_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m01_axi_wstrb        ,
    output logic                                   m01_axi_wlast        ,
    input                                          m01_axi_bvalid       ,
    output logic                                   m01_axi_bready       ,
    output logic                                   m01_axi_arvalid      ,
    input                                          m01_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m01_axi_araddr       ,
    output logic [8-1:0]                           m01_axi_arlen        ,
    input                                          m01_axi_rvalid       ,
    output logic                                   m01_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m01_axi_rdata        ,
    input                                          m01_axi_rlast        ,

    // AXI4 master interface m02_axi
    output logic                                   m02_axi_awvalid      ,
    input                                          m02_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m02_axi_awaddr       ,
    output logic [8-1:0]                           m02_axi_awlen        ,
    output logic                                   m02_axi_wvalid       ,
    input                                          m02_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m02_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m02_axi_wstrb        ,
    output logic                                   m02_axi_wlast        ,
    input                                          m02_axi_bvalid       ,
    output logic                                   m02_axi_bready       ,
    output logic                                   m02_axi_arvalid      ,
    input                                          m02_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m02_axi_araddr       ,
    output logic [8-1:0]                           m02_axi_arlen        ,
    input                                          m02_axi_rvalid       ,
    output logic                                   m02_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m02_axi_rdata        ,
    input                                          m02_axi_rlast        ,

    // AXI4 master interface m03_axi
    output logic                                   m03_axi_awvalid      ,
    input                                          m03_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m03_axi_awaddr       ,
    output logic [8-1:0]                           m03_axi_awlen        ,
    output logic                                   m03_axi_wvalid       ,
    input                                          m03_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m03_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m03_axi_wstrb        ,
    output logic                                   m03_axi_wlast        ,
    input                                          m03_axi_bvalid       ,
    output logic                                   m03_axi_bready       ,
    output logic                                   m03_axi_arvalid      ,
    input                                          m03_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m03_axi_araddr       ,
    output logic [8-1:0]                           m03_axi_arlen        ,
    input                                          m03_axi_rvalid       ,
    output logic                                   m03_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m03_axi_rdata        ,
    input                                          m03_axi_rlast        ,

    // AXI4 master interface m04_axi
    output logic                                   m04_axi_awvalid      ,
    input                                          m04_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m04_axi_awaddr       ,
    output logic [8-1:0]                           m04_axi_awlen        ,
    output logic                                   m04_axi_wvalid       ,
    input                                          m04_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m04_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m04_axi_wstrb        ,
    output logic                                   m04_axi_wlast        ,
    input                                          m04_axi_bvalid       ,
    output logic                                   m04_axi_bready       ,
    output logic                                   m04_axi_arvalid      ,
    input                                          m04_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m04_axi_araddr       ,
    output logic [8-1:0]                           m04_axi_arlen        ,
    input                                          m04_axi_rvalid       ,
    output logic                                   m04_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m04_axi_rdata        ,
    input                                          m04_axi_rlast        ,

    // AXI4 master interface m05_axi
    output logic                                   m05_axi_awvalid      ,
    input                                          m05_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m05_axi_awaddr       ,
    output logic [8-1:0]                           m05_axi_awlen        ,
    output logic                                   m05_axi_wvalid       ,
    input                                          m05_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m05_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m05_axi_wstrb        ,
    output logic                                   m05_axi_wlast        ,
    input                                          m05_axi_bvalid       ,
    output logic                                   m05_axi_bready       ,
    output logic                                   m05_axi_arvalid      ,
    input                                          m05_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m05_axi_araddr       ,
    output logic [8-1:0]                           m05_axi_arlen        ,
    input                                          m05_axi_rvalid       ,
    output logic                                   m05_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m05_axi_rdata        ,
    input                                          m05_axi_rlast        ,

    // AXI4 master interface m06_axi
    output logic                                   m06_axi_awvalid      ,
    input                                          m06_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m06_axi_awaddr       ,
    output logic [8-1:0]                           m06_axi_awlen        ,
    output logic                                   m06_axi_wvalid       ,
    input                                          m06_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m06_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m06_axi_wstrb        ,
    output logic                                   m06_axi_wlast        ,
    input                                          m06_axi_bvalid       ,
    output logic                                   m06_axi_bready       ,
    output logic                                   m06_axi_arvalid      ,
    input                                          m06_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m06_axi_araddr       ,
    output logic [8-1:0]                           m06_axi_arlen        ,
    input                                          m06_axi_rvalid       ,
    output logic                                   m06_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m06_axi_rdata        ,
    input                                          m06_axi_rlast        ,

    // AXI4 master interface m07_axi
    output logic                                   m07_axi_awvalid      ,
    input                                          m07_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m07_axi_awaddr       ,
    output logic [8-1:0]                           m07_axi_awlen        ,
    output logic                                   m07_axi_wvalid       ,
    input                                          m07_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m07_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m07_axi_wstrb        ,
    output logic                                   m07_axi_wlast        ,
    input                                          m07_axi_bvalid       ,
    output logic                                   m07_axi_bready       ,
    output logic                                   m07_axi_arvalid      ,
    input                                          m07_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m07_axi_araddr       ,
    output logic [8-1:0]                           m07_axi_arlen        ,
    input                                          m07_axi_rvalid       ,
    output logic                                   m07_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m07_axi_rdata        ,
    input                                          m07_axi_rlast        ,

    // AXI4 master interface m08_axi
    output logic                                   m08_axi_awvalid      ,
    input                                          m08_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m08_axi_awaddr       ,
    output logic [8-1:0]                           m08_axi_awlen        ,
    output logic                                   m08_axi_wvalid       ,
    input                                          m08_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m08_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m08_axi_wstrb        ,
    output logic                                   m08_axi_wlast        ,
    input                                          m08_axi_bvalid       ,
    output logic                                   m08_axi_bready       ,
    output logic                                   m08_axi_arvalid      ,
    input                                          m08_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m08_axi_araddr       ,
    output logic [8-1:0]                           m08_axi_arlen        ,
    input                                          m08_axi_rvalid       ,
    output logic                                   m08_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m08_axi_rdata        ,
    input                                          m08_axi_rlast        ,

    // AXI4 master interface m09_axi
    output logic                                   m09_axi_awvalid      ,
    input                                          m09_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m09_axi_awaddr       ,
    output logic [8-1:0]                           m09_axi_awlen        ,
    output logic                                   m09_axi_wvalid       ,
    input                                          m09_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m09_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m09_axi_wstrb        ,
    output logic                                   m09_axi_wlast        ,
    input                                          m09_axi_bvalid       ,
    output logic                                   m09_axi_bready       ,
    output logic                                   m09_axi_arvalid      ,
    input                                          m09_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m09_axi_araddr       ,
    output logic [8-1:0]                           m09_axi_arlen        ,
    input                                          m09_axi_rvalid       ,
    output logic                                   m09_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m09_axi_rdata        ,
    input                                          m09_axi_rlast        ,

    // AXI4 master interface m10_axi
    output logic                                   m10_axi_awvalid      ,
    input                                          m10_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m10_axi_awaddr       ,
    output logic [8-1:0]                           m10_axi_awlen        ,
    output logic                                   m10_axi_wvalid       ,
    input                                          m10_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m10_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m10_axi_wstrb        ,
    output logic                                   m10_axi_wlast        ,
    input                                          m10_axi_bvalid       ,
    output logic                                   m10_axi_bready       ,
    output logic                                   m10_axi_arvalid      ,
    input                                          m10_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m10_axi_araddr       ,
    output logic [8-1:0]                           m10_axi_arlen        ,
    input                                          m10_axi_rvalid       ,
    output logic                                   m10_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m10_axi_rdata        ,
    input                                          m10_axi_rlast        ,

    // AXI4 master interface m11_axi
    output logic                                   m11_axi_awvalid      ,
    input                                          m11_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m11_axi_awaddr       ,
    output logic [8-1:0]                           m11_axi_awlen        ,
    output logic                                   m11_axi_wvalid       ,
    input                                          m11_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m11_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m11_axi_wstrb        ,
    output logic                                   m11_axi_wlast        ,
    input                                          m11_axi_bvalid       ,
    output logic                                   m11_axi_bready       ,
    output logic                                   m11_axi_arvalid      ,
    input                                          m11_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m11_axi_araddr       ,
    output logic [8-1:0]                           m11_axi_arlen        ,
    input                                          m11_axi_rvalid       ,
    output logic                                   m11_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m11_axi_rdata        ,
    input                                          m11_axi_rlast        ,

    // AXI4 master interface m12_axi
    output logic                                   m12_axi_awvalid      ,
    input                                          m12_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m12_axi_awaddr       ,
    output logic [8-1:0]                           m12_axi_awlen        ,
    output logic                                   m12_axi_wvalid       ,
    input                                          m12_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m12_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m12_axi_wstrb        ,
    output logic                                   m12_axi_wlast        ,
    input                                          m12_axi_bvalid       ,
    output logic                                   m12_axi_bready       ,
    output logic                                   m12_axi_arvalid      ,
    input                                          m12_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m12_axi_araddr       ,
    output logic [8-1:0]                           m12_axi_arlen        ,
    input                                          m12_axi_rvalid       ,
    output logic                                   m12_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m12_axi_rdata        ,
    input                                          m12_axi_rlast        ,

    // AXI4 master interface m13_axi
    output logic                                   m13_axi_awvalid      ,
    input                                          m13_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m13_axi_awaddr       ,
    output logic [8-1:0]                           m13_axi_awlen        ,
    output logic                                   m13_axi_wvalid       ,
    input                                          m13_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m13_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m13_axi_wstrb        ,
    output logic                                   m13_axi_wlast        ,
    input                                          m13_axi_bvalid       ,
    output logic                                   m13_axi_bready       ,
    output logic                                   m13_axi_arvalid      ,
    input                                          m13_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m13_axi_araddr       ,
    output logic [8-1:0]                           m13_axi_arlen        ,
    input                                          m13_axi_rvalid       ,
    output logic                                   m13_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m13_axi_rdata        ,
    input                                          m13_axi_rlast        ,

    // AXI4 master interface m14_axi
    output logic                                   m14_axi_awvalid      ,
    input                                          m14_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m14_axi_awaddr       ,
    output logic [8-1:0]                           m14_axi_awlen        ,
    output logic                                   m14_axi_wvalid       ,
    input                                          m14_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m14_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m14_axi_wstrb        ,
    output logic                                   m14_axi_wlast        ,
    input                                          m14_axi_bvalid       ,
    output logic                                   m14_axi_bready       ,
    output logic                                   m14_axi_arvalid      ,
    input                                          m14_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m14_axi_araddr       ,
    output logic [8-1:0]                           m14_axi_arlen        ,
    input                                          m14_axi_rvalid       ,
    output logic                                   m14_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m14_axi_rdata        ,
    input                                          m14_axi_rlast        ,

    // AXI4 master interface m15_axi
    output logic                                   m15_axi_awvalid      ,
    input                                          m15_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m15_axi_awaddr       ,
    output logic [8-1:0]                           m15_axi_awlen        ,
    output logic                                   m15_axi_wvalid       ,
    input                                          m15_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m15_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m15_axi_wstrb        ,
    output logic                                   m15_axi_wlast        ,
    input                                          m15_axi_bvalid       ,
    output logic                                   m15_axi_bready       ,
    output logic                                   m15_axi_arvalid      ,
    input                                          m15_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m15_axi_araddr       ,
    output logic [8-1:0]                           m15_axi_arlen        ,
    input                                          m15_axi_rvalid       ,
    output logic                                   m15_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m15_axi_rdata        ,
    input                                          m15_axi_rlast        ,

    // AXI4 master interface m16_axi
    output logic                                   m16_axi_awvalid      ,
    input                                          m16_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m16_axi_awaddr       ,
    output logic [8-1:0]                           m16_axi_awlen        ,
    output logic                                   m16_axi_wvalid       ,
    input                                          m16_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m16_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m16_axi_wstrb        ,
    output logic                                   m16_axi_wlast        ,
    input                                          m16_axi_bvalid       ,
    output logic                                   m16_axi_bready       ,
    output logic                                   m16_axi_arvalid      ,
    input                                          m16_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m16_axi_araddr       ,
    output logic [8-1:0]                           m16_axi_arlen        ,
    input                                          m16_axi_rvalid       ,
    output logic                                   m16_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m16_axi_rdata        ,
    input                                          m16_axi_rlast        ,

    // AXI4 master interface m17_axi
    output logic                                   m17_axi_awvalid      ,
    input                                          m17_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m17_axi_awaddr       ,
    output logic [8-1:0]                           m17_axi_awlen        ,
    output logic                                   m17_axi_wvalid       ,
    input                                          m17_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m17_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m17_axi_wstrb        ,
    output logic                                   m17_axi_wlast        ,
    input                                          m17_axi_bvalid       ,
    output logic                                   m17_axi_bready       ,
    output logic                                   m17_axi_arvalid      ,
    input                                          m17_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m17_axi_araddr       ,
    output logic [8-1:0]                           m17_axi_arlen        ,
    input                                          m17_axi_rvalid       ,
    output logic                                   m17_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m17_axi_rdata        ,
    input                                          m17_axi_rlast        ,

    // AXI4 master interface m18_axi
    output logic                                   m18_axi_awvalid      ,
    input                                          m18_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m18_axi_awaddr       ,
    output logic [8-1:0]                           m18_axi_awlen        ,
    output logic                                   m18_axi_wvalid       ,
    input                                          m18_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m18_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m18_axi_wstrb        ,
    output logic                                   m18_axi_wlast        ,
    input                                          m18_axi_bvalid       ,
    output logic                                   m18_axi_bready       ,
    output logic                                   m18_axi_arvalid      ,
    input                                          m18_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m18_axi_araddr       ,
    output logic [8-1:0]                           m18_axi_arlen        ,
    input                                          m18_axi_rvalid       ,
    output logic                                   m18_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m18_axi_rdata        ,
    input                                          m18_axi_rlast        ,

    // AXI4 master interface m19_axi
    output logic                                   m19_axi_awvalid      ,
    input                                          m19_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m19_axi_awaddr       ,
    output logic [8-1:0]                           m19_axi_awlen        ,
    output logic                                   m19_axi_wvalid       ,
    input                                          m19_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m19_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m19_axi_wstrb        ,
    output logic                                   m19_axi_wlast        ,
    input                                          m19_axi_bvalid       ,
    output logic                                   m19_axi_bready       ,
    output logic                                   m19_axi_arvalid      ,
    input                                          m19_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m19_axi_araddr       ,
    output logic [8-1:0]                           m19_axi_arlen        ,
    input                                          m19_axi_rvalid       ,
    output logic                                   m19_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m19_axi_rdata        ,
    input                                          m19_axi_rlast        ,

    // AXI4 master interface m20_axi
    output logic                                   m20_axi_awvalid      ,
    input                                          m20_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m20_axi_awaddr       ,
    output logic [8-1:0]                           m20_axi_awlen        ,
    output logic                                   m20_axi_wvalid       ,
    input                                          m20_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m20_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m20_axi_wstrb        ,
    output logic                                   m20_axi_wlast        ,
    input                                          m20_axi_bvalid       ,
    output logic                                   m20_axi_bready       ,
    output logic                                   m20_axi_arvalid      ,
    input                                          m20_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m20_axi_araddr       ,
    output logic [8-1:0]                           m20_axi_arlen        ,
    input                                          m20_axi_rvalid       ,
    output logic                                   m20_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m20_axi_rdata        ,
    input                                          m20_axi_rlast        ,

    // AXI4 master interface m21_axi
    output logic                                   m21_axi_awvalid      ,
    input                                          m21_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m21_axi_awaddr       ,
    output logic [8-1:0]                           m21_axi_awlen        ,
    output logic                                   m21_axi_wvalid       ,
    input                                          m21_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m21_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m21_axi_wstrb        ,
    output logic                                   m21_axi_wlast        ,
    input                                          m21_axi_bvalid       ,
    output logic                                   m21_axi_bready       ,
    output logic                                   m21_axi_arvalid      ,
    input                                          m21_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m21_axi_araddr       ,
    output logic [8-1:0]                           m21_axi_arlen        ,
    input                                          m21_axi_rvalid       ,
    output logic                                   m21_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m21_axi_rdata        ,
    input                                          m21_axi_rlast        ,

    // AXI4 master interface m22_axi
    output logic                                   m22_axi_awvalid      ,
    input                                          m22_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m22_axi_awaddr       ,
    output logic [8-1:0]                           m22_axi_awlen        ,
    output logic                                   m22_axi_wvalid       ,
    input                                          m22_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m22_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m22_axi_wstrb        ,
    output logic                                   m22_axi_wlast        ,
    input                                          m22_axi_bvalid       ,
    output logic                                   m22_axi_bready       ,
    output logic                                   m22_axi_arvalid      ,
    input                                          m22_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m22_axi_araddr       ,
    output logic [8-1:0]                           m22_axi_arlen        ,
    input                                          m22_axi_rvalid       ,
    output logic                                   m22_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m22_axi_rdata        ,
    input                                          m22_axi_rlast        ,

    // AXI4 master interface m23_axi
    output logic                                   m23_axi_awvalid      ,
    input                                          m23_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m23_axi_awaddr       ,
    output logic [8-1:0]                           m23_axi_awlen        ,
    output logic                                   m23_axi_wvalid       ,
    input                                          m23_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m23_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m23_axi_wstrb        ,
    output logic                                   m23_axi_wlast        ,
    input                                          m23_axi_bvalid       ,
    output logic                                   m23_axi_bready       ,
    output logic                                   m23_axi_arvalid      ,
    input                                          m23_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m23_axi_araddr       ,
    output logic [8-1:0]                           m23_axi_arlen        ,
    input                                          m23_axi_rvalid       ,
    output logic                                   m23_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m23_axi_rdata        ,
    input                                          m23_axi_rlast        ,

    // AXI4 master interface m24_axi
    output logic                                   m24_axi_awvalid      ,
    input                                          m24_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m24_axi_awaddr       ,
    output logic [8-1:0]                           m24_axi_awlen        ,
    output logic                                   m24_axi_wvalid       ,
    input                                          m24_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m24_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m24_axi_wstrb        ,
    output logic                                   m24_axi_wlast        ,
    input                                          m24_axi_bvalid       ,
    output logic                                   m24_axi_bready       ,
    output logic                                   m24_axi_arvalid      ,
    input                                          m24_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m24_axi_araddr       ,
    output logic [8-1:0]                           m24_axi_arlen        ,
    input                                          m24_axi_rvalid       ,
    output logic                                   m24_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m24_axi_rdata        ,
    input                                          m24_axi_rlast        ,

    // AXI4 master interface m25_axi
    output logic                                   m25_axi_awvalid      ,
    input                                          m25_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m25_axi_awaddr       ,
    output logic [8-1:0]                           m25_axi_awlen        ,
    output logic                                   m25_axi_wvalid       ,
    input                                          m25_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m25_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m25_axi_wstrb        ,
    output logic                                   m25_axi_wlast        ,
    input                                          m25_axi_bvalid       ,
    output logic                                   m25_axi_bready       ,
    output logic                                   m25_axi_arvalid      ,
    input                                          m25_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m25_axi_araddr       ,
    output logic [8-1:0]                           m25_axi_arlen        ,
    input                                          m25_axi_rvalid       ,
    output logic                                   m25_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m25_axi_rdata        ,
    input                                          m25_axi_rlast        ,

    // AXI4 master interface m26_axi
    output logic                                   m26_axi_awvalid      ,
    input                                          m26_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m26_axi_awaddr       ,
    output logic [8-1:0]                           m26_axi_awlen        ,
    output logic                                   m26_axi_wvalid       ,
    input                                          m26_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m26_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m26_axi_wstrb        ,
    output logic                                   m26_axi_wlast        ,
    input                                          m26_axi_bvalid       ,
    output logic                                   m26_axi_bready       ,
    output logic                                   m26_axi_arvalid      ,
    input                                          m26_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m26_axi_araddr       ,
    output logic [8-1:0]                           m26_axi_arlen        ,
    input                                          m26_axi_rvalid       ,
    output logic                                   m26_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m26_axi_rdata        ,
    input                                          m26_axi_rlast        ,

    // AXI4 master interface m27_axi
    output logic                                   m27_axi_awvalid      ,
    input                                          m27_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m27_axi_awaddr       ,
    output logic [8-1:0]                           m27_axi_awlen        ,
    output logic                                   m27_axi_wvalid       ,
    input                                          m27_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m27_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m27_axi_wstrb        ,
    output logic                                   m27_axi_wlast        ,
    input                                          m27_axi_bvalid       ,
    output logic                                   m27_axi_bready       ,
    output logic                                   m27_axi_arvalid      ,
    input                                          m27_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m27_axi_araddr       ,
    output logic [8-1:0]                           m27_axi_arlen        ,
    input                                          m27_axi_rvalid       ,
    output logic                                   m27_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m27_axi_rdata        ,
    input                                          m27_axi_rlast        ,

    // AXI4 master interface m28_axi
    output logic                                   m28_axi_awvalid      ,
    input                                          m28_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m28_axi_awaddr       ,
    output logic [8-1:0]                           m28_axi_awlen        ,
    output logic                                   m28_axi_wvalid       ,
    input                                          m28_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m28_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m28_axi_wstrb        ,
    output logic                                   m28_axi_wlast        ,
    input                                          m28_axi_bvalid       ,
    output logic                                   m28_axi_bready       ,
    output logic                                   m28_axi_arvalid      ,
    input                                          m28_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m28_axi_araddr       ,
    output logic [8-1:0]                           m28_axi_arlen        ,
    input                                          m28_axi_rvalid       ,
    output logic                                   m28_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m28_axi_rdata        ,
    input                                          m28_axi_rlast        ,

    // AXI4 master interface m29_axi
    output logic                                   m29_axi_awvalid      ,
    input                                          m29_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m29_axi_awaddr       ,
    output logic [8-1:0]                           m29_axi_awlen        ,
    output logic                                   m29_axi_wvalid       ,
    input                                          m29_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m29_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m29_axi_wstrb        ,
    output logic                                   m29_axi_wlast        ,
    input                                          m29_axi_bvalid       ,
    output logic                                   m29_axi_bready       ,
    output logic                                   m29_axi_arvalid      ,
    input                                          m29_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m29_axi_araddr       ,
    output logic [8-1:0]                           m29_axi_arlen        ,
    input                                          m29_axi_rvalid       ,
    output logic                                   m29_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m29_axi_rdata        ,
    input                                          m29_axi_rlast        ,

    // AXI4 master interface m30_axi
    output logic                                   m30_axi_awvalid      ,
    input                                          m30_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m30_axi_awaddr       ,
    output logic [8-1:0]                           m30_axi_awlen        ,
    output logic                                   m30_axi_wvalid       ,
    input                                          m30_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m30_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m30_axi_wstrb        ,
    output logic                                   m30_axi_wlast        ,
    input                                          m30_axi_bvalid       ,
    output logic                                   m30_axi_bready       ,
    output logic                                   m30_axi_arvalid      ,
    input                                          m30_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m30_axi_araddr       ,
    output logic [8-1:0]                           m30_axi_arlen        ,
    input                                          m30_axi_rvalid       ,
    output logic                                   m30_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m30_axi_rdata        ,
    input                                          m30_axi_rlast        ,

    // AXI4 master interface m31_axi
    output logic                                   m31_axi_awvalid      ,
    input                                          m31_axi_awready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m31_axi_awaddr       ,
    output logic [8-1:0]                           m31_axi_awlen        ,
    output logic                                   m31_axi_wvalid       ,
    input                                          m31_axi_wready       ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]          m31_axi_wdata        ,
    output logic [C_M_AXI_DATA_WIDTH/8-1:0]        m31_axi_wstrb        ,
    output logic                                   m31_axi_wlast        ,
    input                                          m31_axi_bvalid       ,
    output logic                                   m31_axi_bready       ,
    output logic                                   m31_axi_arvalid      ,
    input                                          m31_axi_arready      ,
    output logic [C_M_AXI_ADDR_WIDTH-1:0]          m31_axi_araddr       ,
    output logic [8-1:0]                           m31_axi_arlen        ,
    input                                          m31_axi_rvalid       ,
    output logic                                   m31_axi_rready       ,
    input        [C_M_AXI_DATA_WIDTH-1:0]          m31_axi_rdata        ,
    input                                          m31_axi_rlast        ,

    // AXI4-Lite slave interface
    input        [C_S_AXI_ADDR_WIDTH-1:0]          s_axi_control_awaddr ,
    input                                          s_axi_control_awvalid,
    output logic                                   s_axi_control_awready,
    input        [C_S_AXI_DATA_WIDTH-1:0]          s_axi_control_wdata  ,
    input        [C_S_AXI_DATA_WIDTH/8-1:0]        s_axi_control_wstrb  ,
    input                                          s_axi_control_wvalid ,
    output logic                                   s_axi_control_wready ,
    output logic [2-1:0]                           s_axi_control_bresp  ,
    output logic                                   s_axi_control_bvalid ,
    input                                          s_axi_control_bready ,
    input        [C_S_AXI_ADDR_WIDTH-1:0]          s_axi_control_araddr ,
    input                                          s_axi_control_arvalid,
    output logic                                   s_axi_control_arready,
    output logic [C_S_AXI_DATA_WIDTH-1:0]          s_axi_control_rdata  ,
    output logic [2-1:0]                           s_axi_control_rresp  ,
    output logic                                   s_axi_control_rvalid ,
    input                                          s_axi_control_rready 
);

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
wire [NUM_BRDG-1:0]                             maxi_awvalid ;
wire [NUM_BRDG-1:0]                             maxi_awready ;
wire [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]     maxi_awaddr  ;
wire [NUM_BRDG-1:0][8-1:0]                      maxi_awlen   ;
wire [NUM_BRDG-1:0]                             maxi_wvalid  ;
wire [NUM_BRDG-1:0]                             maxi_wready  ;
wire [NUM_BRDG-1:0][C_M_AXI_DATA_WIDTH-1:0]     maxi_wdata   ;
wire [NUM_BRDG-1:0][C_M_AXI_DATA_WIDTH/8-1:0]   maxi_wstrb   ;
wire [NUM_BRDG-1:0]                             maxi_wlast   ;
wire [NUM_BRDG-1:0]                             maxi_bvalid  ;
wire [NUM_BRDG-1:0]                             maxi_bready  ;
wire [NUM_BRDG-1:0]                             maxi_arvalid ;
wire [NUM_BRDG-1:0]                             maxi_arready ;
wire [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]     maxi_araddr  ;
wire [NUM_BRDG-1:0][8-1:0]                      maxi_arlen   ;
wire [NUM_BRDG-1:0]                             maxi_rvalid  ;
wire [NUM_BRDG-1:0]                             maxi_rready  ;
wire [NUM_BRDG-1:0][C_M_AXI_DATA_WIDTH-1:0]     maxi_rdata   ;
wire [NUM_BRDG-1:0]                             maxi_rlast   ;

wire    user_start ;
wire    user_idle  ;
wire    user_done  ;
wire    user_ready ;

wire [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]      hbm_read_base_addr ;
wire [NUM_BRDG-1:0][C_M_AXI_ADDR_WIDTH-1:0]      hbm_write_base_addr;

// hbm buffer "read" base address sent from host program (defailed address offset specified in vadd_control_s_axi.sv)
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm00_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm01_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm02_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm03_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm04_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm05_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm06_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm07_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm08_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm09_read_base_addr ;

wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm10_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm11_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm12_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm13_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm14_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm15_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm16_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm17_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm18_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm19_read_base_addr ;

wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm20_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm21_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm22_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm23_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm24_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm25_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm26_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm27_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm28_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm29_read_base_addr ;

wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm30_read_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm31_read_base_addr ;

// hbm buffer "write" base address sent from host program (defailed address offset specified in vadd_control_s_axi.sv)
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm00_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm01_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm02_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm03_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm04_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm05_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm06_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm07_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm08_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm09_write_base_addr ;

wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm10_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm11_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm12_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm13_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm14_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm15_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm16_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm17_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm18_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm19_write_base_addr ;

wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm20_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm21_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm22_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm23_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm24_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm25_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm26_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm27_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm28_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm29_write_base_addr ;

wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm30_write_base_addr ;
wire [C_M_AXI_ADDR_WIDTH-1:0]   hbm31_write_base_addr ;

wire [32-1:0]                   instruction_base    ;
wire [32-1:0]                   instruction_num     ;



asic_top #(
    .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
    .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
    .NUM_BRDG(NUM_BRDG)
)
u_asic_top(
    .clk                    (ap_clk),
    .resetn               (ap_rst_n),

    .maxi_awvalid           (maxi_awvalid),
    .maxi_awready           (maxi_awready),
    .maxi_awaddr            (maxi_awaddr ),
    .maxi_awlen             (maxi_awlen  ),
    .maxi_wvalid            (maxi_wvalid ),
    .maxi_wready            (maxi_wready ),
    .maxi_wdata             (maxi_wdata  ),
    .maxi_wstrb             (maxi_wstrb  ),
    .maxi_wlast             (maxi_wlast  ),
    .maxi_bvalid            (maxi_bvalid ),
    .maxi_bready            (maxi_bready ),
    .maxi_arvalid           (maxi_arvalid),
    .maxi_arready           (maxi_arready),
    .maxi_araddr            (maxi_araddr ),
    .maxi_arlen             (maxi_arlen  ),
    .maxi_rvalid            (maxi_rvalid ),
    .maxi_rready            (maxi_rready ),
    .maxi_rdata             (maxi_rdata  ),
    .maxi_rlast             (maxi_rlast  ),

    .user_start             (user_start),
    .user_idle              (user_idle ), 
    .user_done              (user_done ), 
    .user_ready             (user_ready),

    .instruction_base       (instruction_base   ),   
    .instruction_num        (instruction_num    ),    

    
    .hbm_read_base_addr     (hbm_read_base_addr ), 
    .hbm_write_base_addr    (hbm_write_base_addr)
);


control_s_axi #(
    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    .NUM_BRDG           (NUM_BRDG)
) 
u_control_s_axi(
    .ACLK           (ACLK    ),    
    .ARESET_N       (ARESET_N),
    .ACLK_EN        ( 1'b1  ), 
    .AWADDR         (s_axi_control_awaddr   ),  
    .AWVALID        (s_axi_control_awvalid  ), 
    .AWREADY        (s_axi_control_awready  ), 
    .WDATA          (s_axi_control_wdata    ),   
    .WSTRB          (s_axi_control_wstrb    ),   
    .WVALID         (s_axi_control_wvalid   ),  
    .WREADY         (s_axi_control_wready   ),  
    .BRESP          (s_axi_control_bresp    ),   
    .BVALID         (s_axi_control_bvalid   ),  
    .BREADY         (s_axi_control_bready   ),  
    .ARADDR         (s_axi_control_araddr   ),  
    .ARVALID        (s_axi_control_arvalid  ), 
    .ARREADY        (s_axi_control_arready  ), 
    .RDATA          (s_axi_control_rdata    ),   
    .RRESP          (s_axi_control_rresp    ),   
    .RVALID         (s_axi_control_rvalid   ),  
    .RREADY         (s_axi_control_rready   ),  

    .user_start     ( user_start),   
    .user_done      ( user_done ),    
    .user_ready     ( user_ready),   
    .user_idle      ( user_idle ),    


    .instruction_base       (instruction_base   ),
    .instruction_num        (instruction_num    ),
        
    .hbm_read_base_addr     (hbm_read_base_addr ),
    .hbm_write_base_addr    (hbm_write_base_addr)

);



    // awvalid
    assign m00_axi_awvalid = maxi_awvalid[ 0];
    assign m01_axi_awvalid = maxi_awvalid[ 1];
    assign m02_axi_awvalid = maxi_awvalid[ 2];
    assign m03_axi_awvalid = maxi_awvalid[ 3];
    assign m04_axi_awvalid = maxi_awvalid[ 4];
    assign m05_axi_awvalid = maxi_awvalid[ 5];
    assign m06_axi_awvalid = maxi_awvalid[ 6];
    assign m07_axi_awvalid = maxi_awvalid[ 7];
    assign m08_axi_awvalid = maxi_awvalid[ 8];
    assign m09_axi_awvalid = maxi_awvalid[ 9];
    assign m10_axi_awvalid = maxi_awvalid[10];
    assign m11_axi_awvalid = maxi_awvalid[11];
    assign m12_axi_awvalid = maxi_awvalid[12];
    assign m13_axi_awvalid = maxi_awvalid[13];
    assign m14_axi_awvalid = maxi_awvalid[14];
    assign m15_axi_awvalid = maxi_awvalid[15];
    assign m16_axi_awvalid = maxi_awvalid[16];
    assign m17_axi_awvalid = maxi_awvalid[17];
    assign m18_axi_awvalid = maxi_awvalid[18];
    assign m19_axi_awvalid = maxi_awvalid[19];
    assign m20_axi_awvalid = maxi_awvalid[20];
    assign m21_axi_awvalid = maxi_awvalid[21];
    assign m22_axi_awvalid = maxi_awvalid[22];
    assign m23_axi_awvalid = maxi_awvalid[23];
    assign m24_axi_awvalid = maxi_awvalid[24];
    assign m25_axi_awvalid = maxi_awvalid[25];
    assign m26_axi_awvalid = maxi_awvalid[26];
    assign m27_axi_awvalid = maxi_awvalid[27];
    assign m28_axi_awvalid = maxi_awvalid[28];
    assign m29_axi_awvalid = maxi_awvalid[29];
    assign m30_axi_awvalid = maxi_awvalid[30];
    assign m31_axi_awvalid = maxi_awvalid[31];


    // awready
    assign m00_axi_awready = maxi_awready[ 0];
    assign m01_axi_awready = maxi_awready[ 1];
    assign m02_axi_awready = maxi_awready[ 2];
    assign m03_axi_awready = maxi_awready[ 3];
    assign m04_axi_awready = maxi_awready[ 4];
    assign m05_axi_awready = maxi_awready[ 5];
    assign m06_axi_awready = maxi_awready[ 6];
    assign m07_axi_awready = maxi_awready[ 7];
    assign m08_axi_awready = maxi_awready[ 8];
    assign m09_axi_awready = maxi_awready[ 9];
    assign m10_axi_awready = maxi_awready[10];
    assign m11_axi_awready = maxi_awready[11];
    assign m12_axi_awready = maxi_awready[12];
    assign m13_axi_awready = maxi_awready[13];
    assign m14_axi_awready = maxi_awready[14];
    assign m15_axi_awready = maxi_awready[15];
    assign m16_axi_awready = maxi_awready[16];
    assign m17_axi_awready = maxi_awready[17];
    assign m18_axi_awready = maxi_awready[18];
    assign m19_axi_awready = maxi_awready[19];
    assign m20_axi_awready = maxi_awready[20];
    assign m21_axi_awready = maxi_awready[21];
    assign m22_axi_awready = maxi_awready[22];
    assign m23_axi_awready = maxi_awready[23];
    assign m24_axi_awready = maxi_awready[24];
    assign m25_axi_awready = maxi_awready[25];
    assign m26_axi_awready = maxi_awready[26];
    assign m27_axi_awready = maxi_awready[27];
    assign m28_axi_awready = maxi_awready[28];
    assign m29_axi_awready = maxi_awready[29];
    assign m30_axi_awready = maxi_awready[30];
    assign m31_axi_awready = maxi_awready[31];


    // awaddr
    assign m00_axi_awaddr = maxi_awaddr[ 0];
    assign m01_axi_awaddr = maxi_awaddr[ 1];
    assign m02_axi_awaddr = maxi_awaddr[ 2];
    assign m03_axi_awaddr = maxi_awaddr[ 3];
    assign m04_axi_awaddr = maxi_awaddr[ 4];
    assign m05_axi_awaddr = maxi_awaddr[ 5];
    assign m06_axi_awaddr = maxi_awaddr[ 6];
    assign m07_axi_awaddr = maxi_awaddr[ 7];
    assign m08_axi_awaddr = maxi_awaddr[ 8];
    assign m09_axi_awaddr = maxi_awaddr[ 9];
    assign m10_axi_awaddr = maxi_awaddr[10];
    assign m11_axi_awaddr = maxi_awaddr[11];
    assign m12_axi_awaddr = maxi_awaddr[12];
    assign m13_axi_awaddr = maxi_awaddr[13];
    assign m14_axi_awaddr = maxi_awaddr[14];
    assign m15_axi_awaddr = maxi_awaddr[15];
    assign m16_axi_awaddr = maxi_awaddr[16];
    assign m17_axi_awaddr = maxi_awaddr[17];
    assign m18_axi_awaddr = maxi_awaddr[18];
    assign m19_axi_awaddr = maxi_awaddr[19];
    assign m20_axi_awaddr = maxi_awaddr[20];
    assign m21_axi_awaddr = maxi_awaddr[21];
    assign m22_axi_awaddr = maxi_awaddr[22];
    assign m23_axi_awaddr = maxi_awaddr[23];
    assign m24_axi_awaddr = maxi_awaddr[24];
    assign m25_axi_awaddr = maxi_awaddr[25];
    assign m26_axi_awaddr = maxi_awaddr[26];
    assign m27_axi_awaddr = maxi_awaddr[27];
    assign m28_axi_awaddr = maxi_awaddr[28];
    assign m29_axi_awaddr = maxi_awaddr[29];
    assign m30_axi_awaddr = maxi_awaddr[30];
    assign m31_axi_awaddr = maxi_awaddr[31];

    // awlen
    assign m00_axi_awlen = maxi_awlen[ 0];
    assign m01_axi_awlen = maxi_awlen[ 1];
    assign m02_axi_awlen = maxi_awlen[ 2];
    assign m03_axi_awlen = maxi_awlen[ 3];
    assign m04_axi_awlen = maxi_awlen[ 4];
    assign m05_axi_awlen = maxi_awlen[ 5];
    assign m06_axi_awlen = maxi_awlen[ 6];
    assign m07_axi_awlen = maxi_awlen[ 7];
    assign m08_axi_awlen = maxi_awlen[ 8];
    assign m09_axi_awlen = maxi_awlen[ 9];
    assign m10_axi_awlen = maxi_awlen[10];
    assign m11_axi_awlen = maxi_awlen[11];
    assign m12_axi_awlen = maxi_awlen[12];
    assign m13_axi_awlen = maxi_awlen[13];
    assign m14_axi_awlen = maxi_awlen[14];
    assign m15_axi_awlen = maxi_awlen[15];
    assign m16_axi_awlen = maxi_awlen[16];
    assign m17_axi_awlen = maxi_awlen[17];
    assign m18_axi_awlen = maxi_awlen[18];
    assign m19_axi_awlen = maxi_awlen[19];
    assign m20_axi_awlen = maxi_awlen[20];
    assign m21_axi_awlen = maxi_awlen[21];
    assign m22_axi_awlen = maxi_awlen[22];
    assign m23_axi_awlen = maxi_awlen[23];
    assign m24_axi_awlen = maxi_awlen[24];
    assign m25_axi_awlen = maxi_awlen[25];
    assign m26_axi_awlen = maxi_awlen[26];
    assign m27_axi_awlen = maxi_awlen[27];
    assign m28_axi_awlen = maxi_awlen[28];
    assign m29_axi_awlen = maxi_awlen[29];
    assign m30_axi_awlen = maxi_awlen[30];
    assign m31_axi_awlen = maxi_awlen[31];


    // wvalid
    assign m00_axi_wvalid = maxi_wvalid[ 0];
    assign m01_axi_wvalid = maxi_wvalid[ 1];
    assign m02_axi_wvalid = maxi_wvalid[ 2];
    assign m03_axi_wvalid = maxi_wvalid[ 3];
    assign m04_axi_wvalid = maxi_wvalid[ 4];
    assign m05_axi_wvalid = maxi_wvalid[ 5];
    assign m06_axi_wvalid = maxi_wvalid[ 6];
    assign m07_axi_wvalid = maxi_wvalid[ 7];
    assign m08_axi_wvalid = maxi_wvalid[ 8];
    assign m09_axi_wvalid = maxi_wvalid[ 9];
    assign m10_axi_wvalid = maxi_wvalid[10];
    assign m11_axi_wvalid = maxi_wvalid[11];
    assign m12_axi_wvalid = maxi_wvalid[12];
    assign m13_axi_wvalid = maxi_wvalid[13];
    assign m14_axi_wvalid = maxi_wvalid[14];
    assign m15_axi_wvalid = maxi_wvalid[15];
    assign m16_axi_wvalid = maxi_wvalid[16];
    assign m17_axi_wvalid = maxi_wvalid[17];
    assign m18_axi_wvalid = maxi_wvalid[18];
    assign m19_axi_wvalid = maxi_wvalid[19];
    assign m20_axi_wvalid = maxi_wvalid[20];
    assign m21_axi_wvalid = maxi_wvalid[21];
    assign m22_axi_wvalid = maxi_wvalid[22];
    assign m23_axi_wvalid = maxi_wvalid[23];
    assign m24_axi_wvalid = maxi_wvalid[24];
    assign m25_axi_wvalid = maxi_wvalid[25];
    assign m26_axi_wvalid = maxi_wvalid[26];
    assign m27_axi_wvalid = maxi_wvalid[27];
    assign m28_axi_wvalid = maxi_wvalid[28];
    assign m29_axi_wvalid = maxi_wvalid[29];
    assign m30_axi_wvalid = maxi_wvalid[30];
    assign m31_axi_wvalid = maxi_wvalid[31];


    // wready
    assign m00_axi_wready = maxi_wready[ 0];
    assign m01_axi_wready = maxi_wready[ 1];
    assign m02_axi_wready = maxi_wready[ 2];
    assign m03_axi_wready = maxi_wready[ 3];
    assign m04_axi_wready = maxi_wready[ 4];
    assign m05_axi_wready = maxi_wready[ 5];
    assign m06_axi_wready = maxi_wready[ 6];
    assign m07_axi_wready = maxi_wready[ 7];
    assign m08_axi_wready = maxi_wready[ 8];
    assign m09_axi_wready = maxi_wready[ 9];
    assign m10_axi_wready = maxi_wready[10];
    assign m11_axi_wready = maxi_wready[11];
    assign m12_axi_wready = maxi_wready[12];
    assign m13_axi_wready = maxi_wready[13];
    assign m14_axi_wready = maxi_wready[14];
    assign m15_axi_wready = maxi_wready[15];
    assign m16_axi_wready = maxi_wready[16];
    assign m17_axi_wready = maxi_wready[17];
    assign m18_axi_wready = maxi_wready[18];
    assign m19_axi_wready = maxi_wready[19];
    assign m20_axi_wready = maxi_wready[20];
    assign m21_axi_wready = maxi_wready[21];
    assign m22_axi_wready = maxi_wready[22];
    assign m23_axi_wready = maxi_wready[23];
    assign m24_axi_wready = maxi_wready[24];
    assign m25_axi_wready = maxi_wready[25];
    assign m26_axi_wready = maxi_wready[26];
    assign m27_axi_wready = maxi_wready[27];
    assign m28_axi_wready = maxi_wready[28];
    assign m29_axi_wready = maxi_wready[29];
    assign m30_axi_wready = maxi_wready[30];
    assign m31_axi_wready = maxi_wready[31];

    // wdata
    assign m00_axi_wdata = maxi_wdata[ 0];
    assign m01_axi_wdata = maxi_wdata[ 1];
    assign m02_axi_wdata = maxi_wdata[ 2];
    assign m03_axi_wdata = maxi_wdata[ 3];
    assign m04_axi_wdata = maxi_wdata[ 4];
    assign m05_axi_wdata = maxi_wdata[ 5];
    assign m06_axi_wdata = maxi_wdata[ 6];
    assign m07_axi_wdata = maxi_wdata[ 7];
    assign m08_axi_wdata = maxi_wdata[ 8];
    assign m09_axi_wdata = maxi_wdata[ 9];
    assign m10_axi_wdata = maxi_wdata[10];
    assign m11_axi_wdata = maxi_wdata[11];
    assign m12_axi_wdata = maxi_wdata[12];
    assign m13_axi_wdata = maxi_wdata[13];
    assign m14_axi_wdata = maxi_wdata[14];
    assign m15_axi_wdata = maxi_wdata[15];
    assign m16_axi_wdata = maxi_wdata[16];
    assign m17_axi_wdata = maxi_wdata[17];
    assign m18_axi_wdata = maxi_wdata[18];
    assign m19_axi_wdata = maxi_wdata[19];
    assign m20_axi_wdata = maxi_wdata[20];
    assign m21_axi_wdata = maxi_wdata[21];
    assign m22_axi_wdata = maxi_wdata[22];
    assign m23_axi_wdata = maxi_wdata[23];
    assign m24_axi_wdata = maxi_wdata[24];
    assign m25_axi_wdata = maxi_wdata[25];
    assign m26_axi_wdata = maxi_wdata[26];
    assign m27_axi_wdata = maxi_wdata[27];
    assign m28_axi_wdata = maxi_wdata[28];
    assign m29_axi_wdata = maxi_wdata[29];
    assign m30_axi_wdata = maxi_wdata[30];
    assign m31_axi_wdata = maxi_wdata[31];

    // wlast
    assign m00_axi_wlast = maxi_wlast[ 0];
    assign m01_axi_wlast = maxi_wlast[ 1];
    assign m02_axi_wlast = maxi_wlast[ 2];
    assign m03_axi_wlast = maxi_wlast[ 3];
    assign m04_axi_wlast = maxi_wlast[ 4];
    assign m05_axi_wlast = maxi_wlast[ 5];
    assign m06_axi_wlast = maxi_wlast[ 6];
    assign m07_axi_wlast = maxi_wlast[ 7];
    assign m08_axi_wlast = maxi_wlast[ 8];
    assign m09_axi_wlast = maxi_wlast[ 9];
    assign m10_axi_wlast = maxi_wlast[10];
    assign m11_axi_wlast = maxi_wlast[11];
    assign m12_axi_wlast = maxi_wlast[12];
    assign m13_axi_wlast = maxi_wlast[13];
    assign m14_axi_wlast = maxi_wlast[14];
    assign m15_axi_wlast = maxi_wlast[15];
    assign m16_axi_wlast = maxi_wlast[16];
    assign m17_axi_wlast = maxi_wlast[17];
    assign m18_axi_wlast = maxi_wlast[18];
    assign m19_axi_wlast = maxi_wlast[19];
    assign m20_axi_wlast = maxi_wlast[20];
    assign m21_axi_wlast = maxi_wlast[21];
    assign m22_axi_wlast = maxi_wlast[22];
    assign m23_axi_wlast = maxi_wlast[23];
    assign m24_axi_wlast = maxi_wlast[24];
    assign m25_axi_wlast = maxi_wlast[25];
    assign m26_axi_wlast = maxi_wlast[26];
    assign m27_axi_wlast = maxi_wlast[27];
    assign m28_axi_wlast = maxi_wlast[28];
    assign m29_axi_wlast = maxi_wlast[29];
    assign m30_axi_wlast = maxi_wlast[30];
    assign m31_axi_wlast = maxi_wlast[31];


    // bvalid
    assign m00_axi_bvalid = maxi_bvalid[ 0];
    assign m01_axi_bvalid = maxi_bvalid[ 1];
    assign m02_axi_bvalid = maxi_bvalid[ 2];
    assign m03_axi_bvalid = maxi_bvalid[ 3];
    assign m04_axi_bvalid = maxi_bvalid[ 4];
    assign m05_axi_bvalid = maxi_bvalid[ 5];
    assign m06_axi_bvalid = maxi_bvalid[ 6];
    assign m07_axi_bvalid = maxi_bvalid[ 7];
    assign m08_axi_bvalid = maxi_bvalid[ 8];
    assign m09_axi_bvalid = maxi_bvalid[ 9];
    assign m10_axi_bvalid = maxi_bvalid[10];
    assign m11_axi_bvalid = maxi_bvalid[11];
    assign m12_axi_bvalid = maxi_bvalid[12];
    assign m13_axi_bvalid = maxi_bvalid[13];
    assign m14_axi_bvalid = maxi_bvalid[14];
    assign m15_axi_bvalid = maxi_bvalid[15];
    assign m16_axi_bvalid = maxi_bvalid[16];
    assign m17_axi_bvalid = maxi_bvalid[17];
    assign m18_axi_bvalid = maxi_bvalid[18];
    assign m19_axi_bvalid = maxi_bvalid[19];
    assign m20_axi_bvalid = maxi_bvalid[20];
    assign m21_axi_bvalid = maxi_bvalid[21];
    assign m22_axi_bvalid = maxi_bvalid[22];
    assign m23_axi_bvalid = maxi_bvalid[23];
    assign m24_axi_bvalid = maxi_bvalid[24];
    assign m25_axi_bvalid = maxi_bvalid[25];
    assign m26_axi_bvalid = maxi_bvalid[26];
    assign m27_axi_bvalid = maxi_bvalid[27];
    assign m28_axi_bvalid = maxi_bvalid[28];
    assign m29_axi_bvalid = maxi_bvalid[29];
    assign m30_axi_bvalid = maxi_bvalid[30];
    assign m31_axi_bvalid = maxi_bvalid[31];


    // bready
    assign m00_axi_bready = maxi_bready[ 0];
    assign m01_axi_bready = maxi_bready[ 1];
    assign m02_axi_bready = maxi_bready[ 2];
    assign m03_axi_bready = maxi_bready[ 3];
    assign m04_axi_bready = maxi_bready[ 4];
    assign m05_axi_bready = maxi_bready[ 5];
    assign m06_axi_bready = maxi_bready[ 6];
    assign m07_axi_bready = maxi_bready[ 7];
    assign m08_axi_bready = maxi_bready[ 8];
    assign m09_axi_bready = maxi_bready[ 9];
    assign m10_axi_bready = maxi_bready[10];
    assign m11_axi_bready = maxi_bready[11];
    assign m12_axi_bready = maxi_bready[12];
    assign m13_axi_bready = maxi_bready[13];
    assign m14_axi_bready = maxi_bready[14];
    assign m15_axi_bready = maxi_bready[15];
    assign m16_axi_bready = maxi_bready[16];
    assign m17_axi_bready = maxi_bready[17];
    assign m18_axi_bready = maxi_bready[18];
    assign m19_axi_bready = maxi_bready[19];
    assign m20_axi_bready = maxi_bready[20];
    assign m21_axi_bready = maxi_bready[21];
    assign m22_axi_bready = maxi_bready[22];
    assign m23_axi_bready = maxi_bready[23];
    assign m24_axi_bready = maxi_bready[24];
    assign m25_axi_bready = maxi_bready[25];
    assign m26_axi_bready = maxi_bready[26];
    assign m27_axi_bready = maxi_bready[27];
    assign m28_axi_bready = maxi_bready[28];
    assign m29_axi_bready = maxi_bready[29];
    assign m30_axi_bready = maxi_bready[30];
    assign m31_axi_bready = maxi_bready[31];

    // arvalid
    assign m00_axi_arvalid = maxi_arvalid[ 0];
    assign m01_axi_arvalid = maxi_arvalid[ 1];
    assign m02_axi_arvalid = maxi_arvalid[ 2];
    assign m03_axi_arvalid = maxi_arvalid[ 3];
    assign m04_axi_arvalid = maxi_arvalid[ 4];
    assign m05_axi_arvalid = maxi_arvalid[ 5];
    assign m06_axi_arvalid = maxi_arvalid[ 6];
    assign m07_axi_arvalid = maxi_arvalid[ 7];
    assign m08_axi_arvalid = maxi_arvalid[ 8];
    assign m09_axi_arvalid = maxi_arvalid[ 9];
    assign m10_axi_arvalid = maxi_arvalid[10];
    assign m11_axi_arvalid = maxi_arvalid[11];
    assign m12_axi_arvalid = maxi_arvalid[12];
    assign m13_axi_arvalid = maxi_arvalid[13];
    assign m14_axi_arvalid = maxi_arvalid[14];
    assign m15_axi_arvalid = maxi_arvalid[15];
    assign m16_axi_arvalid = maxi_arvalid[16];
    assign m17_axi_arvalid = maxi_arvalid[17];
    assign m18_axi_arvalid = maxi_arvalid[18];
    assign m19_axi_arvalid = maxi_arvalid[19];
    assign m20_axi_arvalid = maxi_arvalid[20];
    assign m21_axi_arvalid = maxi_arvalid[21];
    assign m22_axi_arvalid = maxi_arvalid[22];
    assign m23_axi_arvalid = maxi_arvalid[23];
    assign m24_axi_arvalid = maxi_arvalid[24];
    assign m25_axi_arvalid = maxi_arvalid[25];
    assign m26_axi_arvalid = maxi_arvalid[26];
    assign m27_axi_arvalid = maxi_arvalid[27];
    assign m28_axi_arvalid = maxi_arvalid[28];
    assign m29_axi_arvalid = maxi_arvalid[29];
    assign m30_axi_arvalid = maxi_arvalid[30];
    assign m31_axi_arvalid = maxi_arvalid[31];



    // arready
    assign m00_axi_arready = maxi_arready[ 0];
    assign m01_axi_arready = maxi_arready[ 1];
    assign m02_axi_arready = maxi_arready[ 2];
    assign m03_axi_arready = maxi_arready[ 3];
    assign m04_axi_arready = maxi_arready[ 4];
    assign m05_axi_arready = maxi_arready[ 5];
    assign m06_axi_arready = maxi_arready[ 6];
    assign m07_axi_arready = maxi_arready[ 7];
    assign m08_axi_arready = maxi_arready[ 8];
    assign m09_axi_arready = maxi_arready[ 9];
    assign m10_axi_arready = maxi_arready[10];
    assign m11_axi_arready = maxi_arready[11];
    assign m12_axi_arready = maxi_arready[12];
    assign m13_axi_arready = maxi_arready[13];
    assign m14_axi_arready = maxi_arready[14];
    assign m15_axi_arready = maxi_arready[15];
    assign m16_axi_arready = maxi_arready[16];
    assign m17_axi_arready = maxi_arready[17];
    assign m18_axi_arready = maxi_arready[18];
    assign m19_axi_arready = maxi_arready[19];
    assign m20_axi_arready = maxi_arready[20];
    assign m21_axi_arready = maxi_arready[21];
    assign m22_axi_arready = maxi_arready[22];
    assign m23_axi_arready = maxi_arready[23];
    assign m24_axi_arready = maxi_arready[24];
    assign m25_axi_arready = maxi_arready[25];
    assign m26_axi_arready = maxi_arready[26];
    assign m27_axi_arready = maxi_arready[27];
    assign m28_axi_arready = maxi_arready[28];
    assign m29_axi_arready = maxi_arready[29];
    assign m30_axi_arready = maxi_arready[30];
    assign m31_axi_arready = maxi_arready[31];



    // araddr
    assign m00_axi_araddr = maxi_araddr[ 0];
    assign m01_axi_araddr = maxi_araddr[ 1];
    assign m02_axi_araddr = maxi_araddr[ 2];
    assign m03_axi_araddr = maxi_araddr[ 3];
    assign m04_axi_araddr = maxi_araddr[ 4];
    assign m05_axi_araddr = maxi_araddr[ 5];
    assign m06_axi_araddr = maxi_araddr[ 6];
    assign m07_axi_araddr = maxi_araddr[ 7];
    assign m08_axi_araddr = maxi_araddr[ 8];
    assign m09_axi_araddr = maxi_araddr[ 9];
    assign m10_axi_araddr = maxi_araddr[10];
    assign m11_axi_araddr = maxi_araddr[11];
    assign m12_axi_araddr = maxi_araddr[12];
    assign m13_axi_araddr = maxi_araddr[13];
    assign m14_axi_araddr = maxi_araddr[14];
    assign m15_axi_araddr = maxi_araddr[15];
    assign m16_axi_araddr = maxi_araddr[16];
    assign m17_axi_araddr = maxi_araddr[17];
    assign m18_axi_araddr = maxi_araddr[18];
    assign m19_axi_araddr = maxi_araddr[19];
    assign m20_axi_araddr = maxi_araddr[20];
    assign m21_axi_araddr = maxi_araddr[21];
    assign m22_axi_araddr = maxi_araddr[22];
    assign m23_axi_araddr = maxi_araddr[23];
    assign m24_axi_araddr = maxi_araddr[24];
    assign m25_axi_araddr = maxi_araddr[25];
    assign m26_axi_araddr = maxi_araddr[26];
    assign m27_axi_araddr = maxi_araddr[27];
    assign m28_axi_araddr = maxi_araddr[28];
    assign m29_axi_araddr = maxi_araddr[29];
    assign m30_axi_araddr = maxi_araddr[30];
    assign m31_axi_araddr = maxi_araddr[31];


    // arlen
    assign m00_axi_arlen = maxi_arlen[ 0];
    assign m01_axi_arlen = maxi_arlen[ 1];
    assign m02_axi_arlen = maxi_arlen[ 2];
    assign m03_axi_arlen = maxi_arlen[ 3];
    assign m04_axi_arlen = maxi_arlen[ 4];
    assign m05_axi_arlen = maxi_arlen[ 5];
    assign m06_axi_arlen = maxi_arlen[ 6];
    assign m07_axi_arlen = maxi_arlen[ 7];
    assign m08_axi_arlen = maxi_arlen[ 8];
    assign m09_axi_arlen = maxi_arlen[ 9];
    assign m10_axi_arlen = maxi_arlen[10];
    assign m11_axi_arlen = maxi_arlen[11];
    assign m12_axi_arlen = maxi_arlen[12];
    assign m13_axi_arlen = maxi_arlen[13];
    assign m14_axi_arlen = maxi_arlen[14];
    assign m15_axi_arlen = maxi_arlen[15];
    assign m16_axi_arlen = maxi_arlen[16];
    assign m17_axi_arlen = maxi_arlen[17];
    assign m18_axi_arlen = maxi_arlen[18];
    assign m19_axi_arlen = maxi_arlen[19];
    assign m20_axi_arlen = maxi_arlen[20];
    assign m21_axi_arlen = maxi_arlen[21];
    assign m22_axi_arlen = maxi_arlen[22];
    assign m23_axi_arlen = maxi_arlen[23];
    assign m24_axi_arlen = maxi_arlen[24];
    assign m25_axi_arlen = maxi_arlen[25];
    assign m26_axi_arlen = maxi_arlen[26];
    assign m27_axi_arlen = maxi_arlen[27];
    assign m28_axi_arlen = maxi_arlen[28];
    assign m29_axi_arlen = maxi_arlen[29];
    assign m30_axi_arlen = maxi_arlen[30];
    assign m31_axi_arlen = maxi_arlen[31];


    // rvalid
    assign m00_axi_rvalid = maxi_rvalid[ 0];
    assign m01_axi_rvalid = maxi_rvalid[ 1];
    assign m02_axi_rvalid = maxi_rvalid[ 2];
    assign m03_axi_rvalid = maxi_rvalid[ 3];
    assign m04_axi_rvalid = maxi_rvalid[ 4];
    assign m05_axi_rvalid = maxi_rvalid[ 5];
    assign m06_axi_rvalid = maxi_rvalid[ 6];
    assign m07_axi_rvalid = maxi_rvalid[ 7];
    assign m08_axi_rvalid = maxi_rvalid[ 8];
    assign m09_axi_rvalid = maxi_rvalid[ 9];
    assign m10_axi_rvalid = maxi_rvalid[10];
    assign m11_axi_rvalid = maxi_rvalid[11];
    assign m12_axi_rvalid = maxi_rvalid[12];
    assign m13_axi_rvalid = maxi_rvalid[13];
    assign m14_axi_rvalid = maxi_rvalid[14];
    assign m15_axi_rvalid = maxi_rvalid[15];
    assign m16_axi_rvalid = maxi_rvalid[16];
    assign m17_axi_rvalid = maxi_rvalid[17];
    assign m18_axi_rvalid = maxi_rvalid[18];
    assign m19_axi_rvalid = maxi_rvalid[19];
    assign m20_axi_rvalid = maxi_rvalid[20];
    assign m21_axi_rvalid = maxi_rvalid[21];
    assign m22_axi_rvalid = maxi_rvalid[22];
    assign m23_axi_rvalid = maxi_rvalid[23];
    assign m24_axi_rvalid = maxi_rvalid[24];
    assign m25_axi_rvalid = maxi_rvalid[25];
    assign m26_axi_rvalid = maxi_rvalid[26];
    assign m27_axi_rvalid = maxi_rvalid[27];
    assign m28_axi_rvalid = maxi_rvalid[28];
    assign m29_axi_rvalid = maxi_rvalid[29];
    assign m30_axi_rvalid = maxi_rvalid[30];
    assign m31_axi_rvalid = maxi_rvalid[31];


    // rready
    assign m00_axi_rready = maxi_rready[ 0];
    assign m01_axi_rready = maxi_rready[ 1];
    assign m02_axi_rready = maxi_rready[ 2];
    assign m03_axi_rready = maxi_rready[ 3];
    assign m04_axi_rready = maxi_rready[ 4];
    assign m05_axi_rready = maxi_rready[ 5];
    assign m06_axi_rready = maxi_rready[ 6];
    assign m07_axi_rready = maxi_rready[ 7];
    assign m08_axi_rready = maxi_rready[ 8];
    assign m09_axi_rready = maxi_rready[ 9];
    assign m10_axi_rready = maxi_rready[10];
    assign m11_axi_rready = maxi_rready[11];
    assign m12_axi_rready = maxi_rready[12];
    assign m13_axi_rready = maxi_rready[13];
    assign m14_axi_rready = maxi_rready[14];
    assign m15_axi_rready = maxi_rready[15];
    assign m16_axi_rready = maxi_rready[16];
    assign m17_axi_rready = maxi_rready[17];
    assign m18_axi_rready = maxi_rready[18];
    assign m19_axi_rready = maxi_rready[19];
    assign m20_axi_rready = maxi_rready[20];
    assign m21_axi_rready = maxi_rready[21];
    assign m22_axi_rready = maxi_rready[22];
    assign m23_axi_rready = maxi_rready[23];
    assign m24_axi_rready = maxi_rready[24];
    assign m25_axi_rready = maxi_rready[25];
    assign m26_axi_rready = maxi_rready[26];
    assign m27_axi_rready = maxi_rready[27];
    assign m28_axi_rready = maxi_rready[28];
    assign m29_axi_rready = maxi_rready[29];
    assign m30_axi_rready = maxi_rready[30];
    assign m31_axi_rready = maxi_rready[31];

    // rdata
    assign m00_axi_rdata = maxi_rdata[ 0];
    assign m01_axi_rdata = maxi_rdata[ 1];
    assign m02_axi_rdata = maxi_rdata[ 2];
    assign m03_axi_rdata = maxi_rdata[ 3];
    assign m04_axi_rdata = maxi_rdata[ 4];
    assign m05_axi_rdata = maxi_rdata[ 5];
    assign m06_axi_rdata = maxi_rdata[ 6];
    assign m07_axi_rdata = maxi_rdata[ 7];
    assign m08_axi_rdata = maxi_rdata[ 8];
    assign m09_axi_rdata = maxi_rdata[ 9];
    assign m10_axi_rdata = maxi_rdata[10];
    assign m11_axi_rdata = maxi_rdata[11];
    assign m12_axi_rdata = maxi_rdata[12];
    assign m13_axi_rdata = maxi_rdata[13];
    assign m14_axi_rdata = maxi_rdata[14];
    assign m15_axi_rdata = maxi_rdata[15];
    assign m16_axi_rdata = maxi_rdata[16];
    assign m17_axi_rdata = maxi_rdata[17];
    assign m18_axi_rdata = maxi_rdata[18];
    assign m19_axi_rdata = maxi_rdata[19];
    assign m20_axi_rdata = maxi_rdata[20];
    assign m21_axi_rdata = maxi_rdata[21];
    assign m22_axi_rdata = maxi_rdata[22];
    assign m23_axi_rdata = maxi_rdata[23];
    assign m24_axi_rdata = maxi_rdata[24];
    assign m25_axi_rdata = maxi_rdata[25];
    assign m26_axi_rdata = maxi_rdata[26];
    assign m27_axi_rdata = maxi_rdata[27];
    assign m28_axi_rdata = maxi_rdata[28];
    assign m29_axi_rdata = maxi_rdata[29];
    assign m30_axi_rdata = maxi_rdata[30];
    assign m31_axi_rdata = maxi_rdata[31];


    // rlast
    assign m00_axi_rlast = maxi_rlast[ 0];
    assign m01_axi_rlast = maxi_rlast[ 1];
    assign m02_axi_rlast = maxi_rlast[ 2];
    assign m03_axi_rlast = maxi_rlast[ 3];
    assign m04_axi_rlast = maxi_rlast[ 4];
    assign m05_axi_rlast = maxi_rlast[ 5];
    assign m06_axi_rlast = maxi_rlast[ 6];
    assign m07_axi_rlast = maxi_rlast[ 7];
    assign m08_axi_rlast = maxi_rlast[ 8];
    assign m09_axi_rlast = maxi_rlast[ 9];
    assign m10_axi_rlast = maxi_rlast[10];
    assign m11_axi_rlast = maxi_rlast[11];
    assign m12_axi_rlast = maxi_rlast[12];
    assign m13_axi_rlast = maxi_rlast[13];
    assign m14_axi_rlast = maxi_rlast[14];
    assign m15_axi_rlast = maxi_rlast[15];
    assign m16_axi_rlast = maxi_rlast[16];
    assign m17_axi_rlast = maxi_rlast[17];
    assign m18_axi_rlast = maxi_rlast[18];
    assign m19_axi_rlast = maxi_rlast[19];
    assign m20_axi_rlast = maxi_rlast[20];
    assign m21_axi_rlast = maxi_rlast[21];
    assign m22_axi_rlast = maxi_rlast[22];
    assign m23_axi_rlast = maxi_rlast[23];
    assign m24_axi_rlast = maxi_rlast[24];
    assign m25_axi_rlast = maxi_rlast[25];
    assign m26_axi_rlast = maxi_rlast[26];
    assign m27_axi_rlast = maxi_rlast[27];
    assign m28_axi_rlast = maxi_rlast[28];
    assign m29_axi_rlast = maxi_rlast[29];
    assign m30_axi_rlast = maxi_rlast[30];
    assign m31_axi_rlast = maxi_rlast[31];

    // // hbm read
    // assign hbm00_read_base_addr = hbm_read_base_addr[ 0];
    // assign hbm01_read_base_addr = hbm_read_base_addr[ 1];
    // assign hbm02_read_base_addr = hbm_read_base_addr[ 2];
    // assign hbm03_read_base_addr = hbm_read_base_addr[ 3];
    // assign hbm04_read_base_addr = hbm_read_base_addr[ 4];
    // assign hbm05_read_base_addr = hbm_read_base_addr[ 5];
    // assign hbm06_read_base_addr = hbm_read_base_addr[ 6];
    // assign hbm07_read_base_addr = hbm_read_base_addr[ 7];
    // assign hbm08_read_base_addr = hbm_read_base_addr[ 8];
    // assign hbm09_read_base_addr = hbm_read_base_addr[ 9];
    // assign hbm10_read_base_addr = hbm_read_base_addr[10];
    // assign hbm11_read_base_addr = hbm_read_base_addr[11];
    // assign hbm12_read_base_addr = hbm_read_base_addr[12];
    // assign hbm13_read_base_addr = hbm_read_base_addr[13];
    // assign hbm14_read_base_addr = hbm_read_base_addr[14];
    // assign hbm15_read_base_addr = hbm_read_base_addr[15];
    // assign hbm16_read_base_addr = hbm_read_base_addr[16];
    // assign hbm17_read_base_addr = hbm_read_base_addr[17];
    // assign hbm18_read_base_addr = hbm_read_base_addr[18];
    // assign hbm19_read_base_addr = hbm_read_base_addr[19];
    // assign hbm20_read_base_addr = hbm_read_base_addr[20];
    // assign hbm21_read_base_addr = hbm_read_base_addr[21];
    // assign hbm22_read_base_addr = hbm_read_base_addr[22];
    // assign hbm23_read_base_addr = hbm_read_base_addr[23];
    // assign hbm24_read_base_addr = hbm_read_base_addr[24];
    // assign hbm25_read_base_addr = hbm_read_base_addr[25];
    // assign hbm26_read_base_addr = hbm_read_base_addr[26];
    // assign hbm27_read_base_addr = hbm_read_base_addr[27];
    // assign hbm28_read_base_addr = hbm_read_base_addr[28];
    // assign hbm29_read_base_addr = hbm_read_base_addr[29];
    // assign hbm30_read_base_addr = hbm_read_base_addr[30];
    // assign hbm31_read_base_addr = hbm_read_base_addr[31];

    // // hbm write
    // assign hbm00_write_base_addr = hbm_write_base_addr[ 0];
    // assign hbm01_write_base_addr = hbm_write_base_addr[ 1];
    // assign hbm02_write_base_addr = hbm_write_base_addr[ 2];
    // assign hbm03_write_base_addr = hbm_write_base_addr[ 3];
    // assign hbm04_write_base_addr = hbm_write_base_addr[ 4];
    // assign hbm05_write_base_addr = hbm_write_base_addr[ 5];
    // assign hbm06_write_base_addr = hbm_write_base_addr[ 6];
    // assign hbm07_write_base_addr = hbm_write_base_addr[ 7];
    // assign hbm08_write_base_addr = hbm_write_base_addr[ 8];
    // assign hbm09_write_base_addr = hbm_write_base_addr[ 9];
    // assign hbm10_write_base_addr = hbm_write_base_addr[10];
    // assign hbm11_write_base_addr = hbm_write_base_addr[11];
    // assign hbm12_write_base_addr = hbm_write_base_addr[12];
    // assign hbm13_write_base_addr = hbm_write_base_addr[13];
    // assign hbm14_write_base_addr = hbm_write_base_addr[14];
    // assign hbm15_write_base_addr = hbm_write_base_addr[15];
    // assign hbm16_write_base_addr = hbm_write_base_addr[16];
    // assign hbm17_write_base_addr = hbm_write_base_addr[17];
    // assign hbm18_write_base_addr = hbm_write_base_addr[18];
    // assign hbm19_write_base_addr = hbm_write_base_addr[19];
    // assign hbm20_write_base_addr = hbm_write_base_addr[20];
    // assign hbm21_write_base_addr = hbm_write_base_addr[21];
    // assign hbm22_write_base_addr = hbm_write_base_addr[22];
    // assign hbm23_write_base_addr = hbm_write_base_addr[23];
    // assign hbm24_write_base_addr = hbm_write_base_addr[24];
    // assign hbm25_write_base_addr = hbm_write_base_addr[25];
    // assign hbm26_write_base_addr = hbm_write_base_addr[26];
    // assign hbm27_write_base_addr = hbm_write_base_addr[27];
    // assign hbm28_write_base_addr = hbm_write_base_addr[28];
    // assign hbm29_write_base_addr = hbm_write_base_addr[29];
    // assign hbm30_write_base_addr = hbm_write_base_addr[30];
    // assign hbm31_write_base_addr = hbm_write_base_addr[31];





endmodule