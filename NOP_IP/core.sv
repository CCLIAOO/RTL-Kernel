// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : core.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-07-16   Lyu-Ming Ho     
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// -----------------------------------------------------------------------------


module core #(
    parameter NUM_READ_BRIDGE       = 32    ,
    parameter NUM_WRITE_BRIDGE      = 16    ,
    parameter C_M_AXI_ADDR_WIDTH    = 64    ,
    parameter C_M_AXI_DATA_WIDTH    = 512   ,
    parameter ADDR_WIDTH            = 64    ,
    parameter DATA_WIDTH            = 512   ,
    parameter NUM_R_BRDG            = 32    ,
    parameter NUM_W_BRDG            = 16    ,
    parameter NUM_QUANT             = 256       // highPrecEngine number of multiplication
) (
    input  logic                                                    clk                 ,
    input  logic                                                    resetn              ,
    
    input  logic [            256-1:0 ]                             instruction         ,
    input  logic                                                    instruction_valid   ,
    output logic                                                    instruction_ready   ,

    // 32 pairs combined AXI4 master "read" interface, will be connected to "read_bridge"
    output logic                                                    ctrl_arvalid        ,
    output logic [ ADDR_WIDTH-1:0 ]                                 ctrl_araddr         ,
    output logic [          8-1:0 ]                                 ctrl_arlen          ,
    input  logic                                                    ctrl_arready        ,
    input  logic                                                    ctrl_rvalid         ,
    input  logic [NUM_R_BRDG-1:0][DATA_WIDTH-1:0]                   ctrl_rdata          ,
    input  logic                                                    ctrl_rlast          ,
    // output logic                                                    ctrl_rready         ,   // currently no use (cuz always ready)

    // 16 pairs of AXI4 master "write" interface, will be connected to "write_bridge"
    output logic                                                    ctrl_awvalid        ,
    output logic [ ADDR_WIDTH-1:0 ]                                 ctrl_awaddr         ,
    output logic [          8-1:0 ]                                 ctrl_awlen          ,
    input  logic                                                    ctrl_awready        ,
    output logic                                                    ctrl_wvalid         ,
    output logic [NUM_W_BRDG-1:0][DATA_WIDTH-1:0]                   ctrl_wdata          ,
    input  logic                                                    ctrl_wready         
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------

// vectorEngine
localparam ATREE_WIDTH       = 25                   ;   // 18 + log2(128)
localparam VERIF_EN          = 0                    ;   // DW02_tree parameter
localparam VEC_LEN           = 128                  ;   // should not be modified, fixed !!
localparam WIDTH             = 8                    ;   // data width
localparam MULT_WIDTH        = 18                   ;   // (WIDTH + 1) + (WIDTH + 1)
localparam NUM_PE_WM         = 2048                 ;   // total PE
localparam NUM_PE_AM         = 1024                 ;   // no use, just a reminder
localparam NUM_PE_HP         = 1024                 ;   // no use, just a reminder
localparam NUM_VEC           = NUM_PE_WM / VEC_LEN  ;   // 16       ( 2048 / 128 )

//------------------------- operation Type ------------------------- 

/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////

logic user_start;
logic user_done;

// vectorEngine
logic                                   ve_op_valid         ;
logic [1:0]                             ve_op_type          ;
logic                                   ve_in_valid         ;
logic [NUM_PE_WM-1:0][WIDTH-1:0]        ve_in_data          ;
logic [WIDTH-1:0]                       ve_z_i              ;
logic                                   ve_weight_valid     ; 
logic [NUM_PE_WM-1:0][WIDTH-1:0]        ve_weight_data      ;
logic [NUM_PE_WM-1:0][WIDTH-1:0]        ve_z_w              ;
logic                                   ve_out_hp_valid     ;
logic [NUM_PE_HP-1:0][MULT_WIDTH-1:0]   ve_out_hp_data      ;
logic                                   ve_out_valid        ;
logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]    ve_out0             ;
logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]    ve_out1             ;
logic                                   ve_outsum_valid     ;
logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]    ve_out              ;

// accumulator
logic                                   accu_in_last        ;
logic                                   accu_in_valid       ;
logic [256-1:0][32-1:0]                 accu_in_data0       ;
logic [256-1:0][32-1:0]                 accu_in_data1       ;
logic                                   accu_out_last       ;
logic                                   accu_out_valid      ;
logic [256-1:0][32-1:0]                 accu_out_acc        ;

// highPrecEngine
logic                                   hpe_in_valid        ;
logic [NUM_QUANT-1:0][32-1:0]           hpe_in_data0        ;
logic [NUM_QUANT-1:0][32-1:0]           hpe_in_data1        ;
logic                                   hpe_shift_valid     ;
logic [NUM_QUANT-1:0][ 8-1:0]           hpe_shift           ;
logic                                   hpe_z_o_valid       ;
logic [NUM_QUANT-1:0][32-1:0]           hpe_z_o             ;
logic                                   hpe_psum_valid      ;
logic [32-1:0]                          hpe_psum0           ;
logic [32-1:0]                          hpe_psum1           ;
logic                                   hpe_ms_outvalid     ;
logic [NUM_QUANT-1:0][32-1:0]           hpe_ms_out          ;
logic                                   hpe_msz_outvalid    ;
logic [NUM_QUANT-1:0][32-1:0]           hpe_msz_out         ;

