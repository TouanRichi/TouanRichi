`timescale 1ns/1ps
module top_tb();

  reg clk;
  reg reset;
  reg start;
  reg [63:0] data_in;
  wire done;
  wire [127:0] final_output;

  // Instantiate the top module
  top uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .data_in(data_in),
    .done(done),
    .final_output(final_output)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Stimulus
  initial begin
    reset = 0;
    start = 0;
    data_in = 64'h0000000000000000;

    #10;
    reset = 0;   // Release reset
    #10;
    reset = 1;

    // Test Case 1
    data_in = 64'h123456789ABCDEF0;
    start = 1;
    #10;
    start = 0;
    wait(done);
    $display("Output: %h", final_output);

    // Test Case 2
    data_in = 64'hFEDCBA9876543210;
    start = 1;
    #10;
    start = 0;
    wait(done);
    $display("Output: %h", final_output);

    #20;
    $stop;
  end

endmodule