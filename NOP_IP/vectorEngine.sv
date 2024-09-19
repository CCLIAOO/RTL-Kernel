// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : vectorEngine.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-06-08   Lyu-Ming Ho     3-stage adder tree (8-2, 8-2, 8-2),   1732642.638031    0.8 
//                                      asynchronous-reset (resetn)
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// (16 x 128) Vector Engine
// -----------------------------------------------------------------------------

//`include "DW02_tree.v"
`include "fake_DW02_tree.v"

module vectorEngine #(
    parameter ATREE_WIDTH       = 25    ,   // 18 + log2(128)
    parameter VERIF_EN          = 1     ,   // DW02_tree parameter
    parameter VEC_LEN           = 128   ,   // should not be modified, fixed !!

    parameter WIDTH             = 8     ,   // data width
    parameter MULT_WIDTH        = 18    ,   // (WIDTH + 1) + (WIDTH + 1)

    parameter NUM_PE_WM         = 2048  ,   // total PE
    parameter NUM_PE_AM         = 1024  ,   // no use, just a reminder
    parameter NUM_PE_HP         = 1024  ,   // no use, just a reminder

    parameter NUM_VEC           = NUM_PE_WM / VEC_LEN                   ,   // 16       ( 2048 / 128 )
    parameter DIN_WIDTH         = NUM_PE_WM * WIDTH                     ,   // 16384    ( 2048 * 8   )
    parameter DOUT_HP_WIDTH     = NUM_PE_HP * MULT_WIDTH                ,   // 18432    ( 1024 * 18  ), temp (HPU num not determined)
    parameter DOUT_WIDTH        = NUM_PE_WM / VEC_LEN * ATREE_WIDTH         // 400      ( 16 * 25    )
) (
    input  logic                                    clk          ,
    input  logic                                    resetn       ,

    input  logic                                    op_valid     ,
    input  logic [1:0]                              op_type      ,

    input  logic                                    in_valid     ,
    input  logic [NUM_PE_WM-1:0][WIDTH-1:0]         in_data      ,
    input  logic                [WIDTH-1:0]         z_i          ,       // activation input: per-tensor quant

    input  logic                                    weight_valid ,
    input  logic [NUM_PE_WM-1:0][WIDTH-1:0]         weight_data  ,
    input  logic [NUM_PE_WM-1:0][WIDTH-1:0]         z_w          ,       // weight: per-channel quant

    output logic                                    out_hp_valid ,
    output logic [NUM_PE_HP-1:0][MULT_WIDTH-1:0]    out_hp_data  ,

    output logic                                    out_valid    ,
    output logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]     out0         ,
    output logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]     out1         ,

    output logic                                    outsum_valid ,      // out_valid delay for 1T
    output logic [NUM_VEC-1:0][ATREE_WIDTH-1:0]     out                 // actual (out0 + out1) value
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------
localparam LATENCY      = 5; 
localparam LATENCY_HP   = 2; 

//------------------------- operation Type ------------------------- 
localparam NO_OP  = 0;                              // No Operation
localparam MLP_WM = 1;                              // Mode 1: Weight Multiplication          ( Weight * input )
localparam MLP_AM = 2;                              // Mode 2: Activation Multiplication      ( Kt     * Q     ), can be treated as mode 1 as well, functioning the same
localparam MLP_HP = 3;                              // Mode 3: Hadamard Product               ( V      * S     )

//------------------------- DW02 Param -------------------------
localparam verif_en         = VERIF_EN;

//------------------------- Adder Tree -------------------------
localparam NUM_TREE_S1       = VEC_LEN / 8          ;   // 16 pairs DW02_tree (128  / 8)
localparam NUM_TREE_S2       = NUM_TREE_S1 * 2 / 8  ;   // 4  pairs DW02_tree (16*2 / 8)
localparam NUM_TREE_S3       = NUM_TREE_S2 * 2 / 8  ;   // 1  pairs DW02_tree (4*2 / 8)

/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////
logic EN;                                                           // Clock Gating, no use for now

logic        [1:0]  mode;
logic        [1:0]  opt_delay [0:LATENCY-1];                        // Operation Mode delay

logic signed [WIDTH-1:0]  inData      [0:NUM_PE_WM-1] ;
logic signed [WIDTH-1:0]  zero_i                      ;             // per-tensor (only one)
logic signed [WIDTH  :0]  inData_dq   [0:NUM_PE_WM-1] ;

logic signed [WIDTH-1:0]  weight      [0:NUM_PE_WM-1] ;
logic signed [WIDTH-1:0]  zero_w      [0:NUM_PE_WM-1] ;
logic signed [WIDTH  :0]  weight_dq   [0:NUM_PE_WM-1] ;

logic signed [ATREE_WIDTH  -1:0]    mult_result     [0:NUM_VEC-1][0:128-1];                 // 2048 pe

logic        [ATREE_WIDTH*8-1:0]    addtree_s1_in   [0:NUM_VEC-1][0:NUM_TREE_S1-1];         // 16 rows, each row has 16 pairs of DW02_tree
logic        [ATREE_WIDTH  -1:0]    addtree_s1_out  [0:NUM_VEC-1][0:NUM_TREE_S1-1][0:1];    

logic        [ATREE_WIDTH*8-1:0]    addtree_s2_in   [0:NUM_VEC-1][0:NUM_TREE_S2-1];         // 16 rows, each row has 4  pairs of DW02_tree
logic        [ATREE_WIDTH  -1:0]    addtree_s2_out  [0:NUM_VEC-1][0:NUM_TREE_S2-1][0:1];

logic        [ATREE_WIDTH*8-1:0]    addtree_s3_in   [0:NUM_VEC-1];                          // 16 rows, each row has 1  pairs of DW02_tree
logic        [ATREE_WIDTH  -1:0]    addtree_s3_out  [0:NUM_VEC-1][0:1];


////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

// Clock Gating Logics, to be continued ...
assign EN = 1'b1;

// Delay
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int i=0; i<LATENCY; i=i+1)
            opt_delay[i] <= 0;
    end
    else begin
        opt_delay[0] <= (op_valid) ? op_type : 0;
        for (int i=1; i<LATENCY; i=i+1)
            opt_delay[i] <= opt_delay[i-1];
    end
end

// Zero point of input
always @(posedge clk or negedge resetn) begin
    if (!resetn)     
        zero_i  <= 0;
    else    
        zero_i  <= (in_valid) ? $signed(z_i) : zero_i;
end

// Zero point of weight
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int i=0; i<NUM_PE_WM; i=i+1)
            zero_w[i] <= 0;
    end
    else begin
        if (weight_valid) begin
            for (int i=0; i<NUM_PE_WM; i=i+1)
                zero_w[i] <= $signed(z_w[i]);
        end
    end
end

// Input FF
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int i=0; i<NUM_PE_WM; i=i+1)
            inData[i] <= 0;
    end
    else begin
        if (in_valid) begin
            for (int i=0; i<NUM_PE_WM; i=i+1) 
                inData[i] <= $signed(in_data[i]);
        end
    end
end

// Dequant input
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int i=0; i<NUM_PE_WM; i=i+1)
            inData_dq[i] <= 0;
    end
    else begin
        for (int i=0; i<NUM_PE_WM; i=i+1)
            inData_dq[i] <= inData[i] - zero_i;
    end
end

// Weight FF
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int i=0; i<NUM_PE_WM; i=i+1) 
            weight[i] <= 0;
    end
    else begin
        if (weight_valid) begin
            for (int i=0; i<NUM_PE_WM; i=i+1) 
                weight[i] <= $signed(weight_data[i]);
        end
    end
end

// Dequant weight
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int i=0; i<NUM_PE_WM; i=i+1) 
            weight_dq[i] <= 0;
    end
    else begin
        for (int i=0; i<NUM_PE_WM; i=i+1) 
            weight_dq[i] <= weight[i] - zero_w[i];
    end
end

// Multiplication
generate
for (genvar ii=0; ii<NUM_VEC; ii=ii+1) begin
    for (genvar jj=0; jj<128; jj=jj+1) begin
        always @(posedge clk or negedge resetn) begin
            if (!resetn)
                mult_result[ii][jj] <= 0;
            else
                mult_result[ii][jj] <= weight_dq[ii*128 + jj] * inData_dq[ii*128 + jj];
        end
    end
end
endgenerate


// Stage 1: Adder Tree (simply concat mult_result)
always @(*) begin
    for (int row=0; row<NUM_VEC; row=row+1) begin
        for (int jj=0; jj<NUM_TREE_S1; jj=jj+1) begin
            addtree_s1_in[row][jj] <= {
                mult_result[row][jj*8 + 0],
                mult_result[row][jj*8 + 1],
                mult_result[row][jj*8 + 2],
                mult_result[row][jj*8 + 3],
                mult_result[row][jj*8 + 4],
                mult_result[row][jj*8 + 5],
                mult_result[row][jj*8 + 6],
                mult_result[row][jj*8 + 7]
            }; 
        end
    end
end

generate
for (genvar row=0; row<NUM_VEC; row=row+1) begin: tree_s1
    // 16 pairs of DW02_tree each row
    for (genvar jj=0; jj<NUM_TREE_S1; jj=jj+1) begin
        DW02_tree #(.num_inputs(8), .input_width(25), .verif_en(verif_en)) addTree (
            .INPUT  ( addtree_s1_in [row][jj]    ),
            .OUT0   ( addtree_s1_out[row][jj][0] ),
            .OUT1   ( addtree_s1_out[row][jj][1] )
        );
    end
end
endgenerate


// Stage 2: Adder Tree
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int row=0; row<NUM_VEC; row=row+1) begin
            addtree_s2_in[row][0] <= 0;
            addtree_s2_in[row][1] <= 0;
            addtree_s2_in[row][2] <= 0;
            addtree_s2_in[row][3] <= 0;
        end
    end
    else begin
        for (int row=0; row<NUM_VEC; row=row+1) begin
            for (int jj=0; jj<NUM_TREE_S2; jj=jj+1) begin
                addtree_s2_in[row][jj] <= {
                    addtree_s1_out[row][jj*4 + 0][0],
                    addtree_s1_out[row][jj*4 + 0][1],
                    addtree_s1_out[row][jj*4 + 1][0],
                    addtree_s1_out[row][jj*4 + 1][1],
                    addtree_s1_out[row][jj*4 + 2][0],
                    addtree_s1_out[row][jj*4 + 2][1],
                    addtree_s1_out[row][jj*4 + 3][0],
                    addtree_s1_out[row][jj*4 + 3][1]
                }; 
            end
        end
    end
end

generate
for (genvar row=0; row<NUM_VEC; row=row+1) begin: tree_s2
    // 4 pairs of DW02_tree each row
    for (genvar jj=0; jj<NUM_TREE_S2; jj=jj+1) begin
        DW02_tree #(.num_inputs(8), .input_width(25), .verif_en(verif_en)) addTree (
            .INPUT  ( addtree_s2_in [row][jj]    ),
            .OUT0   ( addtree_s2_out[row][jj][0] ),
            .OUT1   ( addtree_s2_out[row][jj][1] )
        );
    end
end
endgenerate


// Stage 3: Adder Tree
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        for (int row=0; row<NUM_VEC; row=row+1)
            addtree_s3_in[row] <= 0;
    end
    else begin
        for (int row=0; row<NUM_VEC; row=row+1) begin
            addtree_s3_in[row] <= {
                addtree_s2_out[row][0][0],
                addtree_s2_out[row][0][1],
                addtree_s2_out[row][1][0],
                addtree_s2_out[row][1][1],
                addtree_s2_out[row][2][0],
                addtree_s2_out[row][2][1],
                addtree_s2_out[row][3][0],
                addtree_s2_out[row][3][1]
            };
        end
    end
end

generate
for (genvar row=0; row<NUM_VEC; row=row+1) begin: tree_s3
    // 1 pair of DW02_tree each row
    DW02_tree #(.num_inputs(8), .input_width(25), .verif_en(verif_en)) addTree (
        .INPUT  ( addtree_s3_in [row]    ),
        .OUT0   ( addtree_s3_out[row][0] ),
        .OUT1   ( addtree_s3_out[row][1] )
    );
end
endgenerate

// Output Related Signals
always @(posedge clk) begin
    out_valid <= (opt_delay[LATENCY-1] == MLP_WM || opt_delay[LATENCY-1] == MLP_AM);           // Beware of the delay // needed to be checked!!

    for (int idx=0; idx<NUM_VEC; idx=idx+1) begin
        out0[idx] <= addtree_s3_out[idx][0];
        out1[idx] <= addtree_s3_out[idx][1];
    end
end

always @(posedge clk) begin
    if (!resetn) begin
        outsum_valid <= 0;
        out          <= 0;
    end
    else begin
        outsum_valid <= out_valid;

        for (int idx=0; idx<NUM_VEC; idx=idx+1)
            out[idx] <= out0[idx] + out1[idx];
    end
end

always @(*) begin
    out_hp_valid = (opt_delay[LATENCY_HP] == MLP_HP);          // Beware of the delay // needed to be checked!!

    for (int idx=0; idx<NUM_PE_HP; idx=idx+1)
        out_hp_data[idx] = mult_result[idx / 128][idx % 128][0 +: MULT_WIDTH];
end

endmodule


// Adder Tree architecture:
//                                                                                               128 x 25b
//                  _________________________________________________________________________________|________________________________________________________________________________
//                 /          /          /         /          /          /          /          /          \          \          \          \          \          \          \         \
//              8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b    8 x 25b  
//              |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|    |.....|  
//              V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V  
//            __________ __________ __________ __________ __________ __________ __________ __________ __________ __________ __________ __________ __________ __________ __________ __________ 
//  Stage 1  |8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|8-to-2 CSA|
//           |__________|__________|__________|__________|__________|__________|__________|__________|__________|__________|__________|__________|__________|__________|__________|__________|
//              |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |   
//              V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V   
//              2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b    2 x 25b  
//              |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |     |    |   
//              V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V     V    V   
//            ___________________________________________ ___________________________________________ ___________________________________________ ___________________________________________ 
//  Stage 2  |                8-to-2 CSA                 |                8-to-2 CSA                 |                8-to-2 CSA                 |                8-to-2 CSA                 |
//           |___________________________________________|___________________________________________|___________________________________________|___________________________________________|
//                              |     |                                     |     |                                     |     |                                     |     |                   
//                              V     V                                     V     V                                     V     V                                     V     V                   
//                              2 x 25b                                     2 x 25b                                     2 x 25b                                     2 x 25b                   
//                              |     |                                     |     |                                     |     |                                     |     |                   
//                              V     V                                     V     V                                     V     V                                     V     V                   
//            _______________________________________________________________________________________________________________________________________________________________________________
//  Stage 3  |                                                                                   8-to-2 CSA                                                                                  |
//           |_______________________________________________________________________________________________________________________________________________________________________________|
//                                                                                                |       |                                          
//                                                                                                V       V                                          
//                                                                                               25b     25b                                        
