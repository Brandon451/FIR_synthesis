// Verilog code for 1-bit full adder
module fullAdder(
    input in_1, 
    input in_2, 
    input carry_in, 
    output sum, 
    output carry_out
);

assign sum = in_1 ^ in_2 ^ carry_in;
assign carry_out = (in_1 & in_2) | (in_2 & carry_in) | (carry_in & in_1);

endmodule