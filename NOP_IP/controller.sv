// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : controller.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          VERSION     DESCRIPTION                             SYN_AREA        SYN_CLK_PERIOD
// 1.0     2024-06-25   Lyu-Ming Ho     v1.0        create this file
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// -----------------------------------------------------------------------------

module controller #(
    parameter NUM_R_BRDG        = 32    ,
    parameter NUM_W_BRDG        = 16    ,
    parameter INST_WIDTH        = 512   ,
    parameter ADDR_WIDTH        = 64    ,
    parameter DATA_WIDTH        = 512   ,

    // highPrecEngine
    parameter NUM_QUANT         = 256   ,                   // highPrecEngine number of multiplication

    // vectorEngine
    parameter ATREE_WIDTH       = 25    ,                   // 18 + log2(128)
    parameter VEC_LEN           = 128   ,                   // should not be modified, fixed !!
    parameter WIDTH             = 8     ,                   // data width
    parameter MULT_WIDTH        = 18    ,                   // (WIDTH + 1) + (WIDTH + 1)
    parameter NUM_PE_WM         = 2048  ,                   // total PE
    parameter NUM_PE_AM         = 1024  ,                   // no use, just a reminder
    parameter NUM_PE_HP         = 1024  ,                   // no use, just a reminder
    parameter NUM_VEC           = NUM_PE_WM / VEC_LEN       // 16       ( 2048 / 128 )
) (
    input  logic                                    clk                 ,
    input  logic                                    resetn              ,   // synchrous active-low reset

    // instructionQueue
    input  logic [           256-1:0 ]              instruction         ,
    input  logic                                    instruction_valid   ,
    output logic                                    instruction_ready   ,

    // read_bridge
    output logic                                    ctrl_arvalid        ,
    output logic [ ADDR_WIDTH-1:0 ]                 ctrl_araddr         ,
    output logic [          8-1:0 ]                 ctrl_arlen          ,
    input  logic                                    ctrl_arready        ,
    input  logic                                    ctrl_rvalid         ,
    input  logic [NUM_R_BRDG-1:0][DATA_WIDTH-1:0]   ctrl_rdata          ,
    input  logic                                    ctrl_rlast          ,

    // write_bridge
    output logic                                    ctrl_awvalid        ,
    output logic [ ADDR_WIDTH-1:0 ]                 ctrl_awaddr         ,
    output logic [          8-1:0 ]                 ctrl_awlen          ,
    input  logic                                    ctrl_awready        ,
    output logic                                    ctrl_wvalid         ,
    output logic [NUM_W_BRDG-1:0][DATA_WIDTH-1:0]   ctrl_wdata          ,
    input  logic                                    ctrl_wready         ,

    // vectorEngine
    output logic                                    ve_op_valid         ,
    output logic [1:0]                              ve_op_type          ,
    output logic                                    ve_in_valid         ,
    output logic [NUM_PE_WM-1:0][WIDTH-1:0]         ve_in_data          ,
    output logic [WIDTH-1:0]                        ve_z_i              ,
    output logic                                    ve_weight_valid     , 
    output logic [NUM_PE_WM-1:0][WIDTH-1:0]         ve_weight_data      ,
    output logic [NUM_PE_WM-1:0][WIDTH-1:0]         ve_z_w              ,
    input  logic                                    ve_out_hp_valid     ,
    input  logic [NUM_PE_HP-1:0][MULT_WIDTH-1:0]    ve_out_hp_data      ,
    input  logic                                    ve_out_valid        ,
    input  logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]     ve_out0             ,
    input  logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]     ve_out1             ,
    input  logic                                    ve_outsum_valid     ,
    input  logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]     ve_out              ,

    // accumulator
    output logic                                    accu_in_last        ,
    output logic                                    accu_in_valid       ,
    output logic [256-1:0][32-1:0]                  accu_in_data0       ,
    output logic [256-1:0][32-1:0]                  accu_in_data1       ,
    input  logic                                    accu_out_last       ,
    input  logic                                    accu_out_valid      ,
    input  logic [256-1:0][32-1:0]                  accu_out_acc        ,

    // highPrecEngine
    output logic                                    hpe_in_valid        ,
    output logic [NUM_QUANT-1:0][32-1:0]            hpe_in_data0        ,
    output logic [NUM_QUANT-1:0][32-1:0]            hpe_in_data1        ,
    output logic                                    hpe_shift_valid     ,
    output logic [NUM_QUANT-1:0][ 8-1:0]            hpe_shift           ,
    output logic                                    hpe_z_o_valid       ,
    output logic [NUM_QUANT-1:0][32-1:0]            hpe_z_o             ,
    input  logic                                    hpe_psum_valid      ,
    input  logic [32-1:0]                           hpe_psum0           ,
    input  logic [32-1:0]                           hpe_psum1           ,
    input  logic                                    hpe_ms_outvalid     ,
    input  logic [NUM_QUANT-1:0][32-1:0]            hpe_ms_out          ,
    input  logic                                    hpe_msz_outvalid    ,
    input  logic [NUM_QUANT-1:0][32-1:0]            hpe_msz_out         
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------
typedef enum logic [5:0] { 
    CORE_IDLE, CORE_EXE
} CORE_ST;     // instruction execution progress, a.k.a top state

