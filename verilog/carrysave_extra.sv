module carrysave #(
    parameter width = 4
)(
    input [width-1:0] in_1,
    input [width-1:0] in_2,
    input [width-1:0] carry_in,
    output [width:0] sum,
    output carry_out
);

wire [width:0] carry_int;
wire [width+1:0] sum_int;
wire [width:0] carry_int2;

assign carry_int2 [0] = carry_in;
assign carry_int [0] = carry_in;
assign carry_out = carry_int2 [width];

genvar i;
for (i=0; i<width; i=i+1) begin: adder_bit
    fullAdder fullAdder_inst(
        .in_1(in_1[i]),
        .in_2(in_2[i]),
        .carry_in(carry_in[i]),
        .sum(sum_int[i]),
        .carry_out(carry_int[i+1])

    );
end 

assign sum[0] = sum_int[0];
assign sum_int [width+1] = 1'b0;

for (i=0; i<width; i=i+1) begin: adder_bit_2
    fullAdder fullAdder_inst2(
        .in_1(carry_int[i+1]),
        .in_2(sum_int[i+1]),
        .carry_in(carry_int2[i]),
        .sum(sum[i+1]),
        .carry_out(carry_int2[i+1])

    );
end
endmodule