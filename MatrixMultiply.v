module matrixMultiply #(
    parameter integer K = 4
)(
    input wire clk,
    input wire reset,
    input wire [63:0] data_in,
    input wire start,
    output reg valid_out,
    output reg [((64/K)*8)-1:0] Encoded_MEM_flat
);
    localparam [7:0] G0 = 8'hE1;
    localparam [7:0] G1 = 8'hD2;
    localparam [7:0] G2 = 8'hB4;
    localparam [7:0] G3 = 8'h78;

    integer chunkIndex;
    integer i;
    reg [K-1:0] chunk;
    reg [7:0] encodedChunk;

    always @(posedge clk or posedge reset) begin
        if (reset == 1'b0) begin
            Encoded_MEM_flat <= 0;
            valid_out <= 0;
        end
        else if (start) begin
            valid_out <= 0;
            for (chunkIndex = 0; chunkIndex < (64 / K); chunkIndex = chunkIndex + 1) begin
                chunk = data_in[63 - (chunkIndex*K) -: K];
                encodedChunk = 0;
                
                for (i = 0; i < K; i = i + 1) begin
                    if (chunk[i]) begin
                        case (i)
                            0: encodedChunk = encodedChunk ^ G0;
                            1: encodedChunk = encodedChunk ^ G1;
                            2: encodedChunk = encodedChunk ^ G2;
                            3: encodedChunk = encodedChunk ^ G3;
                            default: encodedChunk = encodedChunk;
                        endcase
                    end
                end
                
                Encoded_MEM_flat[((64/K) - 1 - chunkIndex)*8 +: 8] <= encodedChunk;
            end
            valid_out <= 1;
        end
        else begin
            valid_out <= 0;
        end
    end
endmodule