// -----------------------------------------------------------------------------
// Copyright (c) 2024, Adar Laboratory (Adar Lab).
// Adar Lab's Proprietary/Confidential.
// -----------------------------------------------------------------------------
// FILE NAME : UniActivation .sv
// AUTHOR : Jye-En Wu
// -----------------------------------------------------------------------------
// `include "ram.sv"
//`include "fsqrt_with2mode.sv"
//`include "rf_sp_8192_15.sv"

module UniActivation (
    clk,
    rst_n,
    op_type,

    // softmax find max
    max_invalid,
    max_data,
    mask_flag_max,
    token_num_max,

    // softmax
    softmax_invalid,
    softmax_data,
    mask_flag_compute,
    token_num,

    // SiLU & GeLU
    SiLU_invalid,
    SiLU_data,

    // RMSnorm
    RMS_invalid,
    RMS_data,
    
    // softmax out
    softmax_out_valid,
    softmax_out_int,
    
    // SiLU & GeLU out
    SiLU_out_valid,
    SiLU_out_int,

    // RMSnorm out
    RMS_out_valid,
    RMS_out_int,
    RMS_out_shift
);

localparam TWO_HEAD             = 1;  // HEAD_NUM  Brian:1   Austin:0
localparam OP_TYPE_BIT          = 3;

// INPUT WIDTH
localparam SOFTMAX_DATA_WIDTH   = 16;
localparam SILU_DATA_WIDTH      = 16;
localparam RMS_DATA_WIDTH       = 32;
localparam TOTAL_TOKEN_WIDTH    = 13;

// OUTPUT WIDTH
localparam SOFTMAX_OUT_WIDTH    = 8;
localparam SILU_OUT_WIDTH       = 16;
localparam RMS_OUT_WIDTH        = 9;
localparam RMS_SHIFT_WIDTH      = 6;

// SRAM 
localparam SRAM_CYCLE   = 1;
localparam SRAM_WIDTH   = 15;
localparam MAX_LENGTH   = 4096;
localparam SRAM_DEPTH   = MAX_LENGTH + TWO_HEAD*MAX_LENGTH;
localparam SRAM_ADDR_BIT= $clog2(SRAM_DEPTH); //$clog2(SRAM_DEPTH);13

// Accumulator
localparam ACC_BIT_WIDTH = 28;
localparam ACC_LOD_INT   = 11;
localparam ACC_LOD_SHIFT = 6;

// fsqrt
localparam FSQRT_IN_WIDTH = 32;
localparam FSQRT_OUT_WIDTH = 9;
localparam FSQRT_SHIFT_WIDTH = 6;

// multiplier
localparam MULTIPLIER_BIT_WIDTH = 9;
localparam MULTIOUT_BIT_WIDTH = 18;
localparam SHIFT_BIT_WIDTH = 6;

localparam [8:0] left_table [0:255] = '{
    511, 452, 399, 352, 311, 274, 484, 427, 377, 332, 293, 259, 457, 403, 356, 314,
    277, 489, 432, 381, 336, 297, 262, 462, 408, 360, 318, 280, 495, 437, 385, 340,
    300, 265, 467, 412, 364, 321, 283, 500, 442, 390, 344, 303, 268, 473, 417, 368,
    325, 287, 506, 447, 394, 348, 307, 271, 478, 422, 372, 329, 290, 512, 452, 399,
    352, 310, 274, 484, 427, 377, 332, 293, 259, 457, 403, 356, 314, 277, 489, 432,
    381, 336, 297, 262, 462, 408, 360, 318, 280, 495, 436, 385, 340, 300, 265, 467,
    412, 364, 321, 283, 250, 221, 195, 172, 152, 134, 118, 104,  92,  81,  72,  63,
     56,  49,  43,  38,  34,  30,  26,  23,  21,  18,  16,  14,  12,  11,  10,   9,
      8,   7,   6,   5,   5,   4,   4,   3,   3,   2,   2,   2,   2,   1,   1,   1,
      1,   1,   1,   1,   1,   1,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
      0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};

localparam [4:0] left_shift [0:255] = '{
     0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,
     2,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,  5,
     5,  5,  6,  6,  6,  6,  6,  7,  7,  7,  7,  7,  7,  8,  8,  8,
     8,  8,  9,  9,  9,  9,  9,  9, 10, 10, 10, 10, 10, 11, 11, 11, 
    11, 11, 11, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14,
    14, 14, 14, 14, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 17, 
    17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
    17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
    17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17,
    17, 17, 17, 17, 17, 17,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
};


localparam [8:0] right_table [0:255] = '{
    511, 511, 511, 511, 511, 511, 511, 510, 510, 510, 510, 509, 509, 509, 509, 508,
    508, 508, 508, 507, 507, 507, 507, 506, 506, 506, 506, 505, 505, 505, 505, 504,
    504, 504, 504, 503, 503, 503, 503, 502, 502, 502, 502, 501, 501, 501, 501, 500,
    500, 500, 500, 499, 499, 499, 499, 498, 498, 498, 498, 497, 497, 497, 497, 496,
    496, 496, 496, 496, 495, 495, 495, 495, 494, 494, 494, 494, 493, 493, 493, 493,
    492, 492, 492, 492, 491, 491, 491, 491, 490, 490, 490, 490, 490, 489, 489, 489,
    489, 488, 488, 488, 488, 487, 487, 487, 487, 486, 486, 486, 486, 485, 485, 485,
    485, 485, 484, 484, 484, 484, 483, 483, 483, 483, 482, 482, 482, 482, 481, 481,
    481, 481, 481, 480, 480, 480, 480, 479, 479, 479, 479, 478, 478, 478, 478, 477,
    477, 477, 477, 477, 476, 476, 476, 476, 475, 475, 475, 475, 474, 474, 474, 474,
    474, 473, 473, 473, 473, 472, 472, 472, 472, 471, 471, 471, 471, 471, 470, 470,
    470, 470, 469, 469, 469, 469, 468, 468, 468, 468, 468, 467, 467, 467, 467, 466,
    466, 466, 466, 465, 465, 465, 465, 465, 464, 464, 464, 464, 463, 463, 463, 463,
    463, 462, 462, 462, 462, 461, 461, 461, 461, 461, 460, 460, 460, 460, 459, 459,
    459, 459, 459, 458, 458, 458, 458, 457, 457, 457, 457, 456, 456, 456, 456, 456,
    455, 455, 455, 455, 454, 454, 454, 454, 454, 453, 453, 453, 453, 453, 452, 452
};

