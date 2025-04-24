module top(
    input wire clk,
    input wire reset,
    input wire start,
    input wire [63:0] data_in,      
    output wire done,
    output wire [127:0] final_output 
);
    wire [127:0] encoded_output;
    wire valid_matrix;
    wire valid_interleave;

    assign done = valid_interleave;
    
    matrixMultiply #(
        .K(4)
    ) matrix_mult (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .start(start),
        .valid_out(valid_matrix),
        .Encoded_MEM_flat(encoded_output)
    );

    interleave interleaver (
        .clk(clk),
        .reset(reset),
        .encoded_mem_flat(encoded_output),
        .valid_in(valid_matrix),
        .valid_out(valid_interleave),
        .interleaved_output(final_output) 
    );

endmodule