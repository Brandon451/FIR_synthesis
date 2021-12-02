// input and output register wrapper for
//  ripple carry adder
module addergen1_top #(parameter SIZE = 8)
(
  input       [SIZE-1:0] a, b,
  input                  ci,
                         clk,
  output logic           co,
  output logic[SIZE-1:0] sum
);

logic           ciq, cod;
logic[SIZE-1:0] aq, bq;
logic[SIZE-1:0] sumd;

addergen1 #(.SIZE(SIZE)) a1(
  .a  (aq  ),
  .b  (bq  ),
  .ci (ciq ),
  .sum(sumd),
  .co (cod ));

always @(posedge clk) begin
// register inputs
  aq  <= a;
  bq  <= b;
  ciq <= ci;
// output registers
  sum <= sumd; 
  co  <= cod; 
end

endmodule