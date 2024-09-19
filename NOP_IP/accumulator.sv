// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME    : accumulator.sv
// AUTHOR       : Lyu-Ming Ho
// -----------------------------------------------------------------------------
// Revision History
// VERSION DATE         AUTHOR          VERSION     DESCRIPTION                             SYN_AREA        SYN_CLK_PERIOD
// 1.0     2024-06-22   Lyu-Ming Ho     v1.0        wire_load_model_top, uncertrainty:10%   221994.108028   0.8
// -----------------------------------------------------------------------------
// PURPOSE: Short description of functionality
// Pure accumulator, no accumulator sram inside this module, sram should be 
// maintained by outside-controller.
// -----------------------------------------------------------------------------

module accumulator #(
    parameter NUM_ACC           = 256   
) (
    input  logic                        clk         ,
    input  logic                        resetn      ,   // synchrous active-low reset

    input  logic                        in_last     ,   // the last input to be accumulated, so after that, out_acc should be reset to 0.
    input  logic                        in_valid    ,   // "outsum_valid" from vectorEngine
    input  logic [NUM_ACC-1:0][32-1:0]  in_data0    ,   // "out"          from vectorEngine (16 * 25), need bit-selection from accumulator controller
    input  logic [NUM_ACC-1:0][32-1:0]  in_data1    ,   // "delta" or "residual"

    output logic                        out_last    ,
    output logic                        out_valid   ,
    output logic [NUM_ACC-1:0][32-1:0]  out_acc     
);

/////////////////////////////////////////////////////////////////////////
// Parameters & Custom datatype
/////////////////////////////////////////////////////////////////////////

//------------------------- Overall Config -------------------------
localparam LATENCY = 2;


/////////////////////////////////////////////////////////////////////////
// Signals
/////////////////////////////////////////////////////////////////////////
logic signed [ 32-1:0 ] A        [0:NUM_ACC-1];
logic signed [ 32-1:0 ] B        [0:NUM_ACC-1];
logic signed [ 32-1:0 ] sum      [0:NUM_ACC-1];
logic signed [ 32-1:0 ] prev_sum [0:NUM_ACC-1];

logic [LATENCY-1:0] in_valid_delay;
logic [LATENCY-1:0] in_last_delay;


/////////////////////////////////////////////////////////////////////////
// Design Logics
/////////////////////////////////////////////////////////////////////////

// Input to Output delay 
assign out_valid    = in_valid_delay [LATENCY-1];
assign out_last     = in_last_delay  [LATENCY-1];

always @(posedge clk) begin
    if (!resetn) begin
        in_valid_delay  <= 0;
        in_last_delay   <= 0;
    end
    else begin            
        in_valid_delay  <= (in_valid_delay << 1) | in_valid;
        in_last_delay   <= (in_last_delay  << 1) | in_last;
    end
end


// Main Accumulator
generate
for (genvar ii=0; ii<NUM_ACC; ii=ii+1) begin

    assign prev_sum[ii] = (out_last) ? 0 : sum[ii];

    always @(posedge clk) begin
        A[ii]   <= (in_valid) ? in_data0[ii] : 0;
        B[ii]   <= (in_valid) ? in_data1[ii] : 0;
    end

    always @(posedge clk) begin
        if (!resetn)    sum[ii] <= 0;
        else            sum[ii] <= (A[ii] + B[ii] + prev_sum[ii]);
    end

    assign out_acc[ii] = sum[ii];
end
endgenerate

endmodule