input  logic                                   clk              ;
input  logic                                   rst_n            ;
input  logic        [                     2:0] op_type          ;  // 0:softmax   1:SiLU   2:GeLU   3:RMSnorm  4:tanh

// find max
input  logic                                   max_invalid      ;
input  logic        [  SOFTMAX_DATA_WIDTH-1:0] max_data         ; 
input  logic                                   mask_flag_max    ;
input  logic        [   TOTAL_TOKEN_WIDTH-1:0] token_num_max    ;
// softmax
input  logic                                   softmax_invalid  ;
input  logic        [  SOFTMAX_DATA_WIDTH-1:0] softmax_data     ; 
input  logic                                   mask_flag_compute;
input  logic        [   TOTAL_TOKEN_WIDTH-1:0] token_num        ; // 4096

// SiLU & GeLU
input logic                                    SiLU_invalid     ;
input logic         [     SILU_DATA_WIDTH-1:0] SiLU_data        ;

// RMSnorm
input logic                                    RMS_invalid      ;
input logic         [      RMS_DATA_WIDTH-1:0] RMS_data         ;

// softmax
output logic                                   softmax_out_valid;
output logic        [   SOFTMAX_OUT_WIDTH-1:0] softmax_out_int  ;

// SiLU & GeLU
output logic                                   SiLU_out_valid   ;
output logic        [      SILU_OUT_WIDTH-1:0] SiLU_out_int     ;

// // RMSnorm
output logic                                   RMS_out_valid    ;
output logic        [       RMS_OUT_WIDTH-1:0] RMS_out_int      ;
output logic        [     RMS_SHIFT_WIDTH-1:0] RMS_out_shift    ;



// find max
logic                                   max_invalid_delay            ;
logic                                   head_flag                    ;
logic        [  SOFTMAX_DATA_WIDTH-1:0] max_data_reg                 ;
logic                                   mask_flag_max_reg            ;
logic        [   TOTAL_TOKEN_WIDTH-1:0] token_num_max_reg            ;
logic        [   TOTAL_TOKEN_WIDTH-1:0] token_counter                ;
logic        [  SOFTMAX_DATA_WIDTH-1:0] head0_max,head1_max          ;
logic        [  SOFTMAX_DATA_WIDTH-1:0] head0_max_hold,head1_max_hold;


logic        [                     2:0] op_type_reg                  ;
           

// softmax
logic        [                     4:0] softmax_invalid_delay        ;
logic                                   softmax_head_flag            ;
logic        [  SOFTMAX_DATA_WIDTH-1:0] softmax_reg                  ;
logic                                   mask_flag_compute_reg        ;
logic                                   mask_flag_compute_reg_delay  ;
logic        [   TOTAL_TOKEN_WIDTH-1:0] token_num_reg                ;
logic                                   first_data_flag              ;
logic        [  SOFTMAX_DATA_WIDTH-1:0] head0_max_reg,head1_max_reg  ;


// SiLU & GeLU
logic        [                     5:0] SiLU_invalid_delay           ;
logic        [  SOFTMAX_DATA_WIDTH-1:0] SiLU_reg                     ;        
logic                                   negative_flag                ;
logic        [  SOFTMAX_DATA_WIDTH-1:0] SiLU_abs                     ;
logic        [                     4:0] SiLU_out_delay               ;
logic        [MULTIPLIER_BIT_WIDTH-1:0] numerator_int                ;

logic                                   GeLU_mul_delay               ;





// ACC LOD
logic        [         ACC_BIT_WIDTH-1:0]  ACC_LOD_in;
logic        [             ACC_LOD_INT:0]  ACC_LOD_int;
logic        [         ACC_LOD_SHIFT-1:0]  ACC_LOD_shift,ACC_LOD_shift_reg0,ACC_LOD_shift_reg1;
logic        [           ACC_LOD_INT-1:0]  ACC_LOD_int_round,ACC_LOD_out;


// ACCumulator
logic        [    MULTIOUT_BIT_WIDTH-1:0]  ACC_in;
logic        [         ACC_BIT_WIDTH-1:0]  ACC_reg0,ACC_reg1;
logic        [                       1:0]  ACC_done_0,ACC_done_1;
logic                                      fsqrt_done;


// shifter 
logic        [       SHIFT_BIT_WIDTH-1:0]  shifter_in_num;
logic        [    MULTIOUT_BIT_WIDTH-1:0]  shifter_in_data,shifter_out,shifter_out_reg;

logic        [       SHIFT_BIT_WIDTH-1:0]  l_shifter_in_num;
logic        [    MULTIOUT_BIT_WIDTH-1:0]  l_shifter_in_data,l_shifter_out;


// SRAM
logic        [         SRAM_ADDR_BIT-1:0]  SRAM_addr;
logic        [            SRAM_WIDTH-1:0]  SRAM_in,SRAM_out,SRAM_out_reg;
logic                                      SRAM_write_enable;
logic                                      SRAM_read_flag;
logic        [                      4:0]   SRAM_read_flag_delay;


// LOD 
logic        [    MULTIOUT_BIT_WIDTH-1:0]  LOD_in;
logic        [    MULTIPLIER_BIT_WIDTH:0]  LOD_int;
logic        [       SHIFT_BIT_WIDTH-1:0]  LOD_shift;
logic        [  MULTIPLIER_BIT_WIDTH-1:0]  LOD_int_round,LOD_out;


// Multiplier
logic        [  MULTIPLIER_BIT_WIDTH-1:0]  multiplier_in_a,multiplier_in_b;
logic        [    MULTIOUT_BIT_WIDTH-1:0]  multiplier_c,multiplier_c_reg;


// exp && shift
logic        [    SOFTMAX_DATA_WIDTH-1:0]  exp_in;
logic        [  MULTIPLIER_BIT_WIDTH-1:0]  exp_left,exp_right;
logic        [       SHIFT_BIT_WIDTH-1:0]  shift_left        ;
logic        [       SHIFT_BIT_WIDTH-1:0]  shift_left_delay  ;
logic        [       SHIFT_BIT_WIDTH-1:0]  shift_acc_in,shift_acc;


