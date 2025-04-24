module createGeneratorMatrix (
    input wire clk,
    input wire reset,
    input wire [3:0] m,
    output reg [15:0] G [0:31],  // Gi? s? k <= 32
    output reg [15:0] k,
    output reg [15:0] n
);

    integer i, j;
    reg [15:0] row;
    reg [15:0] rowValue;
    reg [15:0] xorResult;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            n <= 0;
            k <= 0;
            row <= 0;
            for (i = 0; i < 32; i = i + 1) begin
                G[i] <= 0;
            end
        end else begin
            n <= (1 << m) - 1;
            k <= n - m;
            row <= 0;

            for (i = 1; i <= n; i = i + 1) begin
                if (!(i != 0 && (i & (i - 1)) == 0)) begin
                    rowValue <= 0;
                    for (j = 0; j < k; j = j + 1) begin
                        if (row == j) begin
                            rowValue <= rowValue | (1 << j);
                        end
                    end
                    for (j = 0; j < m; j = j + 1) begin
                        if ((i >> (m - j - 1)) & 1) begin
                            rowValue <= rowValue | (1 << (k + j));
                        end
                    end
                    G[row] <= rowValue;
                    row <= row + 1;
                end
            end

            // Thêm c?t parity m? r?ng
            for (i = 0; i < k; i = i + 1) begin
                xorResult <= 0;
                for (j = 0; j < k + m; j = j + 1) begin
                    xorResult <= xorResult ^ ((G[i] >> j) & 1);
                end
                G[i] <= G[i] | (xorResult << (k + m));
            end
        end
    end

endmodule