// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : control_s_axi.sv 
// AUTHOR       : Cheng-Chia Liao
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-09-12   Cheng-Chia Liao   
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// -----------------------------------------------------------------------------


module control_s_axi#(
parameter   C_S_AXI_ADDR_WIDTH = 12,
parameter   C_S_AXI_DATA_WIDTH = 32,
parameter   NUM_BRDG           = 32
)(
    input                                   ACLK     ,
    input                                   ARESET_N ,
    input                                   ACLK_EN  ,
    input        [C_S_AXI_ADDR_WIDTH-1:0]   AWADDR   ,
    input                                   AWVALID  ,
    output logic                            AWREADY  ,
    input        [C_S_AXI_DATA_WIDTH-1:0]   WDATA    ,
    input        [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB    ,
    input                                   WVALID   ,
    output logic                            WREADY   ,
    output logic [1:0]                      BRESP    ,
    output logic                            BVALID   ,
    input                                   BREADY   ,
    input        [C_S_AXI_ADDR_WIDTH-1:0]   ARADDR   ,
    input                                   ARVALID  ,
    output logic                            ARREADY  ,
    output logic [C_S_AXI_DATA_WIDTH-1:0]   RDATA    ,
    output logic [1:0]                      RRESP    ,
    output logic                            RVALID   ,
    input                                   RREADY   ,

    /////////////////////////////////////////////////////////////////////////
    // User Defined Registers. You can modify here.
    /////////////////////////////////////////////////////////////////////////
    output logic                                    user_start ,
    input                                           user_done  ,
    input                                           user_ready ,
    input                                           user_idle  ,
    output logic [NUM_BRDG-1:0][64-1:0]             hbm_read_base_addr,
    output logic [NUM_BRDG-1:0][64-1:0]             hbm_write_base_addr,
    output logic [32-1:0]                           instruction_base,
    output logic [32-1:0]                           instruction_num     
    /////////////////////////////////////////////////////////////////////////
    // End User Defined Registers 
    /////////////////////////////////////////////////////////////////////////
);


//------------------------Address Info-------------------

// 0x10 : User Control signals
//        bit 0  - user_start (Read/Write/)
//        bit 1  - user_done (Read)
//        bit 2  - user_idle (Read)

// 0x1c  : Pointer of hbm00_read_base_addr (lower 32 bits)
// 0x20  : Pointer of hbm00_read_base_addr (upper 32 bits)
// 0x24  : Pointer of hbm01_read_base_addr
// 0x28  : Pointer of hbm01_read_base_addr
// 0x2c  : Pointer of hbm02_read_base_addr
// 0x30  : Pointer of hbm02_read_base_addr
// 0x34  : Pointer of hbm03_read_base_addr
// 0x38  : Pointer of hbm03_read_base_addr
// 0x3c  : Pointer of hbm04_read_base_addr
// 0x40  : Pointer of hbm04_read_base_addr
// 0x44  : Pointer of hbm05_read_base_addr
// 0x48  : Pointer of hbm05_read_base_addr
// 0x4c  : Pointer of hbm06_read_base_addr
// 0x50  : Pointer of hbm06_read_base_addr
// 0x54  : Pointer of hbm07_read_base_addr
// 0x58  : Pointer of hbm07_read_base_addr
// 0x5c  : Pointer of hbm08_read_base_addr
// 0x60  : Pointer of hbm08_read_base_addr
// 0x64  : Pointer of hbm09_read_base_addr
// 0x68  : Pointer of hbm09_read_base_addr

// 0x6c  : Pointer of hbm10_read_base_addr
// 0x70  : Pointer of hbm10_read_base_addr
// 0x74  : Pointer of hbm11_read_base_addr
// 0x78  : Pointer of hbm11_read_base_addr
// 0x7c  : Pointer of hbm12_read_base_addr
// 0x80  : Pointer of hbm12_read_base_addr
// 0x84  : Pointer of hbm13_read_base_addr
// 0x88  : Pointer of hbm13_read_base_addr
// 0x8c  : Pointer of hbm14_read_base_addr
// 0x90  : Pointer of hbm14_read_base_addr
// 0x94  : Pointer of hbm15_read_base_addr
// 0x98  : Pointer of hbm15_read_base_addr
// 0x9c  : Pointer of hbm16_read_base_addr
// 0xa0  : Pointer of hbm16_read_base_addr
// 0xa4  : Pointer of hbm17_read_base_addr
// 0xa8  : Pointer of hbm17_read_base_addr
// 0xac  : Pointer of hbm18_read_base_addr
// 0xb0  : Pointer of hbm18_read_base_addr
// 0xb4  : Pointer of hbm19_read_base_addr
// 0xb8  : Pointer of hbm19_read_base_addr

// 0xbc  : Pointer of hbm20_read_base_addr
// 0xc0  : Pointer of hbm20_read_base_addr
// 0xc4  : Pointer of hbm21_read_base_addr
// 0xc8  : Pointer of hbm21_read_base_addr
// 0xcc  : Pointer of hbm22_read_base_addr
// 0xd0  : Pointer of hbm22_read_base_addr
// 0xd4  : Pointer of hbm23_read_base_addr
// 0xd8  : Pointer of hbm23_read_base_addr
// 0xdc  : Pointer of hbm24_read_base_addr
// 0xe0  : Pointer of hbm24_read_base_addr
// 0xe4  : Pointer of hbm25_read_base_addr
// 0xe8  : Pointer of hbm25_read_base_addr
// 0xec  : Pointer of hbm26_read_base_addr
// 0xf0  : Pointer of hbm26_read_base_addr
// 0xf4  : Pointer of hbm27_read_base_addr
// 0xf8  : Pointer of hbm27_read_base_addr
// 0xfc  : Pointer of hbm28_read_base_addr
// 0x100 : Pointer of hbm28_read_base_addr
// 0x104 : Pointer of hbm29_read_base_addr
// 0x108 : Pointer of hbm29_read_base_addr

// 0x10c : Pointer of hbm30_read_base_addr
// 0x110 : Pointer of hbm30_read_base_addr
// 0x114 : Pointer of hbm31_read_base_addr
// 0x118 : Pointer of hbm31_read_base_addr

// 0x11c : Pointer of hbm00_write_base_addr
// 0x120 : Pointer of hbm00_write_base_addr
// 0x124  : Pointer of hbm01_write_base_addr
// 0x128  : Pointer of hbm01_write_base_addr
// 0x12c  : Pointer of hbm02_write_base_addr
// 0x130  : Pointer of hbm02_write_base_addr
// 0x134  : Pointer of hbm03_write_base_addr
// 0x138  : Pointer of hbm03_write_base_addr
// 0x13c  : Pointer of hbm04_write_base_addr
// 0x140  : Pointer of hbm04_write_base_addr
// 0x144  : Pointer of hbm05_write_base_addr
// 0x148  : Pointer of hbm05_write_base_addr
// 0x14c  : Pointer of hbm06_write_base_addr
// 0x150  : Pointer of hbm06_write_base_addr
// 0x154  : Pointer of hbm07_write_base_addr
// 0x158  : Pointer of hbm07_write_base_addr
// 0x15c  : Pointer of hbm08_write_base_addr
// 0x160  : Pointer of hbm08_write_base_addr
// 0x164  : Pointer of hbm09_write_base_addr
// 0x168  : Pointer of hbm09_write_base_addr

// 0x16c  : Pointer of hbm10_write_base_addr
// 0x170  : Pointer of hbm10_write_base_addr
// 0x174  : Pointer of hbm11_write_base_addr
// 0x178  : Pointer of hbm11_write_base_addr
// 0x17c  : Pointer of hbm12_write_base_addr
// 0x180  : Pointer of hbm12_write_base_addr
// 0x184  : Pointer of hbm13_write_base_addr
// 0x188  : Pointer of hbm13_write_base_addr
// 0x18c  : Pointer of hbm14_write_base_addr
// 0x190  : Pointer of hbm14_write_base_addr
// 0x194  : Pointer of hbm15_write_base_addr
// 0x198  : Pointer of hbm15_write_base_addr
// 0x19c  : Pointer of hbm16_write_base_addr
// 0x1a0  : Pointer of hbm16_write_base_addr
// 0x1a4  : Pointer of hbm17_write_base_addr
// 0x1a8  : Pointer of hbm17_write_base_addr
// 0x1ac  : Pointer of hbm18_write_base_addr
// 0x1b0  : Pointer of hbm18_write_base_addr
// 0x1b4  : Pointer of hbm19_write_base_addr
// 0x1b8  : Pointer of hbm19_write_base_addr

// 0x1bc  : Pointer of hbm20_write_base_addr
// 0x1c0  : Pointer of hbm20_write_base_addr
// 0x1c4  : Pointer of hbm21_write_base_addr
// 0x1c8  : Pointer of hbm21_write_base_addr
// 0x1cc  : Pointer of hbm22_write_base_addr
// 0x1d0  : Pointer of hbm22_write_base_addr
// 0x1d4  : Pointer of hbm23_write_base_addr
// 0x1d8  : Pointer of hbm23_write_base_addr
// 0x1dc  : Pointer of hbm24_write_base_addr
// 0x1e0  : Pointer of hbm24_write_base_addr
// 0x1e4  : Pointer of hbm25_write_base_addr
// 0x1e8  : Pointer of hbm25_write_base_addr
// 0x1ec  : Pointer of hbm26_write_base_addr
// 0x1f0  : Pointer of hbm26_write_base_addr
// 0x1f4  : Pointer of hbm27_write_base_addr
// 0x1f8  : Pointer of hbm27_write_base_addr
// 0x1fc  : Pointer of hbm28_write_base_addr
// 0x200 : Pointer of hbm28_write_base_addr
// 0x204 : Pointer of hbm29_write_base_addr
// 0x208 : Pointer of hbm29_write_base_addr

// 0x20c : Pointer of hbm30_write_base_addr
// 0x210 : Pointer of hbm30_write_base_addr
// 0x214 : Pointer of hbm31_write_base_addr
// 0x218 : Pointer of hbm31_write_base_addr

// 0x21c : Pointer of instruction_base
// 0x220 : Pointer of instruction_base
// 0x224 : Pointer of instruction_num
// 0x228 : Pointer of instruction_num
//------------------------Parameter----------------------
localparam
    // address offset for kernet argument
    ADDR_USER_CTRL       = 6'h10,

    /////////////////////////////////////////////////////////////////////////
    // User Defined Registers Address Offset. You can modify here.
    /////////////////////////////////////////////////////////////////////////
    ADDR_HBM00_READ0     = 32'h1c ,         ADDR_HBM00_READ1     = 32'h20,
    ADDR_HBM01_READ0     = 32'h24 ,         ADDR_HBM01_READ1     = 32'h28,
    ADDR_HBM02_READ0     = 32'h2c ,         ADDR_HBM02_READ1     = 32'h30,
    ADDR_HBM03_READ0     = 32'h34 ,         ADDR_HBM03_READ1     = 32'h38,
    ADDR_HBM04_READ0     = 32'h3c ,         ADDR_HBM04_READ1     = 32'h40,
    ADDR_HBM05_READ0     = 32'h44 ,         ADDR_HBM05_READ1     = 32'h48,
    ADDR_HBM06_READ0     = 32'h4c ,         ADDR_HBM06_READ1     = 32'h50,
    ADDR_HBM07_READ0     = 32'h54 ,         ADDR_HBM07_READ1     = 32'h58,
    ADDR_HBM08_READ0     = 32'h5c ,         ADDR_HBM08_READ1     = 32'h60,
    ADDR_HBM09_READ0     = 32'h64 ,         ADDR_HBM09_READ1     = 32'h68,

    ADDR_HBM10_READ0     = 32'h6c ,         ADDR_HBM10_READ1     = 32'h70,
    ADDR_HBM11_READ0     = 32'h74 ,         ADDR_HBM11_READ1     = 32'h78,
    ADDR_HBM12_READ0     = 32'h7c ,         ADDR_HBM12_READ1     = 32'h80,
    ADDR_HBM13_READ0     = 32'h84 ,         ADDR_HBM13_READ1     = 32'h88,
    ADDR_HBM14_READ0     = 32'h8c ,         ADDR_HBM14_READ1     = 32'h90,
    ADDR_HBM15_READ0     = 32'h94 ,         ADDR_HBM15_READ1     = 32'h98,
    ADDR_HBM16_READ0     = 32'h9c ,         ADDR_HBM16_READ1     = 32'ha0,
    ADDR_HBM17_READ0     = 32'ha4 ,         ADDR_HBM17_READ1     = 32'ha8,
    ADDR_HBM18_READ0     = 32'hac ,         ADDR_HBM18_READ1     = 32'hb0,
    ADDR_HBM19_READ0     = 32'hb4 ,         ADDR_HBM19_READ1     = 32'hb8,

    ADDR_HBM20_READ0     = 32'hbc ,         ADDR_HBM20_READ1     = 32'hc0 ,
    ADDR_HBM21_READ0     = 32'hc4 ,         ADDR_HBM21_READ1     = 32'hc8 ,
    ADDR_HBM22_READ0     = 32'hcc ,         ADDR_HBM22_READ1     = 32'hd0 ,
    ADDR_HBM23_READ0     = 32'hd4 ,         ADDR_HBM23_READ1     = 32'hd8 ,
    ADDR_HBM24_READ0     = 32'hdc ,         ADDR_HBM24_READ1     = 32'he0 ,
    ADDR_HBM25_READ0     = 32'he4 ,         ADDR_HBM25_READ1     = 32'he8 ,
    ADDR_HBM26_READ0     = 32'hec ,         ADDR_HBM26_READ1     = 32'hf0 ,
    ADDR_HBM27_READ0     = 32'hf4 ,         ADDR_HBM27_READ1     = 32'hf8 ,
    ADDR_HBM28_READ0     = 32'hfc ,         ADDR_HBM28_READ1     = 32'h100,
    ADDR_HBM29_READ0     = 32'h104,         ADDR_HBM29_READ1     = 32'h108,

    ADDR_HBM30_READ0     = 32'h10c,         ADDR_HBM30_READ1     = 32'h110,
    ADDR_HBM31_READ0     = 32'h114,         ADDR_HBM31_READ1     = 32'h118,



    ADDR_HBM00_WRITE0     = 32'h11c ,       ADDR_HBM00_WRITE1     = 32'h120,
    ADDR_HBM01_WRITE0     = 32'h124 ,       ADDR_HBM01_WRITE1     = 32'h128,
    ADDR_HBM02_WRITE0     = 32'h12c ,       ADDR_HBM02_WRITE1     = 32'h130,
    ADDR_HBM03_WRITE0     = 32'h134 ,       ADDR_HBM03_WRITE1     = 32'h138,
    ADDR_HBM04_WRITE0     = 32'h13c ,       ADDR_HBM04_WRITE1     = 32'h140,
    ADDR_HBM05_WRITE0     = 32'h144 ,       ADDR_HBM05_WRITE1     = 32'h148,
    ADDR_HBM06_WRITE0     = 32'h14c ,       ADDR_HBM06_WRITE1     = 32'h150,
    ADDR_HBM07_WRITE0     = 32'h154 ,       ADDR_HBM07_WRITE1     = 32'h158,
    ADDR_HBM08_WRITE0     = 32'h15c ,       ADDR_HBM08_WRITE1     = 32'h160,
    ADDR_HBM09_WRITE0     = 32'h164 ,       ADDR_HBM09_WRITE1     = 32'h168,

    ADDR_HBM10_WRITE0     = 32'h16c ,       ADDR_HBM10_WRITE1     = 32'h170,
    ADDR_HBM11_WRITE0     = 32'h174 ,       ADDR_HBM11_WRITE1     = 32'h178,
    ADDR_HBM12_WRITE0     = 32'h17c ,       ADDR_HBM12_WRITE1     = 32'h180,
    ADDR_HBM13_WRITE0     = 32'h184 ,       ADDR_HBM13_WRITE1     = 32'h188,
    ADDR_HBM14_WRITE0     = 32'h18c ,       ADDR_HBM14_WRITE1     = 32'h190,
    ADDR_HBM15_WRITE0     = 32'h194 ,       ADDR_HBM15_WRITE1     = 32'h198,
    ADDR_HBM16_WRITE0     = 32'h19c ,       ADDR_HBM16_WRITE1     = 32'h1a0,
    ADDR_HBM17_WRITE0     = 32'h1a4 ,       ADDR_HBM17_WRITE1     = 32'h1a8,
    ADDR_HBM18_WRITE0     = 32'h1ac ,       ADDR_HBM18_WRITE1     = 32'h1b0,
    ADDR_HBM19_WRITE0     = 32'h1b4 ,       ADDR_HBM19_WRITE1     = 32'h1b8,

    ADDR_HBM20_WRITE0     = 32'h1bc ,       ADDR_HBM20_WRITE1     = 32'h1c0 ,
    ADDR_HBM21_WRITE0     = 32'h1c4 ,       ADDR_HBM21_WRITE1     = 32'h1c8 ,
    ADDR_HBM22_WRITE0     = 32'h1cc ,       ADDR_HBM22_WRITE1     = 32'h1d0 ,
    ADDR_HBM23_WRITE0     = 32'h1d4 ,       ADDR_HBM23_WRITE1     = 32'h1d8 ,
    ADDR_HBM24_WRITE0     = 32'h1dc ,       ADDR_HBM24_WRITE1     = 32'h1e0 ,
    ADDR_HBM25_WRITE0     = 32'h1e4 ,       ADDR_HBM25_WRITE1     = 32'h1e8 ,
    ADDR_HBM26_WRITE0     = 32'h1ec ,       ADDR_HBM26_WRITE1     = 32'h1f0 ,
    ADDR_HBM27_WRITE0     = 32'h1f4 ,       ADDR_HBM27_WRITE1     = 32'h1f8 ,
    ADDR_HBM28_WRITE0     = 32'h1fc ,       ADDR_HBM28_WRITE1     = 32'h200,
    ADDR_HBM29_WRITE0     = 32'h204,        ADDR_HBM29_WRITE1     = 32'h208,

    ADDR_HBM30_WRITE0     = 32'h20c,        ADDR_HBM30_WRITE1     = 32'h210,
    ADDR_HBM31_WRITE0     = 32'h214,        ADDR_HBM31_WRITE1     = 32'h218,

    INST_BASE0            = 32'h21c,        INST_BASE1            = 32'h220,
    INST_NUM0             = 32'h224,        INST_NUM1             = 32'h228,


    /////////////////////////////////////////////////////////////////////////
    // End User Defined Registers Address Offset  
    /////////////////////////////////////////////////////////////////////////
     ADDR_BITS            = C_S_AXI_ADDR_WIDTH;



//------------------------Local signal-------------------
typedef enum logic [1:0] { WRIDLE, WRDATA, WRRESP, WRRESET }    AXIW_STATE;
AXIW_STATE                      wstate;
AXIW_STATE                      wnext;
logic  [ADDR_BITS-1:0]          waddr;
logic                           aw_hs;
logic                           w_hs;

typedef enum logic [1:0] { RDIDLE, RDDATA, RDRESET }            AXIR_STATE;
AXIR_STATE                      rstate;
AXIR_STATE                      rnext;
logic  [63:0]                   rdata;
logic                           ar_hs;
logic [ADDR_BITS-1:0]           raddr;

// internal registers
logic                           int_ap_idle  ;
logic                           int_ap_done  ;
logic                           int_ap_start ;

//------------------------Instantiation------------------

//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
// assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK or negedge ARESET_N) begin
    if (!ARESET_N)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= AWADDR[ADDR_BITS-1:0];
    end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK or negedge ARESET_N) begin
    if (!ARESET_N)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 1'b0;
            case (raddr) // synopsys parallel_case // synthesis parallel_case
                /////////////////////////////////////////////////////////////////////////
                // User Defined Registers. You can modify here.
                /////////////////////////////////////////////////////////////////////////
                ADDR_USER_CTRL: begin
                    rdata[0] <= int_ap_start;
                    rdata[1] <= int_ap_done;
                    rdata[2] <= int_ap_idle;
                end
                ADDR_HBM00_READ0: rdata <= hbm_read_base_addr[00][31: 0];
                ADDR_HBM00_READ1: rdata <= hbm_read_base_addr[00][63:32];
                ADDR_HBM01_READ0: rdata <= hbm_read_base_addr[01][31: 0]; 
                ADDR_HBM01_READ1: rdata <= hbm_read_base_addr[01][63:32]; 
                ADDR_HBM02_READ0: rdata <= hbm_read_base_addr[02][31: 0]; 
                ADDR_HBM02_READ1: rdata <= hbm_read_base_addr[02][63:32]; 
                ADDR_HBM03_READ0: rdata <= hbm_read_base_addr[03][31: 0]; 
                ADDR_HBM03_READ1: rdata <= hbm_read_base_addr[03][63:32]; 
                ADDR_HBM04_READ0: rdata <= hbm_read_base_addr[04][31: 0]; 
                ADDR_HBM04_READ1: rdata <= hbm_read_base_addr[04][63:32]; 
                ADDR_HBM05_READ0: rdata <= hbm_read_base_addr[05][31: 0]; 
                ADDR_HBM05_READ1: rdata <= hbm_read_base_addr[05][63:32]; 
                ADDR_HBM06_READ0: rdata <= hbm_read_base_addr[06][31: 0]; 
                ADDR_HBM06_READ1: rdata <= hbm_read_base_addr[06][63:32]; 
                ADDR_HBM07_READ0: rdata <= hbm_read_base_addr[07][31: 0]; 
                ADDR_HBM07_READ1: rdata <= hbm_read_base_addr[07][63:32]; 
                ADDR_HBM08_READ0: rdata <= hbm_read_base_addr[08][31: 0]; 
                ADDR_HBM08_READ1: rdata <= hbm_read_base_addr[08][63:32]; 
                ADDR_HBM09_READ0: rdata <= hbm_read_base_addr[09][31: 0]; 
                ADDR_HBM09_READ1: rdata <= hbm_read_base_addr[09][63:32]; 

                ADDR_HBM10_READ0: rdata <= hbm_read_base_addr[10][31: 0];  
                ADDR_HBM10_READ1: rdata <= hbm_read_base_addr[10][63:32];  
                ADDR_HBM11_READ0: rdata <= hbm_read_base_addr[11][31: 0];  
                ADDR_HBM11_READ1: rdata <= hbm_read_base_addr[11][63:32];  
                ADDR_HBM12_READ0: rdata <= hbm_read_base_addr[12][31: 0];  
                ADDR_HBM12_READ1: rdata <= hbm_read_base_addr[12][63:32];  
                ADDR_HBM13_READ0: rdata <= hbm_read_base_addr[13][31: 0];  
                ADDR_HBM13_READ1: rdata <= hbm_read_base_addr[13][63:32];  
                ADDR_HBM14_READ0: rdata <= hbm_read_base_addr[14][31: 0];  
                ADDR_HBM14_READ1: rdata <= hbm_read_base_addr[14][63:32];  
                ADDR_HBM15_READ0: rdata <= hbm_read_base_addr[15][31: 0];  
                ADDR_HBM15_READ1: rdata <= hbm_read_base_addr[15][63:32];  
                ADDR_HBM16_READ0: rdata <= hbm_read_base_addr[16][31: 0];  
                ADDR_HBM16_READ1: rdata <= hbm_read_base_addr[16][63:32];  
                ADDR_HBM17_READ0: rdata <= hbm_read_base_addr[17][31: 0];  
                ADDR_HBM17_READ1: rdata <= hbm_read_base_addr[17][63:32];  
                ADDR_HBM18_READ0: rdata <= hbm_read_base_addr[18][31: 0];  
                ADDR_HBM18_READ1: rdata <= hbm_read_base_addr[18][63:32];  
                ADDR_HBM19_READ0: rdata <= hbm_read_base_addr[19][31: 0];  
                ADDR_HBM19_READ1: rdata <= hbm_read_base_addr[19][63:32];  

                ADDR_HBM20_READ0: rdata <= hbm_read_base_addr[20][31: 0]; 
                ADDR_HBM20_READ1: rdata <= hbm_read_base_addr[20][63:32]; 
                ADDR_HBM21_READ0: rdata <= hbm_read_base_addr[21][31: 0]; 
                ADDR_HBM21_READ1: rdata <= hbm_read_base_addr[21][63:32]; 
                ADDR_HBM22_READ0: rdata <= hbm_read_base_addr[22][31: 0]; 
                ADDR_HBM22_READ1: rdata <= hbm_read_base_addr[22][63:32]; 
                ADDR_HBM23_READ0: rdata <= hbm_read_base_addr[23][31: 0]; 
                ADDR_HBM23_READ1: rdata <= hbm_read_base_addr[23][63:32]; 
                ADDR_HBM24_READ0: rdata <= hbm_read_base_addr[24][31: 0]; 
                ADDR_HBM24_READ1: rdata <= hbm_read_base_addr[24][63:32]; 
                ADDR_HBM25_READ0: rdata <= hbm_read_base_addr[25][31: 0]; 
                ADDR_HBM25_READ1: rdata <= hbm_read_base_addr[25][63:32]; 
                ADDR_HBM26_READ0: rdata <= hbm_read_base_addr[26][31: 0]; 
                ADDR_HBM26_READ1: rdata <= hbm_read_base_addr[26][63:32]; 
                ADDR_HBM27_READ0: rdata <= hbm_read_base_addr[27][31: 0]; 
                ADDR_HBM27_READ1: rdata <= hbm_read_base_addr[27][63:32]; 
                ADDR_HBM28_READ0: rdata <= hbm_read_base_addr[28][31: 0]; 
                ADDR_HBM28_READ1: rdata <= hbm_read_base_addr[28][63:32]; 
                ADDR_HBM29_READ0: rdata <= hbm_read_base_addr[29][31: 0]; 
                ADDR_HBM29_READ1: rdata <= hbm_read_base_addr[29][63:32]; 

                ADDR_HBM30_READ0: rdata <= hbm_read_base_addr[30][31: 0]; 
                ADDR_HBM30_READ1: rdata <= hbm_read_base_addr[30][63:32]; 
                ADDR_HBM31_READ0: rdata <= hbm_read_base_addr[31][31: 0]; 
                ADDR_HBM31_READ1: rdata <= hbm_read_base_addr[31][63:32]; 



                //      write
                ADDR_HBM00_WRITE0: rdata <= hbm_write_base_addr[00][31: 0];
                ADDR_HBM00_WRITE1: rdata <= hbm_write_base_addr[00][63:32];
                ADDR_HBM01_WRITE0: rdata <= hbm_write_base_addr[01][31: 0];
                ADDR_HBM01_WRITE1: rdata <= hbm_write_base_addr[01][63:32];
                ADDR_HBM02_WRITE0: rdata <= hbm_write_base_addr[02][31: 0];
                ADDR_HBM02_WRITE1: rdata <= hbm_write_base_addr[02][63:32];
                ADDR_HBM03_WRITE0: rdata <= hbm_write_base_addr[03][31: 0];
                ADDR_HBM03_WRITE1: rdata <= hbm_write_base_addr[03][63:32];
                ADDR_HBM04_WRITE0: rdata <= hbm_write_base_addr[04][31: 0];
                ADDR_HBM04_WRITE1: rdata <= hbm_write_base_addr[04][63:32];
                ADDR_HBM05_WRITE0: rdata <= hbm_write_base_addr[05][31: 0];
                ADDR_HBM05_WRITE1: rdata <= hbm_write_base_addr[05][63:32];
                ADDR_HBM06_WRITE0: rdata <= hbm_write_base_addr[06][31: 0];
                ADDR_HBM06_WRITE1: rdata <= hbm_write_base_addr[06][63:32];
                ADDR_HBM07_WRITE0: rdata <= hbm_write_base_addr[07][31: 0];
                ADDR_HBM07_WRITE1: rdata <= hbm_write_base_addr[07][63:32];
                ADDR_HBM08_WRITE0: rdata <= hbm_write_base_addr[08][31: 0];
                ADDR_HBM08_WRITE1: rdata <= hbm_write_base_addr[08][63:32];
                ADDR_HBM09_WRITE0: rdata <= hbm_write_base_addr[09][31: 0];
                ADDR_HBM09_WRITE1: rdata <= hbm_write_base_addr[09][63:32];

                ADDR_HBM10_WRITE0: rdata <= hbm_write_base_addr[10][31: 0];
                ADDR_HBM10_WRITE1: rdata <= hbm_write_base_addr[10][63:32];
                ADDR_HBM11_WRITE0: rdata <= hbm_write_base_addr[11][31: 0];
                ADDR_HBM11_WRITE1: rdata <= hbm_write_base_addr[11][63:32];
                ADDR_HBM12_WRITE0: rdata <= hbm_write_base_addr[12][31: 0];
                ADDR_HBM12_WRITE1: rdata <= hbm_write_base_addr[12][63:32];
                ADDR_HBM13_WRITE0: rdata <= hbm_write_base_addr[13][31: 0];
                ADDR_HBM13_WRITE1: rdata <= hbm_write_base_addr[13][63:32];
                ADDR_HBM14_WRITE0: rdata <= hbm_write_base_addr[14][31: 0];
                ADDR_HBM14_WRITE1: rdata <= hbm_write_base_addr[14][63:32];
                ADDR_HBM15_WRITE0: rdata <= hbm_write_base_addr[15][31: 0];
                ADDR_HBM15_WRITE1: rdata <= hbm_write_base_addr[15][63:32];
                ADDR_HBM16_WRITE0: rdata <= hbm_write_base_addr[16][31: 0];
                ADDR_HBM16_WRITE1: rdata <= hbm_write_base_addr[16][63:32];
                ADDR_HBM17_WRITE0: rdata <= hbm_write_base_addr[17][31: 0];
                ADDR_HBM17_WRITE1: rdata <= hbm_write_base_addr[17][63:32];
                ADDR_HBM18_WRITE0: rdata <= hbm_write_base_addr[18][31: 0];
                ADDR_HBM18_WRITE1: rdata <= hbm_write_base_addr[18][63:32];
                ADDR_HBM19_WRITE0: rdata <= hbm_write_base_addr[19][31: 0];
                ADDR_HBM19_WRITE1: rdata <= hbm_write_base_addr[19][63:32];

                ADDR_HBM20_WRITE0: rdata <= hbm_write_base_addr[20][31: 0];
                ADDR_HBM20_WRITE1: rdata <= hbm_write_base_addr[20][63:32];
                ADDR_HBM21_WRITE0: rdata <= hbm_write_base_addr[21][31: 0];
                ADDR_HBM21_WRITE1: rdata <= hbm_write_base_addr[21][63:32];
                ADDR_HBM22_WRITE0: rdata <= hbm_write_base_addr[22][31: 0];
                ADDR_HBM22_WRITE1: rdata <= hbm_write_base_addr[22][63:32];
                ADDR_HBM23_WRITE0: rdata <= hbm_write_base_addr[23][31: 0];
                ADDR_HBM23_WRITE1: rdata <= hbm_write_base_addr[23][63:32];
                ADDR_HBM24_WRITE0: rdata <= hbm_write_base_addr[24][31: 0];
                ADDR_HBM24_WRITE1: rdata <= hbm_write_base_addr[24][63:32];
                ADDR_HBM25_WRITE0: rdata <= hbm_write_base_addr[25][31: 0];
                ADDR_HBM25_WRITE1: rdata <= hbm_write_base_addr[25][63:32];
                ADDR_HBM26_WRITE0: rdata <= hbm_write_base_addr[26][31: 0];
                ADDR_HBM26_WRITE1: rdata <= hbm_write_base_addr[26][63:32];
                ADDR_HBM27_WRITE0: rdata <= hbm_write_base_addr[27][31: 0];
                ADDR_HBM27_WRITE1: rdata <= hbm_write_base_addr[27][63:32];
                ADDR_HBM28_WRITE0: rdata <= hbm_write_base_addr[28][31: 0];
                ADDR_HBM28_WRITE1: rdata <= hbm_write_base_addr[28][63:32];
                ADDR_HBM29_WRITE0: rdata <= hbm_write_base_addr[29][31: 0];
                ADDR_HBM29_WRITE1: rdata <= hbm_write_base_addr[29][63:32];

                ADDR_HBM30_WRITE0: rdata <= hbm_write_base_addr[30][31: 0];
                ADDR_HBM30_WRITE1: rdata <= hbm_write_base_addr[30][63:32];
                ADDR_HBM31_WRITE0: rdata <= hbm_write_base_addr[31][31: 0];
                ADDR_HBM31_WRITE1: rdata <= hbm_write_base_addr[31][63:32];

                /////////////////////////////////////////////////////////////////////////
                // End User Defined Registers.
                /////////////////////////////////////////////////////////////////////////
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign user_start  = int_ap_start;