typedef enum logic [5:0] { 
    EXE_IDLE    ,
    EXE_START   ,
    EXE_DONE
} EXE_ST;

//------------------------- Instruction Decode -------------------------
typedef enum logic [4-1:0] {
    NOP         ,   // No operation, for multi-batch use
    LOAD        ,   // Load activation, Z_w, bias, M+S, Z_o, residual
    STORE       ,
    MLP_WM      ,   // Mode 1 vectorEngine
    MLP_AM      ,   // Mode 2 vectorEngine
    MLP_HP      ,   // Mode 3 vectorEngine
    MLP_WM_WOQ  ,   // Linear2, Output FC, mode 1 vectorEngine
    MLP_HP_WOA  ,   // product gating before Linear2
    RMSNORM     ,
    SILU        ,
    SOFTMAX     ,
    RESIDUAL    ,
    ROPE        ,
    QUANT       
} operation_t;

typedef enum logic [3-1:0] {
                // (words)  x (width byte), area(*10,000)   usage (sram content)
    type1   ,   // 16       x 1K            46.7            activation
    type2   ,   // 176      x 64            5.82            zw, zo, 8-bit-result
    type3   ,   // 344      x 64            8.85            M+S, 16-bit-result
    type4       // 688      x 64            16.4            bias
} mem_type_t;

typedef struct packed {
    mem_type_t          mem_type;
    logic       [4-1:0] id      ;
} config_t;

typedef enum logic {
    SUM ,
    GEN
} stage_t;

localparam DRAM_ADDR_BIT = 29;  // 512 MB (each HBM size) --> 29-bit
localparam DIMENTION_BIT = 14;  // 11008

typedef struct packed {
    operation_t                             operation       ;
    config_t                                input_src       ;   // in_sram_config
    config_t                                weight_src      ;   // weight_sram_config
    config_t                                zw_src          ;   // z_w_sram_config
    config_t                                ms_src          ;   // MS_sram_config
    config_t                                zo_src          ;   // z_o_sram_config
    config_t                                output_dst      ;   // out_sram_config
    logic                                   bias_enable     ;   // indicate MLP_WM need to accumulate with "bias_delta" or not
    logic           [DRAM_ADDR_BIT-1:0]     input_addr      ;   // in_dram_offset_addr
    logic           [DRAM_ADDR_BIT-1:0]     output_addr     ;   // out_dram_offset_addr
    logic           [8-1:0]                 z_i             ;
    logic           [12-1:0]                current_token   ;
    stage_t                                 stage           ;   // summarization or generation
    logic           [DIMENTION_BIT-1:0]     input_dim       ;
    logic           [DIMENTION_BIT-1:0]     output_dim      ;
} instruction_t;


/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////
EXE_ST          exe_state,  exe_nstate  ;

//---------------- instruction related & top-level (core-level) fsm ----------------
CORE_ST         core_state, core_nstate ;
logic           inst_hs;

//-------------------- execution-level fsm (functional-level) --------------------

//------------------------- Instruction Decode -------------------------
instruction_t   inst;


/////////////////////////////////////////////////////////////////////////
// Macro Instantiations
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

//---------------- instruction related & top-level (core-level) fsm ----------------
assign inst_hs              = (instruction_ready & instruction_valid);
assign instruction_ready    = (core_state == CORE_IDLE);

always @(*) begin
    case (core_state)
        CORE_IDLE   :   core_nstate = (inst_hs)                 ? CORE_EXE  : CORE_IDLE;
        CORE_EXE    :   core_nstate = (exe_state == EXE_DONE)   ? CORE_IDLE : CORE_EXE;
        default     :   core_nstate = core_state;
    endcase
end

always @(posedge clk) begin
    if (!resetn)    core_state <= CORE_IDLE;
    else            core_state <= core_nstate; 
end

always @(posedge clk) begin
    if      (!resetn)   inst <= 0;
    else if (inst_hs)   inst <= instruction;
end


//-------------------- execution-level fsm (functional-level) --------------------
always @(*) begin
    case (exe_state)
        EXE_IDLE    : begin
            if (core_state == CORE_EXE) begin
                case (inst.operation)
                    NOP     : exe_nstate = EXE_DONE;
                    // ... fixme
                    default : exe_nstate = exe_state;
                endcase
            end
            else
                exe_nstate = EXE_IDLE;
        end 
        // each operation state
        EXE_DONE    :   exe_nstate = EXE_IDLE;  
        default     :   exe_nstate = EXE_IDLE;
    endcase
end

always @(posedge clk) begin
    if (!resetn)    exe_state <= EXE_IDLE;
    else            exe_state <= exe_nstate;
end



//------------------------- vectorEngine -------------------------



//------------------------- accumulator -------------------------


endmodule
