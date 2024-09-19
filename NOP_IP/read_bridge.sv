// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : read_bridge.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-07-09   Lyu-Ming Ho     
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// -----------------------------------------------------------------------------


module read_bridge #(
    parameter integer NUM_BRIDGE            = 32    ,
    parameter integer C_M_AXI_ADDR_WIDTH    = 64    ,
    parameter integer C_M_AXI_DATA_WIDTH    = 512   
) (
    input  logic                                            clk             ,
    input  logic                                            resetn          ,

    // from instructionQueue side
    input  logic                                            instQ_arvalid   ,
    input  logic [ C_M_AXI_ADDR_WIDTH-1:0 ]                 instQ_araddr    ,
    input  logic [                  8-1:0 ]                 instQ_arlen     ,
    output logic                                            instQ_arready   ,

    output logic                                            instQ_rvalid    ,
    output logic [C_M_AXI_DATA_WIDTH-1:0]                   instQ_rdata     ,
    output logic                                            instQ_rlast     ,
    input  logic                                            instQ_rready    ,
    
    // from controller side (request 32*512 bit data)
    input  logic                                            ctrl_arvalid    ,
    input  logic [ C_M_AXI_ADDR_WIDTH-1:0 ]                 ctrl_araddr     ,
    input  logic [                  8-1:0 ]                 ctrl_arlen      ,
    output logic                                            ctrl_arready    ,

    output logic                                            ctrl_rvalid     ,
    output logic [NUM_BRIDGE-1:0][C_M_AXI_DATA_WIDTH-1:0]   ctrl_rdata      ,
    output logic                                            ctrl_rlast      ,

    // actual 32 hbm side (axi-full interface), fpga side
    output logic [NUM_BRIDGE-1:0]                           arvalid         ,
    output logic [NUM_BRIDGE-1:0][C_M_AXI_ADDR_WIDTH-1:0]   araddr          ,
    output logic [NUM_BRIDGE-1:0][8-1:0]                    arlen           ,
    input  logic [NUM_BRIDGE-1:0]                           arready         ,
    
    input  logic [NUM_BRIDGE-1:0]                           rvalid          ,
    input  logic [NUM_BRIDGE-1:0][C_M_AXI_DATA_WIDTH-1:0]   rdata           ,
    input  logic [NUM_BRIDGE-1:0]                           rlast           ,
    output logic [NUM_BRIDGE-1:0]                           rready          ,

    // from axi slave registers
    input  logic [NUM_BRIDGE-1:0][C_M_AXI_ADDR_WIDTH-1:0]   read_base_addr  
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------
typedef enum logic [3:0] { IDLE, READ_INST, READ_CONFIG, READ_START, READ_DATA } READ_BRDG_STATE;

typedef enum logic [3:0] { RIDLE, RADDR, RDATA, INSTRADDR, INSTRDATA }  AXIR_STATE;

/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////
READ_BRDG_STATE bridge_state, bridge_nstate;

AXIR_STATE rstate [0:NUM_BRIDGE-1], n_rstate [0:NUM_BRIDGE-1] ;

logic ar_hs [0:NUM_BRIDGE-1], r_hs [0:NUM_BRIDGE-1] ;

logic [C_M_AXI_ADDR_WIDTH-1:0]  addr;
logic [8-1:0]                   len;

// logic intf_all_idle;

logic [NUM_BRIDGE-1:0]                          fifo_winc;
logic [NUM_BRIDGE-1:0]                          fifo_wfull;
logic [NUM_BRIDGE-1:0][C_M_AXI_DATA_WIDTH-1:0]  fifo_wdata;
logic [NUM_BRIDGE-1:0]                          fifo_rinc;
logic [NUM_BRIDGE-1:0][C_M_AXI_DATA_WIDTH-1:0]  fifo_rdata;
logic [NUM_BRIDGE-1:0]                          fifo_rempty;
logic [NUM_BRIDGE-1:0]                          fifo_rvalid;

logic read_req;

logic [8-1:0] data_counter;

/////////////////////////////////////////////////////////////////////////
// Macro Instantiations
/////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

assign ctrl_arready = (bridge_state == READ_CONFIG);

always @(*) begin
    case (bridge_state)
        IDLE        :   begin
            if      (instQ_arvalid) bridge_nstate = READ_INST;
            else if (ctrl_arvalid)  bridge_nstate = READ_CONFIG;
            else                    bridge_nstate = IDLE;
        end

        READ_INST   :   begin
            if      (rlast[0] && r_hs[0])   bridge_nstate = IDLE;
            else                            bridge_nstate = READ_INST;
        end

        READ_CONFIG :   bridge_nstate = READ_START;
        READ_START  :   bridge_nstate = READ_DATA;
        READ_DATA   :   begin
            if      (ctrl_rlast && ctrl_rvalid) bridge_nstate = IDLE;
            else                                bridge_nstate = READ_DATA;
        end

        default     :   bridge_nstate = IDLE;
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
    else if (bridge_state == READ_CONFIG) begin
        addr    <= ctrl_araddr;
        len     <= ctrl_arlen;
    end
end

// always @(*) begin
//     intf_all_idle = 1;
//     for (int i=0; i<NUM_BRIDGE; i=i+1) begin
//         intf_all_idle = intf_all_idle && (rstate[i] == RIDLE);
//     end
// end


// actual 32 hbm axi-full interface
generate 
for (genvar ii=0; ii<NUM_BRIDGE; ii=ii+1) begin: hbm_bridge

    lmho_fifo_std #(.WIDTH(512), .WORDS(4)) read_fifo (
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

    assign fifo_winc [ii]   = (rstate[ii] == RDATA) ? r_hs[ii] : 0;
    assign fifo_wdata[ii]   = rdata[ii];
    assign fifo_rinc [ii]   = read_req;

    assign ar_hs  [ii] = (arvalid[ii] & arready[ii]);
    assign r_hs   [ii] = (rready[ii] & rvalid[ii]);

    always @(*) begin
        case (rstate[ii])
            RIDLE : begin
                if      (bridge_state == READ_INST)     n_rstate[ii] = INSTRADDR;
                else if (bridge_state == READ_START)    n_rstate[ii] = RADDR;
                else                                    n_rstate[ii] = RIDLE;
            end

            INSTRADDR : n_rstate[ii] = (ar_hs[0])               ? INSTRDATA : INSTRADDR;
            INSTRDATA : n_rstate[ii] = (r_hs[0] && rlast[0])    ? RIDLE     : INSTRDATA;

            RADDR :     n_rstate[ii] = (ar_hs[ii])              ? RDATA     : RADDR;
            RDATA :     n_rstate[ii] = (r_hs[ii] && rlast[ii])  ? RIDLE     : RDATA;
        endcase
    end

    always @(posedge clk or negedge resetn) begin
        if (!resetn)    rstate[ii] <= RIDLE;
        else            rstate[ii] <= n_rstate[ii];
    end

    if (ii == 0) begin
        // Channel: address read
        always @(*) begin
            if (rstate[ii] == INSTRADDR) begin
                arvalid[ii] = instQ_arvalid;
                arlen  [ii] = instQ_arlen;
                araddr [ii] = instQ_araddr;
            end
            else if (rstate[ii] == RADDR) begin
                arvalid[ii] = 1;
                arlen  [ii] = len;
                araddr [ii] = addr[31:0] + read_base_addr[ii][31:0];
            end
            else begin
                arvalid[ii] = 0;
                arlen  [ii] = 0;
                araddr [ii] = 0;
            end
        end

        // Channel: read data
        always @(*) begin
            if      (rstate[ii] == INSTRDATA)   rready[ii] = instQ_rready; 
            else if (rstate[ii] == RDATA)       rready[ii] = !fifo_wfull[ii];
            else                                rready[ii] = 0;
        end
    end
    else begin
        // Channel: address read
        always @(*) begin
            if (rstate[ii] == RADDR) begin
                arvalid[ii] = 1;
                arlen  [ii] = len;
                araddr [ii] = addr[31:0] + read_base_addr[ii][31:0];
            end
            else begin
                arvalid[ii] = 0;
                arlen  [ii] = 0;
                araddr [ii] = 0;
            end
        end

        // Channel: read data
        always @(*) begin
            if (rstate[ii] == RDATA)    rready[ii] = !fifo_wfull[ii];
            else                        rready[ii] = 0;
        end
    end
end
endgenerate


always @(*) begin
    read_req = 1;
    for (int i=0; i<NUM_BRIDGE; i=i+1)  
        read_req = read_req & (!fifo_rempty[i]);
end

always @(posedge clk) begin
    if (!resetn)    ctrl_rvalid <= 0;
    else            ctrl_rvalid <= read_req;
end

always @(*) begin
    for (int i=0; i<NUM_BRIDGE; i=i+1)
        ctrl_rdata[i] = fifo_rdata[i];
end

always @(*) begin
    if (rstate[0] == INSTRDATA) begin
        instQ_rvalid = rvalid[0];
        instQ_rdata  = rdata[0];
        instQ_rlast  = rlast[0];
    end
    else begin
        instQ_rvalid = 0;
        instQ_rdata  = 0;
        instQ_rlast  = 0;
    end
end

assign instQ_arready = (rstate[0] == INSTRADDR) ? arready[0] : 0;

always @(posedge clk) begin
    if (!resetn)    
        data_counter <= 0;
    else if (ctrl_rvalid) begin
        if (data_counter == len)    data_counter <= 0;
        else                        data_counter <= data_counter + 1;
    end
end

// we only care only 1 hbm_bridge's state, cuz every rstate[i] should be the same
assign ctrl_rlast = (data_counter == len && bridge_state == READ_DATA);


endmodule
