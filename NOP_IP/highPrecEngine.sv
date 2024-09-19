// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : highPrecEngine.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          DESCRIPTION                           SYN_AREA          SYN_CLK_PERIOD
// 1.0     2024-06-23   Lyu-Ming Ho     
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// highPrecEngine: for high precision operations 
// (Quant, RoPE, Residual, rmsNorm ...)
// -----------------------------------------------------------------------------

//`include "DW02_mult_2_stage.v"

module highPrecEngine #(
    parameter NUM_QUANT     = 256   ,
    parameter VERIF_EN      = 1     ,
    
    parameter WIDTH0        = 32    ,
    parameter WIDTH1        = 10    ,
    parameter ATREE_WIDTH   = 32    
) (
    input  logic clk     ,
    input  logic resetn  ,

    input  logic                            in_valid    ,
    input  logic [NUM_QUANT-1:0][32-1:0]    in_data0    ,   // 32 bit   requant: data, rmsnorm step2: (xj - zj), rmsnrom step6: ((xj - zj) * gama_i), rope: query
    input  logic [NUM_QUANT-1:0][10-1:0]    in_data1    ,   // 10 bit   requant: M   , rmsnorm step2:  lambda^2, rmsnorm step6: rsqrt               , rope: <cos | sin>

    input  logic                            shift_valid ,
    input  logic [NUM_QUANT-1:0][8 -1:0]    shift       ,

    input  logic                            z_o_valid   ,
    input  logic [NUM_QUANT-1:0][32-1:0]    z_o         ,

    output logic                            psum_valid  ,
    output logic [          32-1:0 ]        psum0       ,   // adder tree partial-sum, will be sent to "accumulator"
    output logic [          32-1:0 ]        psum1       ,   // adder tree partial-sum, will be sent to "accumulator"

    output logic                            ms_outvalid ,
    output logic [NUM_QUANT-1:0][32-1:0]    ms_out      ,   // output of mult and shift

    output logic                            msz_outvalid,
    output logic [NUM_QUANT-1:0][32-1:0]    msz_out         // output of mult, shift and subtract z_o 
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------

//------------------------- operation Type -------------------------

//-------------------------- DW Param --------------------------
localparam verif_en = VERIF_EN;

//------------------------- Adder Tree -------------------------
localparam
    NUM_TREE_S1 = NUM_QUANT / 8         ,       // 32
    NUM_TREE_S2 = NUM_TREE_S1 * 2 / 8   ,       // 8
    NUM_TREE_S3 = NUM_TREE_S2 * 2 / 8   ;       // 2


/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////

//------------------------- input delay -------------------------
logic in_valid_delay;
logic shift_valid_delay;
logic z_o_valid_delay;
logic [8:0] addtree_delay; // fixme bit num should be checked

//------------------------- input staged registers -------------------------
logic signed [ 32-1:0 ] data0           [ 0:NUM_QUANT-1 ];
logic signed [ 10-1:0 ] data1           [ 0:NUM_QUANT-1 ];
logic signed [  8-1:0 ] shft            [ 0:NUM_QUANT-1 ];
logic signed [ 32-1:0 ] zo              [ 0:NUM_QUANT-1 ];

logic signed [ 42-1:0 ] mult_result     [ 0:NUM_QUANT-1 ];
logic signed [ 32-1:0 ] shift_result    [ 0:NUM_QUANT-1 ];
logic signed [ 32-1:0 ] subzo_result    [ 0:NUM_QUANT-1 ];

//------------------------- adder tree I/O -------------------------
logic        [ATREE_WIDTH*8-1:0] addtree_s1_in  [0:NUM_TREE_S1-1];
logic        [ATREE_WIDTH  -1:0] addtree_s1_out [0:NUM_TREE_S1-1][0:1];

logic        [ATREE_WIDTH*8-1:0] addtree_s2_in  [0:NUM_TREE_S2-1];
logic        [ATREE_WIDTH  -1:0] addtree_s2_out [0:NUM_TREE_S2-1][0:1];

logic        [ATREE_WIDTH*8-1:0] addtree_s3_in  [0:NUM_TREE_S3-1];
logic        [ATREE_WIDTH  -1:0] addtree_s3_out [0:NUM_TREE_S3-1][0:1];

/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

//------------------------- delay -------------------------
always @(posedge clk) begin
    // input valid delay
    in_valid_delay      <= in_valid;
    shift_valid_delay   <= shift_valid;
    z_o_valid_delay     <= z_o_valid;

    // adder tree delay
    addtree_delay       <= (addtree_delay << 1) | shift_valid_delay;

    // output valid
    ms_outvalid         <= shift_valid_delay;
    msz_outvalid        <= z_o_valid_delay;
end

assign psum_valid = addtree_delay[3];


//------------------------- core architecture -------------------------
generate
for (genvar ii=0; ii<NUM_QUANT; ii=ii+1) begin

    // stage input data
    always @(posedge clk) begin
        if (!resetn) begin
            data0[ii] <= 0;
            data1[ii] <= 0;
        end
        else if (in_valid) begin
            data0[ii] <= in_data0[ii];
            data1[ii] <= in_data1[ii];
        end
    end

    // stage input shift
    always @(posedge clk) begin
        if      (!resetn)       shft[ii] <= 0;
        else if (shift_valid)   shft[ii] <= shift[ii];                   // assume we only need 5 bit shifter
    end

    // stage zero point of OUT
    always @(posedge clk) begin
        if      (!resetn)       zo[ii] <= 0;
        else if (z_o_valid)     zo[ii] <= z_o[ii];
    end

    // multiply
//    DW02_mult_2_stage #(.A_width(32), .B_width(10)) multiplier_32x10 (
//        .A       (data0[ii]),
//        .B       (data1[ii]),
//        .TC      (1'b1),
//        .CLK     (clk ),
//        .PRODUCT (mult_result[ii])
//    );
     always @(posedge clk) begin
         if      (!resetn)           mult_result[ii] <= 0;
         else if (in_valid_delay)    mult_result[ii] <= data0[ii] * data1[ii];   // 32-bit x 10-bit multiplier (UINT9 --> Signed INT10)
     end

    // shift
    always @(posedge clk) begin
        if      (!resetn)           shift_result[ii] <= 0;
        else if (shift_valid_delay) shift_result[ii] <= (mult_result[ii] >> shft[ii]);
    end

    // subtract zero point
    always @(posedge clk) begin
        if      (!resetn)           subzo_result[ii] <= 0;
        else if (z_o_valid_delay)   subzo_result[ii] <= shift_result[ii] - zo[ii];  
    end

    assign ms_out   [ii] = shift_result[ii];
    assign msz_out  [ii] = subzo_result[ii];
end
endgenerate


//------------------------- Adder Tree -------------------------

//------------------------- stage 1 -------------------------
always @(*) begin
    for (int i=0; i<NUM_TREE_S1; i=i+1) begin
        addtree_s1_in[i] = {
            shift_result[i*8 + 0],
            shift_result[i*8 + 1],
            shift_result[i*8 + 2],
            shift_result[i*8 + 3],
            shift_result[i*8 + 4],
            shift_result[i*8 + 5],
            shift_result[i*8 + 6],
            shift_result[i*8 + 7]
        };
    end
end

generate
for (genvar ii=0; ii<NUM_TREE_S1; ii=ii+1) begin: tree_s1
    // 32 pairs of addTree
    DW02_tree #(.num_inputs(8), .input_width(ATREE_WIDTH), .verif_en(verif_en)) addTree (
        .INPUT  (addtree_s1_in[ii]),
        .OUT0   (addtree_s1_out[ii][0]),
        .OUT1   (addtree_s1_out[ii][1])
    );
