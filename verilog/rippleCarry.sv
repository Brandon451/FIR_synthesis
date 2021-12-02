module rippleCarry #(
    parameter width = 4
)(
    input [width-1:0] in_1,
    input [width-1:0] in_2,
    input carry_in,
    output [width-1:0] sum,
    output carry_out
);

wire [width:0] carry_int;

assign carry_int[0] = carry_in;
assign carry_out = carry_int[width];

genvar i;
for (i=0; i<width; i=i+1) begin: adder_bit
    fullAdder fullAdder_inst(
        .in_1(in_1[i]),
        .in_2(in_2[i]),
        .carry_in(carry_int[i]),
        .sum(sum[i]),
        .carry_out(carry_int[i+1])
    );
end

endmodule
