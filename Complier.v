module Complier (
    input  wire [8:0] in_value,   
    output reg  [8:0] out_value   
);

always @(*) begin
    if (in_value >= 9'h100 && in_value <= 9'h1FF)
        out_value = in_value - 9'h100; 
    else if (in_value >= 9'h000 && in_value <= 9'h0FF)
        out_value = in_value + 9'h100;  
    else
        out_value = in_value; 
end

endmodule
