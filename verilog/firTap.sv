//`define rippleCarry_transpose
//`define carrySave_transpose
`define baseline    //Canonical ripple carry adder

// adder_arch 1 - ripple carry adder
//              2 - carry save adder

module firTap #(
    parameter tapSize = 4,
    parameter width = 4
)(
    input clk,
    input reset,
    input in_valid,
    input [width-1:0] in,
    output out_valid,
    output [$clog2(tapSize)+width-1:0] out
);

// logic [width-1:0] in_temp [tapSize-1:0];
// logic [tapSize-1:0] valid_temp;

// assign out_valid = valid_temp[tapSize-1];

// wire [width:0] out_temp_1;
// wire [width:0] out_temp_2;

`ifdef rippleCarry_transpose

    logic [width-1:0] in_temp [tapSize-1:0];
    logic [tapSize-1:0] valid_temp;

    assign out_valid = valid_temp[tapSize-1];

    wire [width:0] out_temp_1;
    wire [width:0] out_temp_2;

`elsif carrySave_transpose

    logic [width-1:0] in_temp [tapSize-1:0];
    logic [tapSize-1:0] valid_temp;

    assign out_valid = valid_temp[tapSize-1];

    wire [width:0] out_temp_1;
    wire [width:0] out_temp_2;

    wire carry_out_temp;

`elsif baseline

    logic [width-1:0] in_temp [tapSize-1:0];
    logic [tapSize-1:0] valid_temp;

    assign out_valid = valid_temp[tapSize-1];

    wire [width:0] out_temp_1;
    wire [width+1:0] out_temp_2;

`endif

integer i;

always @ (posedge clk) begin : input_delay
    if (reset) begin
        for(i=0; i<tapSize; i=i+1) begin
            in_temp[i] = 0;
        end
    end
    else begin
        in_temp[0] <= (in_valid)? in:0;
        valid_temp[0] <= in_valid;
        for(i=0; i<tapSize; i=i+1) begin
            in_temp[i+1] <= in_temp[i];
            valid_temp[i+1] <= valid_temp[i];
        end
    end
end

`ifdef rippleCarry_transpose

    rippleCarry #(
        .width(width)
    )rippleCarry_inst1(
        .in_1(in_temp[0]),
        .in_2(in_temp[1]),
        .carry_in(1'b0),
        .sum(out_temp_1[width-1:0]),
        .carry_out(out_temp_1[width])
    );

    rippleCarry #(
        .width(width)
    )rippleCarry_inst2(
        .in_1(in_temp[2]),
        .in_2(in_temp[3]),
        .carry_in(1'b0),
        .sum(out_temp_2[width-1:0]),
        .carry_out(out_temp_2[width])
    );

    rippleCarry #(
        .width(width+1)
    )rippleCarry_inst3(
        .in_1(out_temp_1),
        .in_2(out_temp_2),
        .carry_in(1'b0),
        .sum(out[width:0]),
        .carry_out(out[width+1])
    );

`elsif carrySave_transpose

    carrySave #(
        .width(width)
    )carrySave_inst1(
        .in_1(in_temp[0]),
        .in_2(in_temp[1]),
        .carry_in(in_temp[2]),
        .sum(out_temp_1),
        .carry_out(carry_out_temp)
    );

    carrySave #(
        .width(width+2)
    )carrySave_inst2(
        .in_1({2'b00, in_temp[3]}),
        .in_2({carry_out_temp, out_temp_1}),
        .carry_in({(width+2){1'b0}}),
        .sum(out),
        .carry_out()
    );

`elsif baseline

    rippleCarry #(
        .width(width)
    )rippleCarry_inst1(
        .in_1(in_temp[0]),
        .in_2(in_temp[1]),
        .carry_in(1'b0),
        .sum(out_temp_1[width-1:0]),
        .carry_out(out_temp_1[width])
    );

    rippleCarry #(
        .width(width+1)
    )rippleCarry_inst2(
        .in_1({1'b0, in_temp[2]}),
        .in_2(out_temp_1),
        .carry_in(1'b0),
        .sum(out_temp_2[width:0]),
        .carry_out(out_temp_2[width+1])
    );

    rippleCarry #(
        .width(width+2)
    )rippleCarry_inst3(
        .in_1(out_temp_2),
        .in_2({2'b00, in_temp[3]}),
        .carry_in(1'b0),
        .sum(out),
        .carry_out()
    );

`endif

endmodule