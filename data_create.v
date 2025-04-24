module data_create(clk,reset_n,out,d_in);
input clk,reset_n;
input wire [127:0] d_in;
output wire out;

reg [6:0] address = 7'b0000000;

assign out = d_in[address];

always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		address<=7'b0000000;
	end else begin
		address<=address+1'b1;
	end
end

endmodule 