// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : lm_mem_2p_512x512b.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-07-25   Lyu-Ming Ho     
// -----------------------------------------------------------------------------
// PURPOSE: instructionQueue 2-port ram
// -----------------------------------------------------------------------------

//synopsys translate_off
`include "rf_2p_512x128b.v"
//synopsys translate_on

module lm_mem_2p_512x512b (
    input  logic            CLK     ,
    input  logic            CENA    ,   // 0: read_enable
    input  logic [9-1:0]    AA      ,
    output logic [512-1:0]  QA      ,

    input  logic            CENB    ,   // 0: write_enable
    input  logic [9-1:0]    AB      ,
    input  logic [512-1:0]  DB      
);

//output port
logic                                                CENYA      [0:3]   ;
logic                                                CENYB      [0:3]   ;
logic                       [             8:0]       AYA        [0:3]   ;
logic                       [             8:0]       AYB        [0:3]   ;
logic                       [           127:0]       DYB        [0:3]   ;    

//input port                            
logic                                                EMASA,TENA,TENB,BENA,TCENA,TCENB,RET1N,STOVA,STOVB,COLLDISN ;
logic                       [             1:0]       EMAWB;
logic                       [             2:0]       EMAA, EMAB;
logic                       [             8:0]       TAA; // as many as address
logic                       [             8:0]       TAB; // as many as address

logic                       [           127:0]       TDB; // as many as one bank input port width
logic                       [           127:0]       TQA; // as many as one bank output port width

logic [512-1:0] q;

assign QA = q;

assign EMAA       = 'b0;
assign EMAB       = 'b0;
assign EMAWB      = 'b0;
assign EMASA      = 'b0;
assign TENA       = 'b1;
assign TENB       = 'b1;
assign BENA       = 'b1;
assign TCENA      = 'b1;
assign TCENB      = 'b1;
assign TAA        = 'b0;
assign TAB        = 'b0;
assign TDB        = 'b0;
assign TQA        = 'b0;
assign RET1N      = 'b1;
assign STOVA      = 'b0;
assign STOVB      = 'b0;
assign COLLDISN   = 'b1;

generate
for (genvar bk=0; bk<4; bk=bk+1) begin: mem_bank
    rf_2p_512x128b u_mem (
        // output
        .CENYA   ( CENYA[bk]         ),
        .AYA     ( AYA  [bk]         ),
        .CENYB   ( CENYB[bk]         ),
        .AYB     ( AYB  [bk]         ),
        .DYB     ( DYB  [bk]         ),
        .QA      ( q[bk*128 +: 128]  ),
        
        // input                           
        .CLKA    ( CLK               ),
        .CENA    ( CENA              ),
        .AA      ( AA                ),
        .CLKB    ( CLK               ),
        .CENB    ( CENB              ),
        .AB      ( AB                ),
        .DB      ( DB[bk*128 +: 128] ),
        .EMAA    ( EMAA              ),
        .EMASA   ( EMASA             ),
        .EMAB    ( EMAB              ),
        .EMAWB   ( EMAWB             ),
        .TENA    ( TENA              ),
        .BENA    ( BENA              ),
        .TCENA   ( TCENA             ),
        .TAA     ( TAA               ),
        .TQA     ( TQA               ),
        .TENB    ( TENB              ),
        .TCENB   ( TCENB             ),
        .TAB     ( TAB               ),
        .TDB     ( TDB               ),
        .RET1N   ( RET1N             ),
        .STOVA   ( STOVA             ),
        .STOVB   ( STOVB             ),
        .COLLDISN( COLLDISN          )
    );
end
endgenerate

endmodule