/////////////////////////////////////////////////////////////////////////
// Macro Instantiations
/////////////////////////////////////////////////////////////////////////

controller u_controller (
    .clk                ( clk    ),
    .resetn             ( resetn ),

    .instruction_ready  ( instruction_ready ),
    .instruction_valid  ( instruction_valid ),
    .instruction        ( instruction       ),

    .ctrl_arvalid       ( ctrl_arvalid      ),
    .ctrl_araddr        ( ctrl_araddr       ),
    .ctrl_arlen         ( ctrl_arlen        ),
    .ctrl_arready       ( ctrl_arready      ),
    .ctrl_rvalid        ( ctrl_rvalid       ),
    .ctrl_rdata         ( ctrl_rdata        ),
    .ctrl_rlast         ( ctrl_rlast        ),

    .ctrl_awvalid       ( ctrl_awvalid      ),
    .ctrl_awaddr        ( ctrl_awaddr       ),
    .ctrl_awlen         ( ctrl_awlen        ),
    .ctrl_awready       ( ctrl_awready      ),
    .ctrl_wvalid        ( ctrl_wvalid       ),
    .ctrl_wdata         ( ctrl_wdata        ),
    .ctrl_wready        ( ctrl_wready       ),


    .ve_op_valid        ( ve_op_valid       ),
    .ve_op_type         ( ve_op_type        ),
    .ve_in_valid        ( ve_in_valid       ),
    .ve_in_data         ( ve_in_data        ),
    .ve_z_i             ( ve_z_i            ),
    .ve_weight_valid    ( ve_weight_valid   ),
    .ve_weight_data     ( ve_weight_data    ),
    .ve_z_w             ( ve_z_w            ),
    .ve_out_hp_valid    ( ve_out_hp_valid   ),
    .ve_out_hp_data     ( ve_out_hp_data    ),
    .ve_out_valid       ( ve_out_valid      ),
    .ve_out0            ( ve_out0           ),
    .ve_out1            ( ve_out1           ),
    .ve_outsum_valid    ( ve_outsum_valid   ),
    .ve_out             ( ve_out            ),

    .accu_in_last       ( accu_in_last      ),
    .accu_in_valid      ( accu_in_valid     ),
    .accu_in_data0      ( accu_in_data0     ),
    .accu_in_data1      ( accu_in_data1     ),
    .accu_out_last      ( accu_out_last     ),
    .accu_out_valid     ( accu_out_valid    ),
    .accu_out_acc       ( accu_out_acc      ),

    .hpe_in_valid       ( hpe_in_valid      ),
    .hpe_in_data0       ( hpe_in_data0      ),
    .hpe_in_data1       ( hpe_in_data1      ),
    .hpe_shift_valid    ( hpe_shift_valid   ),
    .hpe_shift          ( hpe_shift         ),
    .hpe_z_o_valid      ( hpe_z_o_valid     ),
    .hpe_z_o            ( hpe_z_o           ),
    .hpe_psum_valid     ( hpe_psum_valid    ),
    .hpe_psum0          ( hpe_psum0         ),
    .hpe_psum1          ( hpe_psum1         ),
    .hpe_ms_outvalid    ( hpe_ms_outvalid   ),
    .hpe_ms_out         ( hpe_ms_out        ),
    .hpe_msz_outvalid   ( hpe_msz_outvalid  ),
    .hpe_msz_out        ( hpe_msz_out       )
);


vectorEngine u_vectorEngine (
    .clk            ( clk    ),
    .resetn         ( resetn ),

    .op_valid       (ve_op_valid),
    .op_type        (ve_op_type),

    .in_valid       (ve_in_valid),
    .in_data        (ve_in_data),
    .z_i            (ve_z_i),

    .weight_valid   (ve_weight_valid),
    .weight_data    (ve_weight_data),
    .z_w            (ve_z_w),

    .out_hp_valid   (ve_out_hp_valid),
    .out_hp_data    (ve_out_hp_data),

    .out_valid      (ve_out_valid),
    .out0           (ve_out0),
    .out1           (ve_out1),
    .outsum_valid   (ve_outsum_valid),
    .out            (ve_out)
);


accumulator u_accumulator (
    .clk            ( clk    ),
    .resetn         ( resetn ),

    .in_last        (accu_in_last),
    .in_valid       (accu_in_valid),
    .in_data0       (accu_in_data0),
    .in_data1       (accu_in_data1),

    .out_last       (accu_out_last),
    .out_valid      (accu_out_valid),
    .out_acc        (accu_out_acc)
);


highPrecEngine u_highPrecEngine (
    .clk            ( clk    ),
    .resetn         ( resetn ),

    .in_valid       (),
    .in_data0       (),
    .in_data1       (),
    
    .shift_valid    (),
    .shift          (),
    .z_o_valid      (),
    .z_o            (),

    .psum_valid     (),
    .psum0          (),
    .psum1          (),

    .ms_outvalid    (),
    .ms_out         (),

    .msz_outvalid   (),
    .msz_out        ()
);

// UniActivation u_nonLinear ();


/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////


endmodule
