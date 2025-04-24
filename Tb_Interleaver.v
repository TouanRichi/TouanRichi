module top_module;
    reg [127:0] encoded_mem_flat;
    wire [127:0] interleaved_output;

    // Kh?i t?o module interleave
    interleave uut (
        .encoded_mem_flat(encoded_mem_flat),
        .interleaved_output(interleaved_output)
    );

    initial begin
        // Gán giá tr? cho encoded_mem_flat
        encoded_mem_flat = 128'h0123456789ABCDEF0123456789ABCDEF;
        #10; // Ch? 10 ??n v? th?i gian

        // Hi?n th? k?t qu?
        $display("Interleaved Output: %h", interleaved_output);
        $finish;
    end
endmodule