`timescale 1 ns / 1 ps
module mem(input         byte_repeat_M, halfword_repeat_M, sign_extend_en_M, 
                   input  [31:0] write_data_M, mem_out_M, alu_out_M, 
                   output [31:0] mem_in_M, data_out_M, 
                   output [3:0]  byte_en_M);

  wire [3:0]  byte_en, halfword_en;
  wire [7:0]  rbyte_repeat_M;
  wire [15:0] rhalfword_repeat_M;
  wire [31:0] byte_extended, halfword_extended; 
  wire [1:0] alu_out;

  
  assign  alu_out = alu_out_M[1:0];

 
  mux3 #(32) wdatamux(write_data_M, {2{write_data_M[15:0]}}, {4{write_data_M[7:0]}},
                      {byte_repeat_M, halfword_repeat_M}, mem_in_M);

 
  dec2 bytebyteendec(alu_out[1:0], byte_en);
  
  mux2 #(4) halfwbyteendec(4'b0011, 4'b1100, alu_out[1], halfword_en);
  mux3 #(4) byte_en_Mux(4'b1111, halfword_en, byte_en, 
                      {byte_repeat_M, halfword_repeat_M}, byte_en_M);

  mux4 #(8) rbyte_repeat_Mux(mem_out_M[7:0], mem_out_M[15:8], mem_out_M[23:16], 
                        mem_out_M[31:24], alu_out[1:0], rbyte_repeat_M);
  
  mux2 #(16) rhalfword_repeat_Mux(mem_out_M[15:0], mem_out_M[31:16], alu_out[1],
                          rhalfword_repeat_M);

  
  signext #(8, 32) rbytesignext(rbyte_repeat_M, sign_extend_en_M, byte_extended);
  signext #(16, 32) rhalfwsignext(rhalfword_repeat_M, sign_extend_en_M, halfword_extended);

  mux3 #(32) readmux(mem_out_M, halfword_extended, byte_extended, {byte_repeat_M, halfword_repeat_M},
                     data_out_M);
endmodule

