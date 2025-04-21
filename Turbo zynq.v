`timescale 1ns / 1ps
// =============================================================
//  RTL FILE SET - Receiver (pure Verilog-2001, Vivado-friendly)
//  Each block delimited with "// >>> filename.v" for easy split.
//  **No array ports** - wide buses are used instead.
// =============================================================

// >>> cordic_pipeline.v -------------------------------------------------------
module cordic_pipeline(
    input  wire         clk,
    input  wire         rst,
    input  wire         valid_in,
    input  wire  signed [15:0] x_in,
    input  wire  signed [15:0] y_in,
    output reg   signed [15:0] magnitude,
    output reg          valid
);
    // ------------------------------------------ LUT (16 entries) -------------
    reg signed [15:0] atan_tbl [0:15];
    initial begin
        atan_tbl[ 0] = 16'sd6434;  atan_tbl[ 1] = 16'sd3798;
        atan_tbl[ 2] = 16'sd2007;  atan_tbl[ 3] = 16'sd1019;
        atan_tbl[ 4] = 16'sd511 ;  atan_tbl[ 5] = 16'sd256 ;
        atan_tbl[ 6] = 16'sd128 ;  atan_tbl[ 7] = 16'sd64  ;
        atan_tbl[ 8] = 16'sd32  ;  atan_tbl[ 9] = 16'sd16  ;
        atan_tbl[10] = 16'sd8   ;  atan_tbl[11] = 16'sd4   ;
        atan_tbl[12] = 16'sd2   ;  atan_tbl[13] = 16'sd1   ;
        atan_tbl[14] = 16'sd1   ;  atan_tbl[15] = 16'sd0   ;
    end

    // pipeline regs ----------------------------------------------------------
    reg  signed [15:0] x [0:15];
    reg  signed [15:0] y [0:15];
    reg  signed [15:0] z [0:15];
    reg                vpipe [0:15];

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            magnitude <= 0; valid <= 0;
            for(i=0;i<16;i=i+1) vpipe[i] <= 0;
        end else begin
            // stage-0 load
            if (valid_in) begin
                x[0] <= x_in; y[0] <= y_in; z[0] <= 0; vpipe[0] <= 1'b1;
            end else vpipe[0] <= 1'b0;

            // core iterations
            for(i=0;i<15;i=i+1) begin
                if (y[i] >= 0) begin
                    x[i+1] <= x[i] + (y[i] >>> i);
                    y[i+1] <= y[i] - (x[i] >>> i);
                    z[i+1] <= z[i] + atan_tbl[i];
                end else begin
                    x[i+1] <= x[i] - (y[i] >>> i);
                    y[i+1] <= y[i] + (x[i] >>> i);
                    z[i+1] <= z[i] - atan_tbl[i];
                end
                vpipe[i+1] <= vpipe[i];
            end
            magnitude <= x[15] >>> 1;   // gain compensation
            valid     <= vpipe[15];
        end
    end
endmodule

// >>> qam16_demod_soft.v ------------------------------------------------------
module qam16_demod_soft(
    input  wire         clk,
    input  wire         rst,
    input  wire         valid_in,
    input  wire  signed [15:0] i_s,
    input  wire  signed [15:0] q_s,
    output reg  signed [15:0] llr_out,
    output reg          valid_out
);
    wire signed [15:0] mag; wire mag_v;
    cordic_pipeline C (.clk(clk),.rst(rst),.valid_in(valid_in),.x_in(i_s),.y_in(q_s),.magnitude(mag),.valid(mag_v));
    always @(posedge clk) begin
        if (rst) begin valid_out<=0; llr_out<=0; end
        else begin
            valid_out <= mag_v;
            if (mag_v) llr_out <= (i_s[15] ? -mag : mag); // simple soft metric
        end
    end
endmodule

// >>> interleaver_rev.v --------------------------------------------------------
module interleaver_rev #(parameter N=128)(
    input  wire              clk,
    input  wire              rst,
    input  wire              valid_in,
    input  wire  [7:0]       alpha_in,
    input  wire  signed [15:0] data_in,
    output reg  [N*16-1:0]   mem_flat,
    output reg               frame_done
);
    // internal RAM
    reg signed [15:0] mem [0:N-1];
    reg [6:0] wr_cnt;
    integer j;
    always @(posedge clk) begin
        if(rst) begin wr_cnt<=0; frame_done<=0; end
        else if(valid_in) begin
            mem[alpha_in] <= data_in;
            wr_cnt <= wr_cnt + 1;
            frame_done <= (wr_cnt==N-1);
            if (wr_cnt==N-1) begin
                // pack into flat bus for downstream module
                for(j=0;j<N;j=j+1) mem_flat[j*16 +: 16] <= mem[j];
            end
        end else frame_done<=0;
    end
endmodule

// >>> dca_decoder.v ------------------------------------------------------------
module dca_decoder #(parameter N=128, parameter ITER=2)(
    input  wire              clk,
    input  wire              rst,
    input  wire              start,
    input  wire  [N*16-1:0]  ch_llr_flat,
    input  wire  [N-1:0]     H_true,
    output reg  [N-1:0]      bits_out,
    output reg               done,
    output reg  [15:0]       ber
);
    // unpack
    reg signed [15:0] La [0:N-1];
    integer i;
    always @(*) begin
        for(i=0;i<N;i=i+1) La[i] = ch_llr_flat[i*16 +: 16];
    end

    reg [3:0] it;
    function signed [15:0] sat(input signed [31:0] v);
        begin
            if(v>32767) sat=32767; else if(v<-32768) sat=-32768; else sat=v[15:0];
        end
    endfunction

    always @(posedge clk) begin
        if(rst) begin done<=0; ber<=0; it<=0; end
        else if(start) begin done<=0; ber<=0; it<=0; end
        else if(it<ITER) begin
            it<=it+1;
            if(it==ITER-1) begin
                ber<=0;
                for(i=0;i<N;i=i+1) begin
                    bits_out[i] <= (La[i]>0);
                    if(((La[i]>0)?1'b1:1'b0) != H_true[i]) ber <= ber + 1;
                end
                done<=1;
            end
        end
    end
endmodule

// >>> receiver_top.v -----------------------------------------------------------
module receiver_top(
    input  wire         clk,
    input  wire         rst,
    input  wire  [3:0]  i_in,
    input  wire  [3:0]  q_in,
    input  wire  [7:0]  alpha_sym,
    input  wire         sym_valid,
    input  wire  [127:0] H_ref,
    output wire [127:0] bits_out,
    output wire [15:0]  ber,
    output wire         frame_done
);
    wire signed [15:0] llr_dem; wire v_dem;
    qam16_demod_soft DEM(.clk(clk),.rst(rst),.valid_in(sym_valid),
                         .i_s({{12{i_in[3]}},i_in}),
                         .q_s({{12{q_in[3]}},q_in}),
                         .llr_out(llr_dem),.valid_out(v_dem));

    wire [2047:0] llr_flat; // 128*16
    wire int_done;
    interleaver_rev DEINT(.clk(clk),.rst(rst),.valid_in(v_dem),.alpha_in(alpha_sym),
                          .data_in(llr_dem),.mem_flat(llr_flat),.frame_done(int_done));

    dca_decoder DEC(.clk(clk),.rst(rst),.start(int_done),.ch_llr_flat(llr_flat),
                    .H_true(H_ref),.bits_out(bits_out),.done(frame_done),.ber(ber));
endmodule

// >>> tb_receiver_top.v --------------------------------------------------------
module tb_receiver_top;
    reg clk=0,rst=1; always #5 clk=~clk; // 100 MHz
    reg [3:0] i_s,q_s; reg [7:0] alpha; reg v_sym;
    wire [127:0] bits; wire [15:0] ber; wire done;
    receiver_top DUT(.clk(clk),.rst(rst),.i_in(i_s),.q_in(q_s),.alpha_sym(alpha),
                     .sym_valid(v_sym),
                     .H_ref(128'hA5A5F0F0123456789ABCDEF013572468),
                     .bits_out(bits),.ber(ber),.frame_done(done));
    integer k;
    initial begin
        repeat(4) @(posedge clk); rst=0; v_sym=0;
        for(k=0;k<128;k=k+1) begin @(posedge clk);
            i_s <= (k%4)+4; q_s <= (k%3)+6; alpha <= k[7:0]; v_sym <= 1; end
        @(posedge clk) v_sym<=0;
        wait(done); $display("BER=%0d", ber); $finish;
    end
endmodule

// ============================================================================
//  Split-tip:  awk '/^\/\/ >>> /{close(f);f=$3} {print > f}' Full_Receiver_Zynq7010.v
// ============================================================================
