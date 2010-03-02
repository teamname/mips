`timescale 1 ns / 1 ps
module exe(input         clk,  reset, alu_src_E, 
                                  luiE, md_start_E,  
                    input  [1:0]  alu_out_sel,
                                  forward_a_E, forward_b_E, 
                    input  [2:0]  alu_cnt_E, 
                    input  [31:0] src_a_E, src_b_E, data_in, alu_out_M, sign_imm_E, pc_E,
                    output [31:0] src_b_out_E, alu_out_E,                    
                    output        of_E,  
                                  md_run_E);

  wire [31:0] src_a, src_b;
  wire [31:0] alu_out, shift_out, pc_plus_8, data_out;

  
  mux3 #(32)  forward_a_Emux(src_a_E, data_in, alu_out_M, forward_a_E, src_a);
  mux3 #(32)  forward_b_Emux(, data_in, alu_out_M, forward_b_E, src_b_out_E);

  
  mux2 #(32)  srcbmux(src_b_out_E, sign_imm_E, alu_src_E, src_b);

  alu         alu(src_a, src_b, alu_cnt_E, alu_out, of_E);
  shifter     shifter(src_a, src_b, alu_cnt_E, luiE, sign_imm_E[10:6],
                      shift_out);

  mdunit md(clk, reset,
            src_a, src_b, alu_cnt_E, md_start_E, data_out, md_run_E);

  adder       pcadd2(pc_E, 32'b1000, pc_plus_8);


  mux4 #(32)  alu_out_Mux(alu_out, shift_out, pc_plus_8, data_out, 
                        alu_out_sel, alu_out_E);


endmodule