// int_ap_start
always @(posedge ACLK) begin
    if (!ARESET_N)
        int_ap_start <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_USER_CTRL && WSTRB[0] && WDATA[0])
            int_ap_start <= 1'b1;
        else if (user_ready)
            int_ap_start <= 0; // clear on handshake
    end
end

// int_ap_done
always @(posedge ACLK) begin
    if (!ARESET_N)
        int_ap_done <= 1'b0;
    else if (ACLK_EN) begin
        if (user_done)
            int_ap_done <= 1'b1;
        else if (ar_hs && raddr == ADDR_USER_CTRL)
            int_ap_done <= 1'b0; // clear on read
    end
end

// int_ap_idle
always @(posedge ACLK) begin
    if (!ARESET_N)
        int_ap_idle <= 1'b0;
    else if (ACLK_EN) begin
        int_ap_idle <= user_idle;
    end
end


/////////////////////////////////////////////////////////////////////////
// User Defined Registers. You can modify here.
/////////////////////////////////////////////////////////////////////////
// hbm_read_base_addr
always @(posedge ACLK) begin
    if (!ARESET_N) begin
        hbm_read_base_addr[00][31: 0] <= 0;
        hbm_read_base_addr[00][63:32] <= 0;
        hbm_read_base_addr[01][31: 0] <= 0;
        hbm_read_base_addr[01][63:32] <= 0;
        hbm_read_base_addr[02][31: 0] <= 0;
        hbm_read_base_addr[02][63:32] <= 0;
        hbm_read_base_addr[03][31: 0] <= 0;
        hbm_read_base_addr[03][63:32] <= 0;
        hbm_read_base_addr[04][31: 0] <= 0;
        hbm_read_base_addr[04][63:32] <= 0;
        hbm_read_base_addr[05][31: 0] <= 0;
        hbm_read_base_addr[05][63:32] <= 0;
        hbm_read_base_addr[06][31: 0] <= 0;
        hbm_read_base_addr[06][63:32] <= 0;
        hbm_read_base_addr[07][31: 0] <= 0;
        hbm_read_base_addr[07][63:32] <= 0;
        hbm_read_base_addr[08][31: 0] <= 0;
        hbm_read_base_addr[08][63:32] <= 0;
        hbm_read_base_addr[09][31: 0] <= 0;
        hbm_read_base_addr[09][63:32] <= 0;
        hbm_read_base_addr[10][31: 0] <= 0;
        hbm_read_base_addr[10][63:32] <= 0;
        hbm_read_base_addr[11][31: 0] <= 0;
        hbm_read_base_addr[11][63:32] <= 0;
        hbm_read_base_addr[12][31: 0] <= 0;
        hbm_read_base_addr[12][63:32] <= 0;
        hbm_read_base_addr[13][31: 0] <= 0;
        hbm_read_base_addr[13][63:32] <= 0;
        hbm_read_base_addr[14][31: 0] <= 0;
        hbm_read_base_addr[14][63:32] <= 0;
        hbm_read_base_addr[15][31: 0] <= 0;
        hbm_read_base_addr[15][63:32] <= 0;
        hbm_read_base_addr[16][31: 0] <= 0;
        hbm_read_base_addr[16][63:32] <= 0;
        hbm_read_base_addr[17][31: 0] <= 0;
        hbm_read_base_addr[17][63:32] <= 0;
        hbm_read_base_addr[18][31: 0] <= 0;
        hbm_read_base_addr[18][63:32] <= 0;
        hbm_read_base_addr[19][31: 0] <= 0;
        hbm_read_base_addr[19][63:32] <= 0;
        hbm_read_base_addr[20][31: 0] <= 0;
        hbm_read_base_addr[20][63:32] <= 0;
        hbm_read_base_addr[21][31: 0] <= 0;
        hbm_read_base_addr[21][63:32] <= 0;
        hbm_read_base_addr[22][31: 0] <= 0;
        hbm_read_base_addr[22][63:32] <= 0;
        hbm_read_base_addr[23][31: 0] <= 0;
        hbm_read_base_addr[23][63:32] <= 0;
        hbm_read_base_addr[24][31: 0] <= 0;
        hbm_read_base_addr[24][63:32] <= 0;
        hbm_read_base_addr[25][31: 0] <= 0;
        hbm_read_base_addr[25][63:32] <= 0;
        hbm_read_base_addr[26][31: 0] <= 0;
        hbm_read_base_addr[26][63:32] <= 0;
        hbm_read_base_addr[27][31: 0] <= 0;
        hbm_read_base_addr[27][63:32] <= 0;
        hbm_read_base_addr[28][31: 0] <= 0;
        hbm_read_base_addr[28][63:32] <= 0;
        hbm_read_base_addr[29][31: 0] <= 0;
        hbm_read_base_addr[29][63:32] <= 0;
        hbm_read_base_addr[30][31: 0] <= 0;
        hbm_read_base_addr[30][63:32] <= 0;
        hbm_read_base_addr[31][31: 0] <= 0;
        hbm_read_base_addr[31][63:32] <= 0;

        hbm_write_base_addr[00][31: 0] <= 0;
        hbm_write_base_addr[00][63:32] <= 0;
        hbm_write_base_addr[01][31: 0] <= 0;
        hbm_write_base_addr[01][63:32] <= 0;
        hbm_write_base_addr[02][31: 0] <= 0;
        hbm_write_base_addr[02][63:32] <= 0;
        hbm_write_base_addr[03][31: 0] <= 0;
        hbm_write_base_addr[03][63:32] <= 0;
        hbm_write_base_addr[04][31: 0] <= 0;
        hbm_write_base_addr[04][63:32] <= 0;
        hbm_write_base_addr[05][31: 0] <= 0;
        hbm_write_base_addr[05][63:32] <= 0;
        hbm_write_base_addr[06][31: 0] <= 0;
        hbm_write_base_addr[06][63:32] <= 0;
        hbm_write_base_addr[07][31: 0] <= 0;
        hbm_write_base_addr[07][63:32] <= 0;
        hbm_write_base_addr[08][31: 0] <= 0;
        hbm_write_base_addr[08][63:32] <= 0;
        hbm_write_base_addr[09][31: 0] <= 0;
        hbm_write_base_addr[09][63:32] <= 0;
        hbm_write_base_addr[10][31: 0] <= 0;
        hbm_write_base_addr[10][63:32] <= 0;
        hbm_write_base_addr[11][31: 0] <= 0;
        hbm_write_base_addr[11][63:32] <= 0;
        hbm_write_base_addr[12][31: 0] <= 0;
        hbm_write_base_addr[12][63:32] <= 0;
        hbm_write_base_addr[13][31: 0] <= 0;
        hbm_write_base_addr[13][63:32] <= 0;
        hbm_write_base_addr[14][31: 0] <= 0;
        hbm_write_base_addr[14][63:32] <= 0;
        hbm_write_base_addr[15][31: 0] <= 0;
        hbm_write_base_addr[15][63:32] <= 0;
        hbm_write_base_addr[16][31: 0] <= 0;
        hbm_write_base_addr[16][63:32] <= 0;
        hbm_write_base_addr[17][31: 0] <= 0;
        hbm_write_base_addr[17][63:32] <= 0;
        hbm_write_base_addr[18][31: 0] <= 0;
        hbm_write_base_addr[18][63:32] <= 0;
        hbm_write_base_addr[19][31: 0] <= 0;
        hbm_write_base_addr[19][63:32] <= 0;
        hbm_write_base_addr[20][31: 0] <= 0;
        hbm_write_base_addr[20][63:32] <= 0;
        hbm_write_base_addr[21][31: 0] <= 0;
        hbm_write_base_addr[21][63:32] <= 0;
        hbm_write_base_addr[22][31: 0] <= 0;
        hbm_write_base_addr[22][63:32] <= 0;
        hbm_write_base_addr[23][31: 0] <= 0;
        hbm_write_base_addr[23][63:32] <= 0;
        hbm_write_base_addr[24][31: 0] <= 0;
        hbm_write_base_addr[24][63:32] <= 0;
        hbm_write_base_addr[25][31: 0] <= 0;
        hbm_write_base_addr[25][63:32] <= 0;
        hbm_write_base_addr[26][31: 0] <= 0;
        hbm_write_base_addr[26][63:32] <= 0;
        hbm_write_base_addr[27][31: 0] <= 0;
        hbm_write_base_addr[27][63:32] <= 0;
        hbm_write_base_addr[28][31: 0] <= 0;
        hbm_write_base_addr[28][63:32] <= 0;
        hbm_write_base_addr[29][31: 0] <= 0;
        hbm_write_base_addr[29][63:32] <= 0;
        hbm_write_base_addr[30][31: 0] <= 0;
        hbm_write_base_addr[30][63:32] <= 0;
        hbm_write_base_addr[31][31: 0] <= 0;
        hbm_write_base_addr[31][63:32] <= 0;
    end else if (ACLK_EN) begin
        if (w_hs) begin
            case(waddr) // synopsys parallel_case // synthesis parallel_case
                ADDR_HBM00_READ0: hbm_read_base_addr[00][31: 0] <= WDATA;
                ADDR_HBM00_READ1: hbm_read_base_addr[00][63:32] <= WDATA;
                ADDR_HBM01_READ0: hbm_read_base_addr[01][31: 0] <= WDATA; 
                ADDR_HBM01_READ1: hbm_read_base_addr[01][63:32] <= WDATA; 
                ADDR_HBM02_READ0: hbm_read_base_addr[02][31: 0] <= WDATA; 
                ADDR_HBM02_READ1: hbm_read_base_addr[02][63:32] <= WDATA; 
                ADDR_HBM03_READ0: hbm_read_base_addr[03][31: 0] <= WDATA; 
                ADDR_HBM03_READ1: hbm_read_base_addr[03][63:32] <= WDATA; 
                ADDR_HBM04_READ0: hbm_read_base_addr[04][31: 0] <= WDATA; 
                ADDR_HBM04_READ1: hbm_read_base_addr[04][63:32] <= WDATA; 
                ADDR_HBM05_READ0: hbm_read_base_addr[05][31: 0] <= WDATA; 
                ADDR_HBM05_READ1: hbm_read_base_addr[05][63:32] <= WDATA; 
                ADDR_HBM06_READ0: hbm_read_base_addr[06][31: 0] <= WDATA; 
                ADDR_HBM06_READ1: hbm_read_base_addr[06][63:32] <= WDATA; 
                ADDR_HBM07_READ0: hbm_read_base_addr[07][31: 0] <= WDATA; 
                ADDR_HBM07_READ1: hbm_read_base_addr[07][63:32] <= WDATA; 
                ADDR_HBM08_READ0: hbm_read_base_addr[08][31: 0] <= WDATA; 
                ADDR_HBM08_READ1: hbm_read_base_addr[08][63:32] <= WDATA; 
                ADDR_HBM09_READ0: hbm_read_base_addr[09][31: 0] <= WDATA; 
                ADDR_HBM09_READ1: hbm_read_base_addr[09][63:32] <= WDATA; 

                ADDR_HBM10_READ0: hbm_read_base_addr[10][31: 0] <= WDATA;  
                ADDR_HBM10_READ1: hbm_read_base_addr[10][63:32] <= WDATA;  
                ADDR_HBM11_READ0: hbm_read_base_addr[11][31: 0] <= WDATA;  
                ADDR_HBM11_READ1: hbm_read_base_addr[11][63:32] <= WDATA;  
                ADDR_HBM12_READ0: hbm_read_base_addr[12][31: 0] <= WDATA;  
                ADDR_HBM12_READ1: hbm_read_base_addr[12][63:32] <= WDATA;  
                ADDR_HBM13_READ0: hbm_read_base_addr[13][31: 0] <= WDATA;  
                ADDR_HBM13_READ1: hbm_read_base_addr[13][63:32] <= WDATA;  
                ADDR_HBM14_READ0: hbm_read_base_addr[14][31: 0] <= WDATA;  
                ADDR_HBM14_READ1: hbm_read_base_addr[14][63:32] <= WDATA;  
                ADDR_HBM15_READ0: hbm_read_base_addr[15][31: 0] <= WDATA;  
                ADDR_HBM15_READ1: hbm_read_base_addr[15][63:32] <= WDATA;  
                ADDR_HBM16_READ0: hbm_read_base_addr[16][31: 0] <= WDATA;  
                ADDR_HBM16_READ1: hbm_read_base_addr[16][63:32] <= WDATA;  
                ADDR_HBM17_READ0: hbm_read_base_addr[17][31: 0] <= WDATA;  
                ADDR_HBM17_READ1: hbm_read_base_addr[17][63:32] <= WDATA;  
                ADDR_HBM18_READ0: hbm_read_base_addr[18][31: 0] <= WDATA;  
                ADDR_HBM18_READ1: hbm_read_base_addr[18][63:32] <= WDATA;  
                ADDR_HBM19_READ0: hbm_read_base_addr[19][31: 0] <= WDATA;  
                ADDR_HBM19_READ1: hbm_read_base_addr[19][63:32] <= WDATA;  

                ADDR_HBM20_READ0: hbm_read_base_addr[20][31: 0] <= WDATA; 
                ADDR_HBM20_READ1: hbm_read_base_addr[20][63:32] <= WDATA; 
                ADDR_HBM21_READ0: hbm_read_base_addr[21][31: 0] <= WDATA; 
                ADDR_HBM21_READ1: hbm_read_base_addr[21][63:32] <= WDATA; 
                ADDR_HBM22_READ0: hbm_read_base_addr[22][31: 0] <= WDATA; 
                ADDR_HBM22_READ1: hbm_read_base_addr[22][63:32] <= WDATA; 
                ADDR_HBM23_READ0: hbm_read_base_addr[23][31: 0] <= WDATA; 
                ADDR_HBM23_READ1: hbm_read_base_addr[23][63:32] <= WDATA; 
                ADDR_HBM24_READ0: hbm_read_base_addr[24][31: 0] <= WDATA; 
                ADDR_HBM24_READ1: hbm_read_base_addr[24][63:32] <= WDATA; 
                ADDR_HBM25_READ0: hbm_read_base_addr[25][31: 0] <= WDATA; 
                ADDR_HBM25_READ1: hbm_read_base_addr[25][63:32] <= WDATA; 
                ADDR_HBM26_READ0: hbm_read_base_addr[26][31: 0] <= WDATA; 
                ADDR_HBM26_READ1: hbm_read_base_addr[26][63:32] <= WDATA; 
                ADDR_HBM27_READ0: hbm_read_base_addr[27][31: 0] <= WDATA; 
                ADDR_HBM27_READ1: hbm_read_base_addr[27][63:32] <= WDATA; 
                ADDR_HBM28_READ0: hbm_read_base_addr[28][31: 0] <= WDATA; 
                ADDR_HBM28_READ1: hbm_read_base_addr[28][63:32] <= WDATA; 
                ADDR_HBM29_READ0: hbm_read_base_addr[29][31: 0] <= WDATA; 
                ADDR_HBM29_READ1: hbm_read_base_addr[29][63:32] <= WDATA; 

                ADDR_HBM30_READ0: hbm_read_base_addr[30][31: 0] <= WDATA; 
                ADDR_HBM30_READ1: hbm_read_base_addr[30][63:32] <= WDATA; 
                ADDR_HBM31_READ0: hbm_read_base_addr[31][31: 0] <= WDATA; 
                ADDR_HBM31_READ1: hbm_read_base_addr[31][63:32] <= WDATA; 


                ADDR_HBM00_WRITE0: hbm_write_base_addr[00][31: 0] <= WDATA;
                ADDR_HBM00_WRITE1: hbm_write_base_addr[00][63:32] <= WDATA;
                ADDR_HBM01_WRITE0: hbm_write_base_addr[01][31: 0] <= WDATA; 
                ADDR_HBM01_WRITE1: hbm_write_base_addr[01][63:32] <= WDATA; 
                ADDR_HBM02_WRITE0: hbm_write_base_addr[02][31: 0] <= WDATA; 
                ADDR_HBM02_WRITE1: hbm_write_base_addr[02][63:32] <= WDATA; 
                ADDR_HBM03_WRITE0: hbm_write_base_addr[03][31: 0] <= WDATA; 
                ADDR_HBM03_WRITE1: hbm_write_base_addr[03][63:32] <= WDATA; 
                ADDR_HBM04_WRITE0: hbm_write_base_addr[04][31: 0] <= WDATA; 
                ADDR_HBM04_WRITE1: hbm_write_base_addr[04][63:32] <= WDATA; 
                ADDR_HBM05_WRITE0: hbm_write_base_addr[05][31: 0] <= WDATA; 
                ADDR_HBM05_WRITE1: hbm_write_base_addr[05][63:32] <= WDATA; 
                ADDR_HBM06_WRITE0: hbm_write_base_addr[06][31: 0] <= WDATA; 
                ADDR_HBM06_WRITE1: hbm_write_base_addr[06][63:32] <= WDATA; 
                ADDR_HBM07_WRITE0: hbm_write_base_addr[07][31: 0] <= WDATA; 
                ADDR_HBM07_WRITE1: hbm_write_base_addr[07][63:32] <= WDATA; 
                ADDR_HBM08_WRITE0: hbm_write_base_addr[08][31: 0] <= WDATA; 
                ADDR_HBM08_WRITE1: hbm_write_base_addr[08][63:32] <= WDATA; 
                ADDR_HBM09_WRITE0: hbm_write_base_addr[09][31: 0] <= WDATA; 
                ADDR_HBM09_WRITE1: hbm_write_base_addr[09][63:32] <= WDATA; 

                ADDR_HBM10_WRITE0: hbm_write_base_addr[10][31: 0] <= WDATA;  
                ADDR_HBM10_WRITE1: hbm_write_base_addr[10][63:32] <= WDATA;  
                ADDR_HBM11_WRITE0: hbm_write_base_addr[11][31: 0] <= WDATA;  
                ADDR_HBM11_WRITE1: hbm_write_base_addr[11][63:32] <= WDATA;  
                ADDR_HBM12_WRITE0: hbm_write_base_addr[12][31: 0] <= WDATA;  
                ADDR_HBM12_WRITE1: hbm_write_base_addr[12][63:32] <= WDATA;  
                ADDR_HBM13_WRITE0: hbm_write_base_addr[13][31: 0] <= WDATA;  
                ADDR_HBM13_WRITE1: hbm_write_base_addr[13][63:32] <= WDATA;  
                ADDR_HBM14_WRITE0: hbm_write_base_addr[14][31: 0] <= WDATA;  
                ADDR_HBM14_WRITE1: hbm_write_base_addr[14][63:32] <= WDATA;  
                ADDR_HBM15_WRITE0: hbm_write_base_addr[15][31: 0] <= WDATA;  
                ADDR_HBM15_WRITE1: hbm_write_base_addr[15][63:32] <= WDATA;  
                ADDR_HBM16_WRITE0: hbm_write_base_addr[16][31: 0] <= WDATA;  
                ADDR_HBM16_WRITE1: hbm_write_base_addr[16][63:32] <= WDATA;  
                ADDR_HBM17_WRITE0: hbm_write_base_addr[17][31: 0] <= WDATA;  
                ADDR_HBM17_WRITE1: hbm_write_base_addr[17][63:32] <= WDATA;  
                ADDR_HBM18_WRITE0: hbm_write_base_addr[18][31: 0] <= WDATA;  
                ADDR_HBM18_WRITE1: hbm_write_base_addr[18][63:32] <= WDATA;  
                ADDR_HBM19_WRITE0: hbm_write_base_addr[19][31: 0] <= WDATA;  
                ADDR_HBM19_WRITE1: hbm_write_base_addr[19][63:32] <= WDATA;  

                ADDR_HBM20_WRITE0: hbm_write_base_addr[20][31: 0] <= WDATA; 
                ADDR_HBM20_WRITE1: hbm_write_base_addr[20][63:32] <= WDATA; 
                ADDR_HBM21_WRITE0: hbm_write_base_addr[21][31: 0] <= WDATA; 
                ADDR_HBM21_WRITE1: hbm_write_base_addr[21][63:32] <= WDATA; 
                ADDR_HBM22_WRITE0: hbm_write_base_addr[22][31: 0] <= WDATA; 
                ADDR_HBM22_WRITE1: hbm_write_base_addr[22][63:32] <= WDATA; 
                ADDR_HBM23_WRITE0: hbm_write_base_addr[23][31: 0] <= WDATA; 
                ADDR_HBM23_WRITE1: hbm_write_base_addr[23][63:32] <= WDATA; 
                ADDR_HBM24_WRITE0: hbm_write_base_addr[24][31: 0] <= WDATA; 
                ADDR_HBM24_WRITE1: hbm_write_base_addr[24][63:32] <= WDATA; 
                ADDR_HBM25_WRITE0: hbm_write_base_addr[25][31: 0] <= WDATA; 
                ADDR_HBM25_WRITE1: hbm_write_base_addr[25][63:32] <= WDATA; 
                ADDR_HBM26_WRITE0: hbm_write_base_addr[26][31: 0] <= WDATA; 
                ADDR_HBM26_WRITE1: hbm_write_base_addr[26][63:32] <= WDATA; 
                ADDR_HBM27_WRITE0: hbm_write_base_addr[27][31: 0] <= WDATA; 
                ADDR_HBM27_WRITE1: hbm_write_base_addr[27][63:32] <= WDATA; 
                ADDR_HBM28_WRITE0: hbm_write_base_addr[28][31: 0] <= WDATA; 
                ADDR_HBM28_WRITE1: hbm_write_base_addr[28][63:32] <= WDATA; 
                ADDR_HBM29_WRITE0: hbm_write_base_addr[29][31: 0] <= WDATA; 
                ADDR_HBM29_WRITE1: hbm_write_base_addr[29][63:32] <= WDATA; 

                ADDR_HBM30_WRITE0: hbm_write_base_addr[30][31: 0] <= WDATA; 
                ADDR_HBM30_WRITE1: hbm_write_base_addr[30][63:32] <= WDATA; 
                ADDR_HBM31_WRITE0: hbm_write_base_addr[31][31: 0] <= WDATA; 
                ADDR_HBM31_WRITE1: hbm_write_base_addr[31][63:32] <= WDATA; 


            endcase
        end
    end
end
/////////////////////////////////////////////////////////////////////////
// End User Defined Registers.
/////////////////////////////////////////////////////////////////////////

//------------------------Memory logic-------------------

endmodule
