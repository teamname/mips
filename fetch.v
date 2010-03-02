`timescale 1 ns / 1 ps
module fetch(input             clk,  reset, stallF,
                  input  [1:0]      pcsrcFD,
                  input  [31:0]     pcnextbrFD,

                  output [31:0]     pcF, 

                  output [31:0]     pcplus4F);

  wire [31:0] pcnextF;

  parameter RESET_ADDRESS = 32'hbfc00000;
  parameter INTERRUPT_ADDRESS = 32'hbfc00100;
  
   
  mux4 #(32)  pcmux(RESET_ADDRESS, INTERRUPT_ADDRESS,
                    pcplus4F, pcnextbrFD, pcsrcFD, pcnextF); 

  
  flopen #(32) PC(clk, ~stallF, pcnextF, pcF);
  
  adder       pcadd1(pcF, 32'b100, pcplus4F);

endmodule
