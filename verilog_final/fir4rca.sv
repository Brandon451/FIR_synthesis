//`define baseline
//`define rca_tree
//`define rca_transpose
//`define cla_tree
`define cla_transpose

module fir4rca #(
    parameter w = 16
)(
    input clk,
    input reset,
    input [w-1:0] a,
    output logic [w+1:0] s
);

`ifdef baseline

    //Pipeline for inputs
    logic [w-1:0] ar;
    logic [w-1:0] br;
    logic [w-1:0] cr;
    logic [w-1:0] dr;

    //Intermediate sums
    logic [w-1:0]   rca1_s;
    logic [w:0]     rca2_s;
    logic [w+1:0]   rca3_s;
    logic [w:0]     rc1;
    logic [w+1:0]   rc2;

    //Padded inputs
    logic [w:0]     cr2;
    logic [w+1:0]   dr3;

    //Intermediate carry
    logic [w:0]     rca1_co;    //Carry in
    logic [w+1:0]   rca2_co;
    logic [w+2:0]   rca3_co;

    //Final sum
    logic [w+1:0]   sum;

    //First adder to add 2 inputs
    always_comb begin
        rca1_co[0] = 0;
        for (int i=0; i<w; i++)
            {rca1_co[i+1], rca1_s[i]} = ar[i] + br[i] + rca1_co[i];
        rc1 = {rca1_co[w], rca1_s};
    end

    //Second adder to add output of first adder and 3rd input
    always_comb begin
        rca2_co[0] = 0;
	    cr2 = {1'b0,cr};
        for(int i=0; i<w+1; i++)
            {rca2_co[i+1],rca2_s[i]} = rc1[i] + cr2[i] + rca2_co[i];
	    rc2 = {rca2_co[w+1],rca2_s};
    end

    //Third adder to add output of second adder and 4th input
    always_comb begin    
        rca3_co[0] = 0;
	    dr3 = {2'b0,dr};
        for(int i=0; i<w+2; i++)
            {rca3_co[i+1],rca3_s[i]} = rc2[i] + dr3[i] + rca3_co[i];
    end

    always_comb
    sum = rca3_s;

    //Shift register to accept inputs
    always_ff @(posedge clk)			// or just always -- always_ff tells tools you intend D flip flops
        if(reset) begin					// reset forces all registers to 0 for clean start of test
            ar <= 'b0;
            br <= 'b0;
            cr <= 'b0;
            dr <= 'b0;
            s  <= 'b0;
        end
        else begin					    // normal operation -- Dffs update on posedge clk
            ar <= a;						// the chain will always hold the four most recent incoming data samples
            br <= ar;
            cr <= br;
            dr <= cr;
            s  <= sum; 
        end

`elsif rca_tree

    //Pipeline for inputs
    logic [w-1:0] ar;
    logic [w-1:0] br;
    logic [w-1:0] cr;
    logic [w-1:0] dr;

    //Intermediate sums
    logic [w-1:0]   rca1_s;
    logic [w-1:0]   rca2_s;

    //Intermediate carry
    logic [w:0]     rca1_co;
    logic [w:0]     rca2_co;
    
    //Final sum
    logic [w+1:0]   sum;

    //First adder to add first 2 inputs
    always_comb begin
        rca1_co[0] = 0;
        for (int i=0; i<w; i++)
            {rca1_co[i+1], rca1_s[i]} = ar[i] + br[i] + rca1_co[i];
    end

    //Second adder to add last 2 inputs
    always_comb begin
        rca2_co[0] = 0;
        for (int i=0; i<w; i++)
            {rca2_co[i+1], rca2_s[i]} = cr[i] + dr[i] + rca2_co[i]; 
    end

    //Final adder to add outputs of first 2 adders
    always_comb begin
        sum = {rca1_co[w], rca1_s} + {rca2_co[w], rca2_s};
    end

    //Shift register to accept inputs
    always_ff @(posedge clk)			// or just always -- always_ff tells tools you intend D flip flops
        if(reset) begin					// reset forces all registers to 0 for clean start of test
            ar <= 'b0;
            br <= 'b0;
            cr <= 'b0;
            dr <= 'b0;
            s  <= 'b0;
        end
        else begin					    // normal operation -- Dffs update on posedge clk
            ar <= a;						// the chain will always hold the four most recent incoming data samples
            br <= ar;
            cr <= br;
            dr <= cr;
            s  <= sum; 
        end

`elsif rca_transpose

    //First input flop
    logic [w-1:0] ar;

    //Pipeline for sums
    logic [w:0]     sum1;
    logic [w:0]     sum1r;
    logic [w+1:0]   sum2;
    logic [w+1:0]   sum2r;
    logic [w+1:0]   sum3;

    //Intermediate sums
    logic [w-1:0]   rca1_s;
    logic [w:0]     rca2_s;
    logic [w+1:0]   rca3_s;

    //Padded inputs
    logic [w:0]     cr2;
    logic [w+1:0]   dr3;

    //Intermediate carry
    logic [w:0]     rca1_co;    //Carry in
    logic [w+1:0]   rca2_co;
    logic [w+2:0]   rca3_co;

    //Final sum
    logic [w+1:0]   sum;

    //First adder to add 
    always_comb begin
        rca1_co[0] = 0;
        for (int i=0; i<w; i++)
            {rca1_co[i+1], rca1_s[i]} = ar[i] + a[i] + rca1_co[i];
        sum1 = {rca1_co[w], rca1_s};
    end

    always_comb begin
        rca2_co[0] = 0;
        cr2 = {1'b0,a};
        for(int i=0; i<w+1; i++)
            {rca2_co[i+1],rca2_s[i]} = sum1r[i] + cr2[i] + rca2_co[i];
        sum2 = {rca2_co[w+1],rca2_s};
    end

    always_comb begin    
        rca3_co[0] = 0;
        dr3 = {2'b0,a};
        for(int i=0; i<w+2; i++)
            {rca3_co[i+1],rca3_s[i]} = sum2r[i] + dr3[i] + rca3_co[i];
    end

    always_comb
        sum = rca3_s;

    //Shift register to store outputs
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


`elsif cla_tree

    // delay pipeline for input a
    logic [w-1:0] ar;
    logic [w-1:0] br;
    logic [w-1:0] cr;
    logic [w-1:0] dr;

    // RIPPLE CARRY ADDER LOGIC
    logic [w:0] cla1_o;
    logic [w:0] cla2_o;
    
    //Output sum
    logic [w+1:0] sum;

    // PG logic
    logic [w-1:0]   p1;
    logic [w-1:0]   p2;
    logic [w-1:0]   g1;
    logic [w-1:0]   g2;
    logic [w:0]     p3;
    logic [w:0]     g3;

    //Intermediate sums
    logic [w-1:0]   sum1;
    logic [w-1:0]   sum2;
    logic [w:0]     sum3;

    //Intermediate carry
    logic [w:0]     c1;
    logic [w:0]     c2;
    logic [w+1:0]   c3;
    
    //Fist adder to add 1st and 2nd input
    always_comb begin
        c1[0] = 1'b0;
        for (int i=0; i<w; i++) begin
            p1[i] = ar[i] ^ br[i];
            g1[i] = ar[i] & br[i];
            c1[i+1] = g1[i] | ( p1[i] & c1[i] );
            sum1[i] = p1[i] ^ c1[i];
        end
        cla1_o = {c1[w],sum1};
    end
  
    //Second adder to add 3rd and 4th inputs
    always_comb begin
        c2[0] = 1'b0;
        for (int i=0; i<w; i++) begin
            p2[i] = cr[i] ^ dr[i];
            g2[i] = cr[i] & dr[i];
            c2[i+1] = g2[i] | ( p2[i] & c2[i] );
            sum2[i] = p2[i] ^ c2[i];
        end
        cla2_o = {c2[w],sum2};
    end
    
    //Third adder to add 1st and 2nd adder's outputs
    always_comb begin
        c3[0] = 1'b0;
        for (int i=0; i<w+1; i++) begin
            p3[i] = cla1_o[i] ^ cla2_o[i];
            g3[i] = cla1_o[i] & cla2_o[i];
            c3[i+1] = g3[i] | ( p3[i] & c3[i] );
            sum3[i] = p3[i] ^ c3[i];
        end
        sum = {c3[w+1],sum3};
    end

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

`elsif cla_transpose

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

`endif

endmodule