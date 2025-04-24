module top_withMOD(
    input wire clk,
    input wire clk_carrier,
    input wire reset,
    input wire start,
    input wire [63:0] data_in,      
    output wire done,
    output wire in_data,
    output signed [8:0] mod_out
);

wire [127:0] encode_output;
    top top_inst (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .done(done),
        .final_output(encode_output)
    );

    mod_16QAM uut(
        .signal_clk(clk),
        .carrier_clk(clk_carrier),
        .reset_n(done),
        .mod_out(mod_out),
        .serial_data(in_data),
        .d_in(encode_output)
        );

endmodule