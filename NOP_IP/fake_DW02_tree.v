module DW02_tree #(
    parameter num_inputs    = 8,
    parameter input_width   = 25,
    parameter verif_en      = 0
) (
    input               [num_inputs*input_width-1:0]  INPUT   , 
    output reg signed   [input_width-1:0]             OUT0    ,
    output reg signed   [input_width-1:0]             OUT1
);

integer i;

always @(*) begin
    OUT0 = 0;
    OUT1 = 0;
    for (i=0; i<num_inputs/2.0; i=i+1) begin
        OUT0 = OUT0 + $signed(INPUT[i*input_width +: input_width]);
    end

    for (i=$ceil(num_inputs/2.0); i<num_inputs; i=i+1) begin
        OUT1 = OUT1 + $signed(INPUT[i*input_width +: input_width]);
    end
end

endmodule