// sub max
logic        [  SOFTMAX_DATA_WIDTH-1:0]  max_sub_in_a,max_sub_in_b;
logic        [    SOFTMAX_DATA_WIDTH:0]  max_sub_c                ;
logic        [  SOFTMAX_DATA_WIDTH-1:0]  max_sub_c_reg            ;


// fsqrt
logic                                      fsqrt_op_type;
logic                                      fsqrt_in_valid;
logic        [        FSQRT_IN_WIDTH-1:0]  fsqrt_in_data;

logic                                      fsqrt_out_valid;
logic        [       FSQRT_OUT_WIDTH-1:0]  fsqrt_out_int;
logic        [     FSQRT_SHIFT_WIDTH-1:0]  fsqrt_out_shift;
logic        [       FSQRT_OUT_WIDTH-1:0]  fsqrt_reg0,fsqrt_reg1;



//  ******************************************************************************* 
//                                softmax  find max
//  *******************************************************************************
always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        max_invalid_delay <= 1'b0;
        max_data_reg      <=  'd0;
        mask_flag_max_reg <= 1'b0;
        token_num_max_reg <=  'd0;
    end
    else begin
        max_invalid_delay <= max_invalid;
        if (max_invalid) begin
            token_num_max_reg <= token_num_max;
            max_data_reg      <= max_data;
            mask_flag_max_reg <= mask_flag_max;
        end
        else begin
            max_data_reg      <=  'd0;
            mask_flag_max_reg <= 1'b0;
            token_num_max_reg <= token_num_max_reg;
        end
    end
end

