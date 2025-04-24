
module mod_16QAM(signal_clk,carrier_clk,reset_n,mod_out,serial_data, d_in);
input signal_clk,carrier_clk,reset_n;
input wire [127:0] d_in;
output signed [8:0] mod_out;
output wire serial_data; 

wire [3:0] p_data; 

wire signed [7:0] carrier_sin;
wire signed [7:0] carrier_cos;

wire signed [7:0] carrier_i;
wire signed [7:0] carrier_q;
wire [1:0] signal_I; 
wire [1:0] signal_Q; 

wire clk_4div; 
wire [8:0] wave;

assign signal_I = {p_data[3],p_data[1]};
assign signal_Q = {p_data[2],p_data[0]};

assign wave = carrier_i + carrier_q;
freq_div #(.DIV(4)) u_div4(
	.orgin_clk(signal_clk),
	.reset_n(reset_n),
	.out_clk(clk_4div)
);

data_create u_data_create(
	.clk(signal_clk),
	.reset_n(reset_n),
	.d_in(d_in),
	.out(serial_data)
);

mod_s2p u_mod_s2p(
	.clk_s(signal_clk),
	.clk_p(clk_4div),
	.reset_n(reset_n),
	.signal(serial_data),
	.code(p_data)
);

carrier_generator u_carrier(
	.clk(carrier_clk),
	.reset_n(reset_n),
	.sin(carrier_sin),
	.cos(carrier_cos)
);

mod_mul  mod_mul_i(
	.clk(carrier_clk),
	.signal(signal_I),
	.carrier(carrier_cos),
	.out(carrier_i)
);

mod_mul mod_mul_q(
	.clk(carrier_clk),
	.signal(signal_Q),
	.carrier(carrier_sin),
	.out(carrier_q)
);

Complier u_complier(
.in_value(wave),
.out_value(mod_out)
);
endmodule 