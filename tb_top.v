`timescale 1ns/1ps

module tb_top_withMOD;
reg clk;
reg clk_carrier;
reg reset;
reg start;
reg [63:0] data_in;
wire done;
wire signed [8:0] mod_out;
wire in_data;
top_withMOD uut (
    .clk(clk),
    .clk_carrier(clk_carrier),
    .reset(reset),
    .start(start),
    .data_in(data_in),
    .done(done),
    .mod_out(mod_out),
    .in_data(in_data)
);
always #5000 clk = ~clk; 
always #5 clk_carrier = ~clk_carrier; 
// Test sequence
initial begin
    clk = 0;
    clk_carrier = 0;
    reset = 0;
    start = 0;
    data_in = 64'hABCD123789E3F456; 
    #50;
    reset = 1;
    #20;
    reset = 1;
    #50;
    start = 1;
    #20;
    start = 1;
    wait (done == 1);
    #100;
end
initial begin
    $dumpfile("tb_top_withMOD.vcd");
    $dumpvars(0, tb_top_withMOD);
end

endmodule