always_ff @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        token_counter <= 'd0;
    end
    else begin
        if (max_invalid_delay && (head_flag || (TWO_HEAD == 'd0))) begin
            token_counter <= token_counter + 1'b1;
        end
        else if ((token_counter == token_num_max_reg) && !head_flag) begin
            token_counter <= 'd0;
        end
        else begin
            token_counter <= token_counter;
        end
    end
end

always_ff @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        head_flag <= 1'b0;
    end
    else begin
        if(max_invalid_delay && TWO_HEAD == 'd1) begin
            head_flag <= !head_flag;
        end
        else begin
            head_flag <= head_flag;
        end
    end
end

always_ff @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        head0_max <= 16'h8000;
    end
    else begin
        if (max_invalid_delay && !head_flag && !mask_flag_max_reg) begin
            head0_max <= ($signed(head0_max) < $signed(max_data_reg))? max_data_reg : head0_max;
        end
        else if ((token_counter == token_num_max_reg) && !head_flag) begin
            head0_max <= 16'h8000;
        end
        else begin
            head0_max <= head0_max;
        end
    end
end

always_ff @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        head1_max <= 16'h8000;
    end
    else begin
        if (max_invalid_delay && head_flag && !mask_flag_max_reg) begin
            head1_max <= ($signed(head1_max) < $signed(max_data_reg))? max_data_reg : head1_max;
        end
        else if ((token_counter == token_num_max_reg) && !head_flag) begin
            head1_max <= 16'h8000;
        end
        else begin
            head1_max <= head1_max;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        head0_max_hold <= 'd0;
        head1_max_hold <= 'd0;
    end
    else begin
        if ((token_counter == token_num_max_reg) && !head_flag) begin
            head0_max_hold <= head0_max;
            head1_max_hold <= head1_max;
        end
        else begin
            head0_max_hold <= head0_max_hold;
            head1_max_hold <= head1_max_hold;
        end
    end
end


// ******************************************************************************************
//                                                 input
// ******************************************************************************************

// op_type_reg
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        op_type_reg <= 'd0;
    end
    else begin
        // if(softmax_invalid || SiLU_invalid || RMS_invalid) begin
        if(softmax_invalid || SiLU_invalid || RMS_invalid) begin
            op_type_reg <= op_type;
        end
        else begin
            op_type_reg <= op_type_reg;
        end
    end
end

// -------------------------------------------------
//                 softmax input
// -------------------------------------------------
always_ff @(posedge clk,negedge rst_n) begin
    if (!rst_n) begin
        softmax_invalid_delay <= 'd0;
    end
    else begin
        softmax_invalid_delay[0] <= softmax_invalid;
        softmax_invalid_delay[1] <= softmax_invalid_delay[0];
        softmax_invalid_delay[2] <= softmax_invalid_delay[1];
        softmax_invalid_delay[3] <= softmax_invalid_delay[2];
        softmax_invalid_delay[4] <= softmax_invalid_delay[3];
    end
end


always_ff @(posedge clk,negedge rst_n) begin
    if (!rst_n) begin
        softmax_reg <= 'd0;
    end
    else begin
        if (softmax_invalid) begin
            softmax_reg <= softmax_data;
        end
        else begin
            softmax_reg <= 'd0;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        first_data_flag <= 1'b0;
    end
    else begin
        if (softmax_invalid) begin
            first_data_flag <= 1'b1;
        end
        else if (softmax_out_valid) begin
            first_data_flag <= 1'b0;
        end
        else begin
            first_data_flag <= first_data_flag;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        token_num_reg <= 'd0;
        mask_flag_compute_reg <= 1'b0;
    end
    else begin
        if (softmax_invalid) begin
            token_num_reg <= token_num;
            mask_flag_compute_reg <= mask_flag_compute;
        end
        else begin
            token_num_reg <= token_num_reg;
            mask_flag_compute_reg <= 1'b0;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        mask_flag_compute_reg_delay <= 1'd0;
    end
    else begin
        mask_flag_compute_reg_delay <= mask_flag_compute_reg;
    end
end


always_ff @(posedge clk,negedge rst_n) begin
    if(!rst_n) begin
        softmax_head_flag <= 1'b0;
    end
    else begin
        if(softmax_invalid_delay[0] && TWO_HEAD == 'd1) begin
            softmax_head_flag <= !softmax_head_flag;
        end
        else if (SRAM_read_flag_delay[1] && TWO_HEAD == 'd1) begin
            softmax_head_flag <= !softmax_head_flag;
        end
        else begin
            softmax_head_flag <= softmax_head_flag;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        head0_max_reg <= 'd0;
        head1_max_reg <= 'd0;
    end
    else begin
        if (softmax_invalid && !first_data_flag) begin
            if ((token_counter == token_num_max_reg) && !head_flag) begin
                head0_max_reg <= head0_max;
                head1_max_reg <= head1_max;
            end
            else begin
                head0_max_reg <= head0_max_hold;
                head1_max_reg <= head1_max_hold;
            end
        end
        else begin
            head0_max_reg <= head0_max_reg;
            head1_max_reg <= head1_max_reg;
        end
    end
end

// -------------------------------------------------
//               SiLU & GeLU input
// -------------------------------------------------

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        SiLU_invalid_delay <= 'd0;
        GeLU_mul_delay <= 'd0;
    end
    else begin
        if (op_type_reg == 'd1) begin
            SiLU_invalid_delay[0] <= SiLU_invalid;
            SiLU_invalid_delay[1] <= SiLU_invalid_delay[0];
            SiLU_invalid_delay[2] <= SiLU_invalid_delay[1];
            SiLU_invalid_delay[3] <= SiLU_invalid_delay[2];
            SiLU_invalid_delay[4] <= SiLU_invalid_delay[3];
            SiLU_invalid_delay[5] <= SiLU_invalid_delay[4];
            GeLU_mul_delay        <= 'd0;
        end
        else begin  //GeLU
            SiLU_invalid_delay[0] <= SiLU_invalid;
            GeLU_mul_delay        <= SiLU_invalid_delay[0];
            SiLU_invalid_delay[1] <= GeLU_mul_delay       ;
            SiLU_invalid_delay[2] <= SiLU_invalid_delay[1];
            SiLU_invalid_delay[3] <= SiLU_invalid_delay[2];
            SiLU_invalid_delay[4] <= SiLU_invalid_delay[3];
            SiLU_invalid_delay[5] <= SiLU_invalid_delay[4];
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        SiLU_reg <= 'd0;
    end
    else begin
        if (SiLU_invalid) begin
            SiLU_reg <= SiLU_data;
        end
        else if (SiLU_invalid_delay[0]) begin
            SiLU_reg <= SiLU_abs;
        end
        else if (SiLU_invalid_delay[1]) begin
            if (op_type_reg == 'd1) begin
                if (SiLU_reg[15] || SiLU_reg[14]) begin
                    SiLU_reg <= 16'hffff;
                end
                else begin
                    SiLU_reg <= {SiLU_reg[13:0],2'b0};
                end
            end
            else begin
                if (multiplier_c_reg[17]) begin
                    SiLU_reg <= 16'hffff;
                end
                else begin
                    SiLU_reg <= {multiplier_c_reg[16:1]};
                end
            end
        end
        else begin
            SiLU_reg <= SiLU_reg;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        negative_flag <= 1'b0;
    end
    else begin
        if (SiLU_invalid_delay[0]) begin
            negative_flag <= SiLU_reg[15];
        end
        else if (SiLU_out_valid) begin
            negative_flag <= 1'b0;
        end
        else begin
            negative_flag <= negative_flag;
        end
    end
end

always_comb begin
    if (SiLU_reg[15]) begin
        SiLU_abs = ~SiLU_reg + 1;
    end
    else begin
        SiLU_abs = SiLU_reg;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        SiLU_out_delay <= 'd0;
    end
    else begin
        if ((op_type_reg == 'd1 || op_type_reg == 'd2) && fsqrt_out_valid) begin
            SiLU_out_delay[0] <= 1'b1;
        end
        else begin
            SiLU_out_delay[0] <= 1'b0;
        end
        SiLU_out_delay[1] <= SiLU_out_delay[0];
        SiLU_out_delay[2] <= SiLU_out_delay[1];
        SiLU_out_delay[3] <= SiLU_out_delay[2];
        SiLU_out_delay[4] <= SiLU_out_delay[3];
    end
end


// -------------------------------------------------
//                  RMS input
// -------------------------------------------------
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        
    end
    else begin
        
    end
end



// -------------------------------------------------------------
//                          cal
// -------------------------------------------------------------
// sub max

always_comb begin
    if (softmax_invalid_delay[0] && !softmax_head_flag) begin
        max_sub_in_a = head0_max_reg;
    end
    else if (softmax_invalid_delay[0] && softmax_head_flag) begin
        max_sub_in_a = head1_max_reg;
    end
    else if (SiLU_out_delay[0]) begin
        max_sub_in_a = 'h400;         // 1* (2**10) - fsqrt_out
    end
    else begin
        max_sub_in_a = 'd0;
    end
end

always_comb begin
    if (softmax_invalid_delay[0]) begin
        max_sub_in_b = softmax_reg;
    end
    else if (SiLU_out_delay[0]) begin
        max_sub_in_b = {5'b0,l_shifter_out[10:0]};
    end
    else begin
        max_sub_in_b = 'd0;
    end
end

always_comb begin
    max_sub_c = $signed(max_sub_in_a) - $signed(max_sub_in_b);
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        max_sub_c_reg <= 'd0;
    end
    else begin
        if (softmax_invalid_delay[0]) begin
            max_sub_c_reg <= max_sub_c[SOFTMAX_DATA_WIDTH-1:0];
        end
        else if (SiLU_out_delay[0]) begin
            max_sub_c_reg <=  max_sub_c[SOFTMAX_DATA_WIDTH-1:0];
        end
        else begin
            max_sub_c_reg <= 'd0;
        end
    end
end


// exp && shift

always_comb begin
    if (softmax_invalid_delay[1]) begin
        exp_in = max_sub_c_reg;
    end
    else if (SiLU_invalid_delay[2]) begin
        exp_in = SiLU_reg;
    end
    else begin
        exp_in = 'd0;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        exp_right  <= 'd0;
        exp_left   <= 'd0;
        shift_left <= 'd0;
    end
    else begin
        if (softmax_invalid_delay[1]) begin
            if (mask_flag_compute_reg_delay) begin
                exp_right  <= 'd0;
                exp_left   <= 'd0;
                shift_left <= 'd0;
            end
            else begin
                exp_right  <= right_table[exp_in[7:0]];
                exp_left   <= left_table[exp_in[15:8]];
                shift_left <= left_shift[exp_in[15:8]];
            end
        end
        else if (SiLU_invalid_delay[2]) begin
            exp_right  <= right_table[exp_in[7:0]];
            exp_left   <= left_table[exp_in[15:8]];
            shift_left <= left_shift[exp_in[15:8]];
        end
        else begin
            exp_right  <= exp_right;
            exp_left   <= exp_left;
            shift_left <= shift_left;
        end
    end
end

always_ff @(posedge clk,negedge rst_n) begin
    if (!rst_n) begin
        shift_left_delay <= 'd0;
    end
    else begin
        shift_left_delay <= shift_left;
    end
end

always_comb begin
    // softmax
    if (softmax_invalid_delay[3]) begin
        shift_acc_in = shift_left_delay - LOD_shift;
    end
    else if (SRAM_read_flag_delay[1] &&!softmax_head_flag) begin
        shift_acc_in = ACC_LOD_shift_reg0 + SRAM_out_reg[5:0];
    end
    else if (SRAM_read_flag_delay[1] &&softmax_head_flag) begin
        shift_acc_in = ACC_LOD_shift_reg1 + SRAM_out_reg[5:0];
    end
    // SiLU
    else if (SiLU_invalid_delay[1]) begin
        shift_acc_in = LOD_shift;
    end
    else if (SiLU_out_delay[1]) begin
        shift_acc_in = shift_acc + LOD_shift;
    end
    else if (SiLU_out_delay[2]) begin
        shift_acc_in = 'd10 - shift_acc;
    end
    else begin
        shift_acc_in = 'd0;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        shift_acc <= 'd0;
    end
    else begin
        if (op_type_reg == 'd1 || op_type_reg == 'd2) begin
            if (SiLU_invalid_delay[1] || SiLU_out_delay[1] || SiLU_out_delay[2]) begin
                shift_acc <= shift_acc_in;
            end
            else begin
                shift_acc <= shift_acc;
            end
        end
        else begin
            shift_acc <= shift_acc_in;
        end
    end
end


// Multiplier

always_comb begin
    if (softmax_invalid_delay[2] || SiLU_invalid_delay[3]) begin
        multiplier_in_a = exp_right;
    end
    else if (SRAM_read_flag_delay[1]) begin
        if ((TWO_HEAD == 0) || !softmax_head_flag) begin
            multiplier_in_a = fsqrt_reg0;
        end
        else begin
            multiplier_in_a = fsqrt_reg1;
        end
    end
    else if (SiLU_out_delay[2]) begin
        multiplier_in_a = LOD_out;
    end
    else if (GeLU_mul_delay) begin
        if (SiLU_reg[15] || SiLU_reg[14]) begin
            multiplier_in_a = 9'h1ff;         //clamp
        end
        else begin
            multiplier_in_a = SiLU_reg[13:5];
        end
    end
    else begin
        multiplier_in_a = 'd0;
    end
end

always_comb begin
    if (softmax_invalid_delay[2] || SiLU_invalid_delay[3]) begin
        multiplier_in_b = exp_left;
    end
    else if (SRAM_read_flag_delay[1]) begin
        multiplier_in_b = SRAM_out_reg[14:6];
    end
    else if (SiLU_out_delay[2]) begin
        multiplier_in_b = numerator_int;
    end
    else if (GeLU_mul_delay) begin
        multiplier_in_b = 'd436;            //GeLU 1.702 = 436 >> 8
    end
    else begin
        multiplier_in_b = 'd0;
    end
end

always_comb begin
    multiplier_c = multiplier_in_a * multiplier_in_b;
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        multiplier_c_reg <= 'd0;
    end
    else begin
        multiplier_c_reg <= multiplier_c;
    end
end

// LOD 

always_comb begin
    if (softmax_invalid_delay[3]) begin
        LOD_in = multiplier_c_reg;
    end
    else if (SiLU_invalid_delay[1]) begin
        LOD_in = {2'd0,SiLU_reg};
    end
    else if (SiLU_out_delay[1]) begin
        if (negative_flag) begin
            LOD_in = {2'd0,max_sub_c_reg};
        end
        else begin
            LOD_in = shifter_out_reg;
        end
    end
    else begin
        LOD_in = 'd0;
    end
end

always_comb begin
    LOD_int = 'd0;
    LOD_shift = 'd0;
    casez(LOD_in)
        18'b1?_????_????_????_????: begin LOD_shift =  9; LOD_int =  LOD_in[17:8]       ;end
        18'b01_????_????_????_????: begin LOD_shift =  8; LOD_int =  LOD_in[16:7]       ;end
        18'b00_1???_????_????_????: begin LOD_shift =  7; LOD_int =  LOD_in[15:6]       ;end
        18'b00_01??_????_????_????: begin LOD_shift =  6; LOD_int =  LOD_in[14:5]       ;end
        18'b00_001?_????_????_????: begin LOD_shift =  5; LOD_int =  LOD_in[13:4]       ;end
        18'b00_0001_????_????_????: begin LOD_shift =  4; LOD_int =  LOD_in[12:3]       ;end
        18'b00_0000_1???_????_????: begin LOD_shift =  3; LOD_int =  LOD_in[11:2]       ;end
        18'b00_0000_01??_????_????: begin LOD_shift =  2; LOD_int =  LOD_in[10:1]       ;end
        18'b00_0000_001?_????_????: begin LOD_shift =  1; LOD_int =  LOD_in[ 9:0]       ;end
        18'b00_0000_0001_????_????: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_1???_????: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_01??_????: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_001?_????: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_0001_????: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_0000_1???: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_0000_01??: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_0000_001?: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
        18'b00_0000_0000_0000_0001: begin LOD_shift =  0; LOD_int = {LOD_in[ 8:0], 1'b0};end
    endcase
end

always_comb  begin
    LOD_int_round = (LOD_int[9:1] == 9'h1ff)? LOD_int[9:1]:(LOD_int[9:1] + LOD_int[0]); //rounding
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        LOD_out <= 0;
    end
    else begin
        if (op_type_reg == 'd1 || op_type_reg == 'd2) begin
            if (SiLU_invalid_delay[1]) begin
                LOD_out <= LOD_int_round;
            end
            else if (SiLU_out_delay[1]) begin
                LOD_out <= LOD_int_round;
            end
            else begin
                LOD_out <= LOD_out;
            end
        end
        else begin
            LOD_out <= LOD_int_round;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        numerator_int <= 'd0;
    end
    else begin
        if (SiLU_invalid_delay[2]) begin
            numerator_int <= LOD_out;
        end
        else if (SiLU_out_valid) begin
            numerator_int <= 'd0;
        end
        else begin
            numerator_int <= numerator_int;
        end
    end
end


// SRAM

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        SRAM_read_flag_delay <= 'd0;
    end
    else begin
        SRAM_read_flag_delay[0] <= SRAM_read_flag;
        SRAM_read_flag_delay[1] <= SRAM_read_flag_delay[0];
        SRAM_read_flag_delay[2] <= SRAM_read_flag_delay[1];
        SRAM_read_flag_delay[3] <= SRAM_read_flag_delay[2];
        SRAM_read_flag_delay[4] <= SRAM_read_flag_delay[3];
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        SRAM_read_flag <= 1'b0;
    end
    else begin
        if (fsqrt_out_valid && fsqrt_done && op_type_reg == 'd0 && TWO_HEAD == 1) begin
            SRAM_read_flag <= 1'b1;
        end
        else if (fsqrt_out_valid && op_type_reg == 'd0 && TWO_HEAD == 0) begin
            SRAM_read_flag <= 1'b1;
        end
        else if ((SRAM_addr == (token_num_reg*2)-1'b1) && TWO_HEAD == 1) begin
            SRAM_read_flag <= 'd0;
        end
        else if ((SRAM_addr == token_num_reg-1'b1) && TWO_HEAD == 0) begin
            SRAM_read_flag <= 'd0;
        end
        else begin
            SRAM_read_flag <= SRAM_read_flag;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        SRAM_addr <= 'd0;
    end
    else begin
        if ((SRAM_addr == ((token_num_reg*2)-1'b1)) && (TWO_HEAD == 1) && (softmax_invalid_delay[4] || SRAM_read_flag)) begin
            SRAM_addr <= 'd0;
        end
        else if ((SRAM_addr == token_num_reg-1'b1) && TWO_HEAD == 0 && (softmax_invalid_delay[4] || SRAM_read_flag)) begin
            SRAM_addr <= 'd0;
        end
        else if (softmax_invalid_delay[4]) begin
            SRAM_addr <= SRAM_addr + 1'b1;
        end
        else if (SRAM_read_flag) begin
            SRAM_addr <= SRAM_addr + 1'b1;
        end
        else begin
            SRAM_addr <= SRAM_addr;
        end
    end
end

always_comb begin
    if (softmax_invalid_delay[4]) begin
        SRAM_in = {LOD_out,shift_acc};
    end
    else begin
        SRAM_in = 'd0;
    end
end

always_comb begin
    if (softmax_invalid_delay[4]) begin
        SRAM_write_enable = 1'b1;
    end
    else begin
        SRAM_write_enable = 1'b0;
    end
end

logic  CEN;
always_comb begin
    // CEN = 'b0;
    if (op_type_reg == 'd0) begin
        CEN = 'b0;
    end
    else begin
        CEN = 'b1;
    end
end
rf_sramfile_8192_15 S1(
    .CLK(clk),
    .Q(SRAM_out),
    .A(SRAM_addr),
    .D(SRAM_in),
    .WEN(!SRAM_write_enable),            // 0: write, 1: read
    .CEN(CEN)
);

// single_port_ram #(.cycle(SRAM_CYCLE), .width(SRAM_WIDTH), .depth(SRAM_DEPTH)) S1(
//     .clk(clk),
//     .addr(SRAM_addr),
//     .write_enable(SRAM_write_enable),            // 1: write, 0: read
//     .D(SRAM_in),
//     .Q(SRAM_out)
// );

// always_ff @(posedge clk, negedge rst_n) begin
//     if (!rst_n) begin
//         SRAM_out_reg <= 'd0;
//     end
//     else begin
//         if (SRAM_read_flag_delay[1]) begin
//             SRAM_out_reg <= SRAM_out;
//         end
//         else begin
//             SRAM_out_reg <= 'd0;
//         end
//     end
// end
always_comb begin
    if (SRAM_read_flag_delay[1]) begin
        SRAM_out_reg = SRAM_out;
    end
    else begin
        SRAM_out_reg = 'd0;
    end
end


// shifter 
always_comb begin
    if (SiLU_out_delay[0]) begin
        l_shifter_in_data = {9'b0,fsqrt_reg0};
        l_shifter_in_num  = 'd20 - ACC_LOD_shift_reg0;
    end
    else begin
        l_shifter_in_data = 'd0;
        l_shifter_in_num  = 'd0;
    end
end

always_comb begin
    l_shifter_out = (l_shifter_in_data << l_shifter_in_num);
end


always_comb begin
    if (softmax_invalid_delay[3]) begin
        shifter_in_num = shift_left_delay;
    end
    else if (SRAM_read_flag_delay[2]) begin
        shifter_in_num = shift_acc - 9;   // (-9 => Q0.9) rounding to Q0.8
    end
    else if (SiLU_invalid_delay[4]) begin
        shifter_in_num = shift_left;
    end
    // else if (SiLU_out_delay[0]) begin
    //     shifter_in_num = ACC_LOD_shift_reg0;    // SiLU after fsqrt shifter  10bit
    // end
    else if (SiLU_out_delay[3]) begin
        shifter_in_num = shift_acc-1;   // (-10 => Q7.10) rounding to Q7.9
    end
    else begin
        shifter_in_num = 'd0;
    end
end

always_comb begin
    if (softmax_invalid_delay[3] || SiLU_invalid_delay[4]) begin
        shifter_in_data = multiplier_c_reg;
    end
    else if (SRAM_read_flag_delay[2]) begin
        shifter_in_data = multiplier_c_reg;
    end
    // else if (SiLU_out_delay[0]) begin
    //     shifter_in_data = {9'b0,fsqrt_reg0};
    // end
    else if (SiLU_out_delay[3]) begin
        shifter_in_data = multiplier_c_reg;
    end
    else begin
        shifter_in_data = 'd0;
    end
end

always_comb begin
    shifter_out = (shifter_in_data >> shifter_in_num);
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        shifter_out_reg <= 'd0;
    end
    else begin
        if (op_type_reg == 'd1 || op_type_reg == 'd2) begin
            if (SiLU_invalid_delay[4]) begin
                if (shifter_out[17:8] == 10'h3ff) begin
                    shifter_out_reg <= {7'b0,1'b1,shifter_out[17:8]};                      //rounding
                end
                else begin
                    shifter_out_reg <= {7'b0,1'b1,{shifter_out[17:8] + shifter_out[7]}};   //rounding
                end
            end
            else if (SiLU_out_delay[0]) begin
                shifter_out_reg <= l_shifter_out;
            end
            else if (SiLU_out_delay[3]) begin
                shifter_out_reg <= (shifter_out[16:1] == 16'hffff)? shifter_out[16:1]:shifter_out[16:1]+shifter_out[0]; //rounding
            end
            else begin
                shifter_out_reg <= shifter_out_reg;
            end
        end
        else begin
            shifter_out_reg <= shifter_out;
        end
    end
end
// ACCumulator

always_comb begin
    if (softmax_invalid_delay[4]) begin
        ACC_in = shifter_out_reg;
    end
    else begin
        ACC_in = 'd0;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ACC_reg0 <= 'd0;
    end
    else begin
        if (softmax_invalid_delay[4] && !SRAM_addr[0] && (TWO_HEAD == 1)) begin
            ACC_reg0 <= ACC_reg0 + ACC_in;
        end
        else if (softmax_invalid_delay[4] && (TWO_HEAD == 0)) begin
            ACC_reg0 <= ACC_reg0 + ACC_in;
        end
        else if (softmax_out_valid) begin
            ACC_reg0 <= 'd0;
        end
        else begin
            ACC_reg0 <= ACC_reg0;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ACC_reg1 <= 'd0;
    end
    else begin
        if (softmax_invalid_delay[4] && SRAM_addr[0] && (TWO_HEAD == 1)) begin
            ACC_reg1 <= ACC_reg1 + ACC_in;
        end
        else if (softmax_out_valid) begin
            ACC_reg1 <= 'd0;
        end
        else begin
            ACC_reg1 <= ACC_reg1;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ACC_done_0 <= 2'b0;
    end
    else begin
        if (SRAM_addr == ((token_num_reg-1'b1)*2) && TWO_HEAD == 1 && !fsqrt_done && !softmax_out_valid && (softmax_invalid_delay[4] || SRAM_read_flag)) begin
            ACC_done_0[0] <= 1'b1;
        end
        else if (SRAM_addr == (token_num_reg-1'b1) && TWO_HEAD == 0 && !fsqrt_done && !softmax_out_valid && (softmax_invalid_delay[4] || SRAM_read_flag)) begin
            ACC_done_0[0] <= 1'b1;
        end
        else begin
            ACC_done_0[0] <= 1'b0;
        end
        ACC_done_0[1] <= ACC_done_0[0];
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ACC_done_1 <= 2'b0;
    end
    else begin
        if (TWO_HEAD == 1) begin
            if (fsqrt_out_valid && !fsqrt_done && op_type_reg == 'd0) begin
                ACC_done_1[0] <= 1'b1;
            end
            else begin
                ACC_done_1[0] <= 1'b0;;
            end
            ACC_done_1[1] <= ACC_done_1[0];
        end
        else begin
            ACC_done_1[0] <= 1'b0;
            ACC_done_1[1] <= 1'b0;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        fsqrt_done <= 1'b0;
    end
    else begin
        if (fsqrt_out_valid && op_type_reg == 'd0) begin
            fsqrt_done <= 1'b1;
        end
        else if (softmax_out_valid) begin
            fsqrt_done <= 1'b0;
        end
        else begin
            fsqrt_done <= fsqrt_done;
        end
    end
end

// ACC LOD

always_comb begin
    if (ACC_done_0[0]) begin
        ACC_LOD_in = ACC_reg0;
    end
    else if (ACC_done_1[0]) begin
        ACC_LOD_in = ACC_reg1;
    end
    else begin
        ACC_LOD_in = 'd0;
    end
end

always_comb begin
    ACC_LOD_int = 'd0;
    ACC_LOD_shift = 'd0;
    casez(ACC_LOD_in)
        28'b1???_????_????_????_????_????_????: begin ACC_LOD_shift = 17; ACC_LOD_int =  ACC_LOD_in[27:16]       ;end
        28'b01??_????_????_????_????_????_????: begin ACC_LOD_shift = 16; ACC_LOD_int =  ACC_LOD_in[26:15]       ;end
        28'b001?_????_????_????_????_????_????: begin ACC_LOD_shift = 15; ACC_LOD_int =  ACC_LOD_in[25:14]       ;end
        28'b0001_????_????_????_????_????_????: begin ACC_LOD_shift = 14; ACC_LOD_int =  ACC_LOD_in[24:13]       ;end
        28'b0000_1???_????_????_????_????_????: begin ACC_LOD_shift = 13; ACC_LOD_int =  ACC_LOD_in[23:12]       ;end
        28'b0000_01??_????_????_????_????_????: begin ACC_LOD_shift = 12; ACC_LOD_int =  ACC_LOD_in[22:11]       ;end
        28'b0000_001?_????_????_????_????_????: begin ACC_LOD_shift = 11; ACC_LOD_int =  ACC_LOD_in[21:10]       ;end
        28'b0000_0001_????_????_????_????_????: begin ACC_LOD_shift = 10; ACC_LOD_int =  ACC_LOD_in[20: 9]       ;end
        28'b0000_0000_1???_????_????_????_????: begin ACC_LOD_shift =  9; ACC_LOD_int =  ACC_LOD_in[19: 8]       ;end
        28'b0000_0000_01??_????_????_????_????: begin ACC_LOD_shift =  8; ACC_LOD_int =  ACC_LOD_in[18: 7]       ;end
        28'b0000_0000_001?_????_????_????_????: begin ACC_LOD_shift =  7; ACC_LOD_int =  ACC_LOD_in[17: 6]       ;end
        28'b0000_0000_0001_????_????_????_????: begin ACC_LOD_shift =  6; ACC_LOD_int =  ACC_LOD_in[16: 5]       ;end
        28'b0000_0000_0000_1???_????_????_????: begin ACC_LOD_shift =  5; ACC_LOD_int =  ACC_LOD_in[15: 4]       ;end
        28'b0000_0000_0000_01??_????_????_????: begin ACC_LOD_shift =  4; ACC_LOD_int =  ACC_LOD_in[14: 3]       ;end
        28'b0000_0000_0000_001?_????_????_????: begin ACC_LOD_shift =  3; ACC_LOD_int =  ACC_LOD_in[13: 2]       ;end
        28'b0000_0000_0000_0001_????_????_????: begin ACC_LOD_shift =  2; ACC_LOD_int =  ACC_LOD_in[12: 1]       ;end
        28'b0000_0000_0000_0000_1???_????_????: begin ACC_LOD_shift =  1; ACC_LOD_int =  ACC_LOD_in[11: 0]       ;end
        28'b0000_0000_0000_0000_01??_????_????: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_001?_????_????: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0001_????_????: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_1???_????: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_01??_????: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_001?_????: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_0001_????: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_0000_1???: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_0000_01??: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_0000_001?: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
        28'b0000_0000_0000_0000_0000_0000_0001: begin ACC_LOD_shift =  0; ACC_LOD_int = {ACC_LOD_in[10: 0], 1'b0};end
    endcase
end

always_comb  begin
    ACC_LOD_int_round = (ACC_LOD_int[11:1] == 11'h7ff)? ACC_LOD_int[11:1]:(ACC_LOD_int[11:1] + ACC_LOD_int[0]); //rounding
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ACC_LOD_out <= 0;
    end
    else begin
        ACC_LOD_out <= ACC_LOD_int_round;
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ACC_LOD_shift_reg0 <= 'd0;
    end
    else begin
        if (ACC_done_0[0]) begin
            ACC_LOD_shift_reg0 <= ACC_LOD_shift;
        end
        else if (softmax_invalid || SiLU_invalid) begin
            ACC_LOD_shift_reg0 <= 'd0;
        end
        else if (fsqrt_out_valid && !fsqrt_done && (op_type_reg == 'd0)) begin
            ACC_LOD_shift_reg0 <= fsqrt_out_shift + ACC_LOD_shift_reg0;
        end
        else if (fsqrt_out_valid && (op_type_reg == 'd1 || op_type_reg == 'd2)) begin
            ACC_LOD_shift_reg0 <= fsqrt_out_shift;
        end
        else begin
            ACC_LOD_shift_reg0 <= ACC_LOD_shift_reg0;
        end
    end
end


always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        ACC_LOD_shift_reg1 <= 'd0;
    end
    else begin
        if (ACC_done_1[0]) begin
            ACC_LOD_shift_reg1 <= ACC_LOD_shift;
        end
        else if (softmax_invalid) begin
            ACC_LOD_shift_reg1 <= 'd0;
        end
        else if (fsqrt_out_valid && fsqrt_done) begin
            ACC_LOD_shift_reg1 <= fsqrt_out_shift + ACC_LOD_shift_reg1;
        end
        else begin
            ACC_LOD_shift_reg1 <= ACC_LOD_shift_reg1;
        end
    end
end

// fsqrt

always_comb begin
    if (RMS_invalid) begin
        fsqrt_op_type = 1'b1;
    end
    else begin
        fsqrt_op_type = 1'b0;
    end
end

always_comb begin
    if ((ACC_done_0[1] || ACC_done_1[1])&&op_type_reg=='d0) begin
        fsqrt_in_valid = 1'b1;
    end
    else if (SiLU_invalid_delay[5] || RMS_invalid) begin
        fsqrt_in_valid = 1'b1;
    end
    else begin
        fsqrt_in_valid = 1'b0;
    end
end

always_comb begin
    if (ACC_done_0[1] || ACC_done_1[1]) begin
        fsqrt_in_data = {21'd0,ACC_LOD_out};
    end
    else if (SiLU_invalid_delay[5]) begin
        fsqrt_in_data = {14'd0,shifter_out_reg};
    end
    else if (RMS_invalid) begin
        fsqrt_in_data = RMS_data;
    end
    else begin
        fsqrt_in_data = 1'b0;
    end
end

fsqrt_with2mode FSQRT(
    .clk(clk),
    .rst_n(rst_n),
    .op_type(fsqrt_op_type),
    .in_valid(fsqrt_in_valid),
    .in_data(fsqrt_in_data),
    .out_valid(fsqrt_out_valid),
    .out_int(fsqrt_out_int),
    .out_shift(fsqrt_out_shift)
);

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        fsqrt_reg0 <= 'd0;
    end
    else begin
        if (fsqrt_out_valid && !fsqrt_done && op_type_reg == 'd0) begin
            fsqrt_reg0 <= fsqrt_out_int;
        end
        else if (fsqrt_out_valid && (op_type_reg == 'd1 || op_type_reg == 'd2)) begin
            fsqrt_reg0 <= fsqrt_out_int;
        end
        else if (softmax_invalid || SiLU_out_valid || SiLU_invalid) begin
            fsqrt_reg0 <= 'd0;
        end
        else begin
            fsqrt_reg0 <= fsqrt_reg0;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        fsqrt_reg1 <= 'd0;
    end
    else begin
        if (fsqrt_out_valid && fsqrt_done && op_type_reg == 'd0) begin
            fsqrt_reg1 <= fsqrt_out_int;
        end
        else if (softmax_invalid) begin
            fsqrt_reg1 <= 'd0;
        end
        else begin
            fsqrt_reg1 <= fsqrt_reg1;
        end
    end
end

// softmac output
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        softmax_out_valid = 1'b0;
        softmax_out_int   =  'd0;
    end
    else begin
        if (SRAM_read_flag_delay[3]) begin
            softmax_out_valid = 1'b1;
            softmax_out_int   = (shifter_out_reg[8:0] == 9'h1ff)? shifter_out_reg[8:1] : shifter_out_reg[8:1] + shifter_out_reg[0];  //rounding
        end
        else begin
            softmax_out_valid = 1'b0;
            softmax_out_int   =  'd0;
        end
    end
end


// SiLU & GeLU output
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        SiLU_out_valid <= 'd0;
        SiLU_out_int   <= 'd0;
    end
    else begin
        if (SiLU_out_delay[4]) begin
            SiLU_out_valid <= 1'b1;
            SiLU_out_int   <= (negative_flag)? ~shifter_out_reg[15:0] + 1:shifter_out_reg[15:0]; //rounding
        end
        else begin
            SiLU_out_valid <= 1'b0;
            SiLU_out_int   <=  'd0;
        end
    end
end

// RMS output
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        RMS_out_valid <= 1'b0;
        RMS_out_int   <=  'd0;
        RMS_out_shift <=  'd0;
    end
    else begin
        if (op_type_reg == 'd3 && fsqrt_out_valid) begin
            RMS_out_valid <= 1'b1;
            RMS_out_int   <= fsqrt_out_int;
            RMS_out_shift <= fsqrt_out_shift;
        end
        else begin
            RMS_out_valid <= 1'b0;
            RMS_out_int   <=  'd0;
            RMS_out_shift <=  'd0;
        end
    end
end

endmodule