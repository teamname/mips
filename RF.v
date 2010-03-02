`timescale 1 ns / 1 ps
module RF(input         clk, 
               input         we, 
               input  [4:0]  ra1, ra2, wa, 
               input  [31:0] data, 
               output [31:0] rd1, rd2);

  reg [31:0] rf[31:0];

  always @(negedge clk)
    if (we) rf[wa] <= data;

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
  
endmodule

