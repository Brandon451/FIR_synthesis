##CLA

module cla #(parameter w=16)(
  input [w-1:0] a,
  input [w-1:0] b,
  output logic [w:0] out
);
 
  logic [w-1:0] p;
  logic [w-1:0] g;
  logic [w:0] c;
  logic [w-1:0] sum;
 
  assign c[0] = 1'b0;
  genvar jj;
 
  generate
    for (jj = 0;jj < w;jj++) begin
      assign p[jj] = a[jj] ^ b[jj];
      assign g[jj] = a[jj] & b[jj];
      assign c[jj+1] = g[jj] | ( p[jj] & c[jj] );
      assign sum[jj] = p[jj] ^ c[jj];
    end
  endgenerate
 
  assign out = {c[w],sum};
 
endmodule

module fir4rca #(parameter w=16)(
  input                      clk,
                             reset,
  input         [w-1:0] a,
  output logic  [w+1:0] s);
// delay pipeline for input a
  logic         [w-1:0] ar, br, cr, dr;

// RIPPLE CARRY ADDER LOGIC

  logic         [w:0] cla1_o,  cla2_o;
  logic         [w:0] rca1_co, rca2_co;

  logic         [w+1:0] sum;

// START OF CLA
  logic [w-1:0] p1,p2;
  logic [w-1:0] g1,g2;
  logic [w:0] p3,g3,sum3;
  logic [w+1:0] c3;
  logic [w:0] c1,c2;
  logic [w-1:0] sum1,sum2;
 
  assign c1[0] = 1'b0;
  assign c2[0] = 1'b0;
  assign c3[0] = 1'b0;
  genvar jj;
 
  generate
    for (jj = 0;jj < w;jj++) begin
      assign p1[jj] = ar[jj] ^ br[jj];
      assign g1[jj] = ar[jj] & br[jj];
      assign c1[jj+1] = g1[jj] | ( p1[jj] & c1[jj] );
      assign sum1[jj] = p1[jj] ^ c1[jj];
    end
  endgenerate
 
  assign cla1_o = {c1[w],sum1};
 
  genvar ii;
 
  generate
    for (ii = 0;ii < w;ii++) begin
      assign p2[ii] = cr[ii] ^ dr[ii];
      assign g2[ii] = cr[ii] & dr[ii];
      assign c2[ii+1] = g2[ii] | ( p2[ii] & c2[ii] );
      assign sum2[ii] = p2[ii] ^ c2[ii];
    end
  endgenerate

  assign cla2_o = {c2[w],sum2};
 
  genvar kk;
 
  generate
    for (kk = 0;kk < w+1;kk++) begin
      assign p3[kk] = cla1_o[kk] ^ cla2_o[kk];
      assign g3[kk] = cla1_o[kk] & cla2_o[kk];
      assign c3[kk+1] = g3[kk] | ( p3[kk] & c3[kk] );
      assign sum3[kk] = p3[kk] ^ c3[kk];
    end
  endgenerate
 
  assign sum = {c3[w+1],sum3};
 
// START OF CLA

// sequential logic -- standardized for everyone
  always_ff @(posedge clk) // or just always -- always_ff tells tools you intend D flip flops
    if(reset) begin // reset forces all registers to 0 for clean start of test
 ar <= 'b0;
 br <= 'b0;
 cr <= 'b0;
 dr <= 'b0;
 s  <= 'b0;
    end
    else begin    // normal operation -- Dffs update on posedge clk
 ar <= a; // the chain will always hold the four most recent incoming data samples
 br <= ar;
 cr <= br;
 dr <= cr;
 s  <= sum;
end

endmodule