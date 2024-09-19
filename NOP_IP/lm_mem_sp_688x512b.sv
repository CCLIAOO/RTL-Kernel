// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : lm_mem_sp_688x512b.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-07-25   Lyu-Ming Ho     
// -----------------------------------------------------------------------------
// PURPOSE: bias
// -----------------------------------------------------------------------------


// fixme not verfied yet

//synopsys translate_off
`include "mem/rf_sp_688x128b.v"
//synopsys translate_on

module lm_mem_sp_688x512b (
    input  logic            CLK     ,
    input  logic [9:0]      A       ,
    input  logic [511:0]    D       ,
    output logic [511:0]    Q       ,
    input  logic            WEN     ,   // 0: write, 1: read
    input  logic            CEN         // 0: enable sram
);

logic EMAS,TEN,BEN,TCEN,TWEN,RET1N,STOV;
logic [1:0] EMAW;
logic [2:0] EMA;
logic [9:0]     TA_IN;
logic [127:0]   TD_IN,TQ_IN;

assign EMA     = 'b0;
assign EMAW    = 'b0;
assign EMAS    = 'b0;
assign TEN     = 'b1;
assign BEN     = 'b1;
assign TCEN    = 'b1;
assign TWEN    = 'b1;
assign TA_IN   = 'b0;
assign TD_IN   = 'b0;
assign TQ_IN   = 'b0;
assign RET1N   = 'b1;
assign STOV    = 'b0;

generate
for (genvar bk=0; bk<4; bk=bk+1) begin: mem_bank
    rf_sp_688x128b u_mem (
        // what we care
        .CLK    ( CLK              ),
        .CEN    ( CEN              ),
        .WEN    ( WEN              ),
        .A      ( A                ),
        .D      ( D[128*bk +: 128] ),
        .Q      ( Q[128*bk +: 128] ),

        // USELESS
        .CENY   (),
        .WENY   (),
        .AY     (),
        .DY     (),
        .EMA    ( EMA              ),
        .EMAW   ( EMAW             ),
        .EMAS   ( EMAS             ),
        .TEN    ( TEN              ),
        .BEN    ( BEN              ),
        .TCEN   ( TCEN             ),
        .TWEN   ( TWEN             ),
        .TA     ( TA_IN            ),
        .TD     ( TD_IN            ),
        .TQ     ( TQ_IN            ),
        .RET1N  ( RET1N            ),
        .STOV   ( STOV             )
    );
end
endgenerate


endmodule