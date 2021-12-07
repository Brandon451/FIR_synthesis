//Transpose CLA architecture


module fir4rca #(parameter w=16)(
  input                      clk,
                             reset,
  input         [w-1:0] a,
  output logic  [w+1:0] s);
// delay pipeline for input a

//Pipeline for inputs
logic [w-1:0] ar;

//Pipeline for sums
logic [w:0]     sum1;
logic [w:0]     sum1r;
logic [w+1:0]   sum2;
logic [w+1:0]   sum2r;
logic [w+1:0]   sum3;

// RIPPLE CARRY ADDER LOGIC

  logic         [w:0] cla1_o,  cla2_o;
  logic         [w:0] rca1_co, rca2_co;

  logic         [w+1:0] sum;

// START OF CLA
logic [w-1:0] p1;
logic [w-1:0] g1;
logic [w:0] c1;
logic [w-1:0] cla1_s;

logic [w:0] p2;
logic [w:0] g2;
logic [w+1:0] c2;
logic [w:0] cr2;
logic [w:0] cla2_s;
   
logic [w+1:0]   dr3;
logic [w+1:0] p3;
logic [w+1:0] g3;
logic [w+2:0] c3;
logic [w+1:0]   cla3_s;
 
always_comb begin
    c1[0] = 1'b0;
    for (int i=0; i<w; i++) begin
        p1[i] = ar[i] ^ a[i];
        g1[i] = ar[i] & a[i];
        c1[i+1] = g1[i] | ( p1[i] & c1[i] );
        cla1_s[i] = p1[i] ^ c1[i];
    end
    sum1 = {c1[w],cla1_s};
end

always_comb begin
    c2[0] = 1'b0;
    cr2 = {1'b0,a};
    for (int i=0; i<w+1; i++) begin
        p2[i] = cr2[i] ^ sum1r[i];
        g2[i] = cr2[i] & sum1r[i];
        c2[i+1] = g2[i] | ( p2[i] & c2[i] );
        cla2_s[i] = p2[i] ^ c2[i];
    end
    sum2 = {c2[w+1],cla2_s};
end

always_comb begin
    c3[0] = 1'b0;
    dr3 = {2'b00,a};
    for (int i=0; i<w+2; i++) begin
        p3[i] = sum2r[i] ^ dr3[i];
        g3[i] = sum2r[i] & dr3[i];
        c3[i+1] = g3[i] | ( p3[i] & c3[i] );
        cla3_s[i] = p3[i] ^ c3[i];
    end
end

always_comb begin
    sum = cla3_s;
end
 
// START OF CLA

// sequential logic -- standardized for everyone
always_ff @(posedge clk)			// or just always -- always_ff tells tools you intend D flip flops
    if(reset) begin					// reset forces all registers to 0 for clean start of test
        ar <= 'b0;
        sum1r <= 'b0;
        sum2r <= 'b0;
        s  <= 'b0;
    end
    else begin					    // normal operation -- Dffs update on posedge clk
        ar <= a;
        sum1r <= sum1;
        sum2r <= sum2;
        s  <= sum; 
    end

endmodule