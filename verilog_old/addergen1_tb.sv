// test bench for addergen
module addergen1_tb();
parameter SIZE = 16;

bit [SIZE-1:0] a, b;
bit            ci, 
               clk;
wire[SIZE-1:0] sum;
wire           co;

addergen1_top #(.SIZE(SIZE)) at1(
  .a   (a  ),
  .b   (b  ),
  .ci  (ci ),
  .clk (clk),
  .sum      , // .sum(sum) same-name shorthand notation
  .co      );

// clock generator
always begin
  #5ns clk = 1;
  #3ns $display(a,,b,,ci,,co,,sum);
  #2ns clk = 0;
 
end

initial begin
  for(int i=0; i<16; i++) begin
    #10ns  a = 1'b1<<i;
	b = '1;    
	ci = i[3];
  end
  #10ns $stop;
end

endmodule