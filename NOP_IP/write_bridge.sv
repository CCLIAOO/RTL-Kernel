// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : write_bridge.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-07-10   Lyu-Ming Ho     
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// -----------------------------------------------------------------------------


module write_bridge #(
    parameter integer NUM_BRIDGE            = 16    ,
    parameter integer C_M_AXI_ADDR_WIDTH    = 64    ,
    parameter integer C_M_AXI_DATA_WIDTH    = 512   
) (
    input  logic                                            clk         ,
    input  logic                                            resetn      ,
    
    // from controller side
    input  logic                                            ctrl_awvalid,
    input  logic [ C_M_AXI_ADDR_WIDTH-1:0 ]                 ctrl_awaddr ,
    input  logic [                  8-1:0 ]                 ctrl_awlen  ,
    output logic                                            ctrl_awready,
    input  logic                                            ctrl_wvalid ,
    input  logic [NUM_BRIDGE-1:0][C_M_AXI_DATA_WIDTH-1:0]   ctrl_wdata  ,
    output logic                                            ctrl_wready ,

    // actual 32 hbm side
    output logic [NUM_BRIDGE-1:0]                           awvalid     ,
    output logic [NUM_BRIDGE-1:0][C_M_AXI_ADDR_WIDTH-1:0]   awaddr      ,
    output logic [NUM_BRIDGE-1:0][8-1:0]                    awlen       ,
    input  logic [NUM_BRIDGE-1:0]                           awready     ,
    output logic [NUM_BRIDGE-1:0]                           wvalid      ,
    output logic [NUM_BRIDGE-1:0][C_M_AXI_DATA_WIDTH-1:0]   wdata       ,
    output logic [NUM_BRIDGE-1:0]                           wlast       ,
    input  logic [NUM_BRIDGE-1:0]                           wready      ,

    // from axi slave registers
    input  logic [NUM_BRIDGE-1:0][C_M_AXI_ADDR_WIDTH-1:0]   write_base_addr 
);

/////////////////////////////////////////////////////////////////////////   
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------
typedef enum logic [3:0] { IDLE, WRITE_CONFIG, WRITE_START, WRITE_DATA } WRITE_BRDG_STATE;

typedef enum logic [3:0] { WIDLE, WADDR, WDATA } AXIW_STATE;

//------------------------- operation Type ------------------------- 

//------------------------- DW02 Param -------------------------

//------------------------- Adder Tree -------------------------

/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////
WRITE_BRDG_STATE bridge_state, bridge_nstate;

AXIW_STATE wstate [0:NUM_BRIDGE-1], n_wstate [0:NUM_BRIDGE-1];

logic aw_hs [0:NUM_BRIDGE-1], w_hs [0:NUM_BRIDGE-1];

logic [C_M_AXI_ADDR_WIDTH-1:0]  addr;
logic [8-1:0]                   len;

logic intf_all_idle;

logic [NUM_BRIDGE-1:0]          fifo_winc;
logic [NUM_BRIDGE-1:0]          fifo_wfull;
logic [NUM_BRIDGE-1:0][512-1:0] fifo_wdata;
logic [NUM_BRIDGE-1:0]          fifo_rinc;
logic [NUM_BRIDGE-1:0][512-1:0] fifo_rdata;
logic [NUM_BRIDGE-1:0]          fifo_rempty;
logic [NUM_BRIDGE-1:0]          fifo_rvalid;

/////////////////////////////////////////////////////////////////////////
// Macro Instantiations
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

assign ctrl_awready = (bridge_state == WRITE_CONFIG);

always @(*) begin
    case (bridge_state)
        IDLE            :   bridge_nstate = (ctrl_awvalid)                  ? WRITE_CONFIG : IDLE;
        WRITE_CONFIG    :   bridge_nstate = (ctrl_awvalid && ctrl_awready)  ? WRITE_START : WRITE_CONFIG;
        WRITE_START     :   bridge_nstate = WRITE_DATA;
        WRITE_DATA      :   bridge_nstate = (intf_all_idle)                 ? IDLE : WRITE_DATA;
        default         :   bridge_nstate = IDLE;
    endcase
end

always @(posedge clk) begin
    if (!resetn)    bridge_state <= IDLE;
    else            bridge_state <= bridge_nstate;
end


always @(posedge clk) begin
    if (!resetn) begin
        addr    <= 0;
        len     <= 0;
    end
    else if (bridge_state == WRITE_CONFIG) begin
        addr    <= ctrl_awaddr;
        len     <= ctrl_awlen;
    end
end

always @(*) begin
    intf_all_idle = 1;
    for (int i=0; i<NUM_BRIDGE; i=i+1) begin
        intf_all_idle = intf_all_idle && (wstate[i] == WIDLE);
    end
end


generate
for (genvar ii=0; ii<NUM_BRIDGE; ii=ii+1) begin: hbm_bridge

    logic [7:0] write_counter;

    assign aw_hs[ii]        = awvalid[ii] & awready[ii];
    assign w_hs[ii]         = wvalid[ii] & wready[ii];

    assign awvalid[ii]      = (wstate[ii] == WADDR);
    assign awaddr[ii]       = addr + write_base_addr[ii][0 +: 34]; // fixme check bit num, assume we only need the lower 34 bit of write_base_addr
    assign awlen[ii]        = len;

    assign wvalid[ii]       = (wstate[ii] == WDATA && !fifo_rempty[ii]);
    assign wdata[ii]        = (wvalid[ii]) ? fifo_rdata[ii] : 0;        // fixme, could simply be fifo_rdata[ii], but it's more easier to debug now
    assign wlast[ii]        = (write_counter == len && wvalid[ii]);

    assign fifo_winc[ii]    = ctrl_wvalid & ctrl_wready;
    assign fifo_wdata[ii]   = ctrl_wdata[ii];
    assign fifo_rinc[ii]    = w_hs[ii];

    lmho_fifo_fwft #(.WIDTH(512), .WORDS(4)) write_fifo (
        .clk    (clk),
        .resetn (resetn),
        .winc   (fifo_winc[ii]),
        .wdata  (fifo_wdata[ii]),
        .wfull  (fifo_wfull[ii]),
        .rinc   (fifo_rinc[ii]),
        .rdata  (fifo_rdata[ii]),
        .rempty (fifo_rempty[ii]),
        .rvalid (fifo_rvalid[ii])
    );

    always @(posedge clk) begin
        if      (!resetn)               write_counter <= 0;
        else if (wstate[ii] == WIDLE)   write_counter <= 0;
        else if (w_hs[ii])              write_counter <= write_counter + 1;
    end

    always @(*) begin
        case (wstate[ii])
            WIDLE   :   n_wstate[ii] = (bridge_state == WRITE_START)    ? WADDR : WIDLE;
            WADDR   :   n_wstate[ii] = (aw_hs[ii])                      ? WDATA : WADDR;
            WDATA   :   n_wstate[ii] = (w_hs[ii] && wlast[ii])          ? WIDLE : WDATA;
            default :   n_wstate[ii] = WIDLE;
        endcase
    end

    always @(posedge clk) begin
        if (!resetn)    wstate[ii] <= WIDLE;
        else            wstate[ii] <= n_wstate[ii];
    end
end
endgenerate

always @(*) begin
    ctrl_wready = 1;
    for (int i=0; i<NUM_BRIDGE; i=i+1) begin
        ctrl_wready = ctrl_wready & ~fifo_wfull[i];
    end
end


endmodule
