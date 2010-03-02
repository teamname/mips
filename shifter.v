`timescale 1 ns / 1 ps
module shifter(input signed [31:0] a, b,
               input        [2:0] control,
               input              lui,
               input        [4:0] constshift,
               output       [31:0] shiftresult);

  wire [31:0] leftlogical, rightlogical, rightassociative;
  wire [4:0] shiftamount;

  assign leftlogical      = b << shiftamount;
  assign rightlogical     = b >> shiftamount;
  assign rightassociative = b >>> shiftamount;

  
 
  mux3 #(5) sh_amount_mux(a[4:0],     
                      constshift, 
                      5'b10000,   
                      {lui, control[2]}, shiftamount);

  mux3 #(32) sh_res_mux(rightlogical, rightassociative, leftlogical, control[1:0],
                      shiftresult);
endmodule