end
endgenerate

//------------------------- stage 2 -------------------------
always @(posedge clk) begin
    for (int i=0; i<NUM_TREE_S2; i=i+1) begin
        addtree_s2_in[i] <= {
            addtree_s1_out[i*4 + 0][0],
            addtree_s1_out[i*4 + 0][1],
            addtree_s1_out[i*4 + 1][0],
            addtree_s1_out[i*4 + 1][1],
            addtree_s1_out[i*4 + 2][0],
            addtree_s1_out[i*4 + 2][1],
            addtree_s1_out[i*4 + 3][0],
            addtree_s1_out[i*4 + 3][1]
        };
    end
end

generate
for (genvar ii=0; ii<NUM_TREE_S2; ii=ii+1) begin: tree_s2
    // 8 pairs of addTree
    DW02_tree #(.num_inputs(8), .input_width(ATREE_WIDTH), .verif_en(verif_en)) addTree (
        .INPUT  (addtree_s2_in[ii]),
        .OUT0   (addtree_s2_out[ii][0]),
        .OUT1   (addtree_s2_out[ii][1])
    );
end
endgenerate

//------------------------- stage 3 -------------------------
always @(posedge clk) begin
    for (int i=0; i<NUM_TREE_S3; i=i+1) begin
        addtree_s3_in[i] <= {
            addtree_s2_out[i*4 + 0][0],
            addtree_s2_out[i*4 + 0][1],
            addtree_s2_out[i*4 + 1][0],
            addtree_s2_out[i*4 + 1][1],
            addtree_s2_out[i*4 + 2][0],
            addtree_s2_out[i*4 + 2][1],
            addtree_s2_out[i*4 + 3][0],
            addtree_s2_out[i*4 + 3][1]
        };
    end
end

generate
for (genvar ii=0; ii<NUM_TREE_S3; ii=ii+1) begin: tree_s3
    // 2 pairs of addTree
    DW02_tree #(.num_inputs(8), .input_width(ATREE_WIDTH), .verif_en(verif_en)) addTree (
        .INPUT  (addtree_s3_in[ii]),
        .OUT0   (addtree_s3_out[ii][0]),
        .OUT1   (addtree_s3_out[ii][1])
    );
end
endgenerate

//------------------------- stage 4 -------------------------
always @(posedge clk) begin
    if (!resetn) begin
        psum0 <= 0;
        psum1 <= 0;
    end
    else begin
        psum0 <= $signed(addtree_s3_out[0][0]) + $signed(addtree_s3_out[0][1]);
        psum1 <= $signed(addtree_s3_out[1][0]) + $signed(addtree_s3_out[1][1]);
    end
end


endmodule