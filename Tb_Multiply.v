module tb_Multiply;
    parameter integer K = 4;
    reg [63:0] data_in;
    wire [((64/K)*8)-1:0] Encoded_MEM_flat;

    // Kh?i t?o module matrixMultiply
    matrixMultiply #(
        .K(K)
    ) uut (
        .data_in(data_in),
        .Encoded_MEM_flat(Encoded_MEM_flat)
    );

    // Bi?n ?? truy c?p t?ng ph?n t? m� h�a
    integer idx;
    reg [7:0] encoded_chunk;

    initial begin
        // G�n gi� tr? cho data_in
        data_in = 64'h0123456789ABCDEF;
        #10; // Ch? 10 ??n v? th?i gian

        // V� d? truy c?p c�c ph?n t? m� h�a
        for (idx = 0; idx < (64/K); idx = idx + 1) begin
            encoded_chunk = Encoded_MEM_flat[(idx*8) +: 8];
            $display("Encoded_MEM_flat[%0d] = %h", idx, encoded_chunk);
        end

        $finish;
    end
endmodule