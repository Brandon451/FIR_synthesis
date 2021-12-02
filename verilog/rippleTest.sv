`timescale 1ps/1ps

module rippleTest;

reg clk;

rippleCarry #(
    .width(4)
)(
    .in_1(4'b0,
    .in_2(),
    .carry_in(),
    .sum(),
    .carry_out()
);

repeat #1 clk = ~clk

endmodule