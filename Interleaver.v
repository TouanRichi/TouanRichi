module interleave(
    input wire clk,
    input wire reset,
    input wire [127:0] encoded_mem_flat,
    input wire valid_in,
    output reg valid_out,
    output reg [127:0] interleaved_output
);

    reg [7:0] Interleaver_Code [0:127];
    integer i;
    reg bit_value;
    integer byte_index;
    integer bit_index;

    initial begin
        Interleaver_Code[0] = 1;
        Interleaver_Code[1] = 2;
        Interleaver_Code[2] = 3;
        Interleaver_Code[3] = 4;
        Interleaver_Code[4] = 5;
        Interleaver_Code[5] = 6;
        Interleaver_Code[6] = 7;
        Interleaver_Code[7] = 8;
        Interleaver_Code[8] = 15;
        Interleaver_Code[9] = 14;
        Interleaver_Code[10] = 13;
        Interleaver_Code[11] = 12;
        Interleaver_Code[12] = 11;
        Interleaver_Code[13] = 10;
        Interleaver_Code[14] = 9;
        Interleaver_Code[15] = 8;
        Interleaver_Code[16] = 16;
        Interleaver_Code[17] = 17;
        Interleaver_Code[18] = 18;
        Interleaver_Code[19] = 19;
        Interleaver_Code[20] = 20;
        Interleaver_Code[21] = 21;
        Interleaver_Code[22] = 22;
        Interleaver_Code[23] = 23;
        Interleaver_Code[24] = 24;
        Interleaver_Code[25] = 25;
        Interleaver_Code[26] = 26;
        Interleaver_Code[27] = 27;
        Interleaver_Code[28] = 28;
        Interleaver_Code[29] = 29;
        Interleaver_Code[30] = 30;
        Interleaver_Code[31] = 31;
        Interleaver_Code[32] = 32;
        Interleaver_Code[33] = 33;
        Interleaver_Code[34] = 34;
        Interleaver_Code[35] = 35;
        Interleaver_Code[36] = 36;
        Interleaver_Code[37] = 37;
        Interleaver_Code[38] = 38;
        Interleaver_Code[39] = 39;
        Interleaver_Code[40] = 40;
        Interleaver_Code[41] = 41;
        Interleaver_Code[42] = 42;
        Interleaver_Code[43] = 43;
        Interleaver_Code[44] = 44;
        Interleaver_Code[45] = 45;
        Interleaver_Code[46] = 46;
        Interleaver_Code[47] = 47;
        Interleaver_Code[48] = 48;
        Interleaver_Code[49] = 49;
        Interleaver_Code[50] = 50;
        Interleaver_Code[51] = 51;
        Interleaver_Code[52] = 52;
        Interleaver_Code[53] = 53;
        Interleaver_Code[54] = 54;
        Interleaver_Code[55] = 55;
        Interleaver_Code[56] = 56;
        Interleaver_Code[57] = 57;
        Interleaver_Code[58] = 58;
        Interleaver_Code[59] = 59;
        Interleaver_Code[60] = 60;
        Interleaver_Code[61] = 61;
        Interleaver_Code[62] = 62;
        Interleaver_Code[63] = 63;
        Interleaver_Code[64] = 64;
        Interleaver_Code[65] = 65;
        Interleaver_Code[66] = 66;
        Interleaver_Code[67] = 67;
        Interleaver_Code[68] = 68;
        Interleaver_Code[69] = 69;
        Interleaver_Code[70] = 70;
        Interleaver_Code[71] = 71;
        Interleaver_Code[72] = 72;
        Interleaver_Code[73] = 73;
        Interleaver_Code[74] = 74;
        Interleaver_Code[75] = 75;
        Interleaver_Code[76] = 76;
        Interleaver_Code[77] = 77;
        Interleaver_Code[78] = 78;
        Interleaver_Code[79] = 79;
        Interleaver_Code[80] = 80;
        Interleaver_Code[81] = 81;
        Interleaver_Code[82] = 82;
        Interleaver_Code[83] = 83;
        Interleaver_Code[84] = 84;
        Interleaver_Code[85] = 85;
        Interleaver_Code[86] = 86;
        Interleaver_Code[87] = 87;
        Interleaver_Code[88] = 88;
        Interleaver_Code[89] = 89;
        Interleaver_Code[90] = 90;
        Interleaver_Code[91] = 91;
        Interleaver_Code[92] = 92;
        Interleaver_Code[93] = 93;
        Interleaver_Code[94] = 94;
        Interleaver_Code[95] = 95;
        Interleaver_Code[96] = 96;
        Interleaver_Code[97] = 97;
        Interleaver_Code[98] = 98;
        Interleaver_Code[99] = 99;
        Interleaver_Code[100] = 100;
        Interleaver_Code[101] = 101;
        Interleaver_Code[102] = 102;
        Interleaver_Code[103] = 103;
        Interleaver_Code[104] = 104;
        Interleaver_Code[105] = 105;
        Interleaver_Code[106] = 106;
        Interleaver_Code[107] = 107;
        Interleaver_Code[108] = 108;
        Interleaver_Code[109] = 109;
        Interleaver_Code[110] = 110;
        Interleaver_Code[111] = 111;
        Interleaver_Code[112] = 112;
        Interleaver_Code[113] = 113;
        Interleaver_Code[114] = 114;
        Interleaver_Code[115] = 115;
        Interleaver_Code[116] = 116;
        Interleaver_Code[117] = 117;
        Interleaver_Code[118] = 118;
        Interleaver_Code[119] = 119;
        Interleaver_Code[120] = 120;
        Interleaver_Code[121] = 121;
        Interleaver_Code[122] = 122;
        Interleaver_Code[123] = 123;
        Interleaver_Code[124] = 124;
        Interleaver_Code[125] = 125;
        Interleaver_Code[126] = 126;
        Interleaver_Code[127] = 127;
    end

    always @(posedge clk or posedge reset) begin
        if (reset == 1'b0) begin
            interleaved_output <= 128'd0;
            valid_out <= 0;
        end
        else if (valid_in) begin
            valid_out <= 0;
            for (i = 0; i < 128; i = i + 1) begin
                byte_index = Interleaver_Code[i] / 8;
                bit_index  = Interleaver_Code[i] % 8;
                bit_value = encoded_mem_flat[byte_index * 8 + bit_index];
                interleaved_output[i] <= bit_value;
            end
            valid_out <= 1;
        end
        else begin
            valid_out <= 0;
        end
    end
endmodule
   
