module carrySave #(
    parameter width = 4
)(
    input [width-1:0] in_1,
    input [width-1:0] in_2,
    input [width-1:0] carry_in,
    output [width:0] sum,
    output carry_out
);

wire [width-1:0] carry_int;
wire [width-1:0] sum_int;

assign sum[0] = sum_int[0];

genvar i;
for (i=0; i<width; i=i+1) begin: adder_bit
    fullAdder fullAdder_inst(
        .in_1(in_1[i]),
        .in_2(in_2[i]),
        .carry_in(carry_in[i]),
        .sum(sum_int[i]),
        .carry_out(carry_int[i])
    );
end

rippleCarry #(
    .width(width)
) rippleCarry_inst (
    .in_1(carry_int),
    .in_2({1'b0, sum_int[width-1:1]}),
    .carry_in(1'b0),
    .sum(sum[width:1]),
    .carry_out(carry_out)
);

endmodule