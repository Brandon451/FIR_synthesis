`timescale 1ns/1ps

module fir4TapTestBench;

parameter width = 16;
parameter tapSize = 4;

reg [width-1:0] in;
reg clk;
reg reset;
reg in_valid;
wire out_valid;
wire [$clog2(tapSize)+width-1:0] out;

//Verification
wire [$clog2(tapSize)+width-1:0] sum_ref;
logic [width-1:0] in_temp [tapSize-1:0];
integer i;

firTap #(
    .tapSize(tapSize),
    .width(width)
) firTap_inst (
    .clk(clk),
    .reset(reset),
    .in_valid(in_valid),
    .in(in),
    .out_valid(out_valid),
    .out(out)
);

initial begin
    in_valid = 0;
    #1 reset = 0;
    #1 reset = 1;
    #1 reset = 0;
    #1 in = $urandom; in_valid = 1;
    repeat(20) #1 in = $urandom;
    #1 in = 16'hFFFF;
    #1 in = 16'hFFFF;
    #1 in = 16'hFFFF;
    #1 in = 16'hFFFF;
    #1 in = 16'hFFFF;
    #1 in = 16'hFFFF;
    #1 in = 16'hFFFF;
    #1 in = 16'hFFFF;
end

always @ (posedge clk) begin
    in_temp[0] <= in;
    for(i=0; i<tapSize; i=i+1) begin
        in_temp[i+1] <= in_temp[i];
    end
end

assign sum_ref = in_temp[0] + in_temp[1] + in_temp[2] + in_temp[3];



initial begin
    clk = 0;
    reset = 0;
    repeat(60) begin
        #0.5 clk = ~clk;
        if (out_valid) begin
            if (sum_ref == out) 
                $display("Output matches reference");
            else begin
                $display("Incorrect output");
                $display("sum_ref: %d", sum_ref);
                $display("out    : %d", out);
            end
        end
    end
end

integer idx;
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, fir4TapTestBench);
    for(idx = 0; idx < tapSize; idx = idx+1) begin: in_delay
		$dumpvars(0, in_temp[idx]);
        $dumpvars(0, firTap_inst.in_temp[idx]);
	end
end

endmodule