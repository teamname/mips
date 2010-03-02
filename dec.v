`timescale 1 ns / 1 ps
module dec(input         clk,  unsignedD,
                   input  [31:0] inst_D, PC_plus_4_D, data_in, alu_out_M, 
                   input         rw, 
                   input  [4:0]  write_add,
                   input         forward_a_D, forward_b_D,
                   input  [1:0]  branch_src,
                   output [5:0]  opcode_D, function_D,
                   output [4:0]  rs_D, rt_D, rd_D,
                   output [31:0] src_a_D, src_b_D, sign_imm_D, next_br_D,
                   output        a_eq_b_D, a_eq_z_D, a_gt_z_D, a_lt_z_D);

  wire [31:0] src_a_1, src_b_1, branch_target;
  
  assign opcode_D = inst_D[31:26];
  assign function_D = inst_D[5:0];
  assign rs_D = inst_D[25:21];
  assign rt_D = inst_D[20:16];
  assign rdD = inst_D[15:11];
  
  // register file
  RF     rf(clk,  rw, rs_D, rt_D, write_add,
                 data_in, src_a_1, src_b_1);
  //forward?
  mux2 #(32)  forward_a_Dmux(src_a_1, alu_out_M, forward_a_D, src_a_D);
  mux2 #(32)  forward_b_Dmux(src_b_1, alu_out_M, forward_b_D, src_b_D);
  
  //sign extension
  signext #(16,32) se(inst_D[15:0], ~unsignedD, sign_imm_D);

  // branch address
  adder btadd(PC_plus_4_D, {sign_imm_D[29:0], 2'b00}, branch_target);

  // comparison flags
  eqcmp aeqbcmp(src_a_D, src_b_D, a_eq_b_D);
  eqzerocmp aeqzcmp(src_a_D, a_eq_z_D);
  gtzerocmp agtzcmp(src_a_D, a_gt_z_D);
  ltzerocmp altzcmp(src_a_D, a_lt_z_D);
  
  // next branch address
  mux3 #(32)  branch_mux(branch_target, {PC_plus_4_D[31:28], inst_D[25:0], 2'b00},
                          src_a_D, branch_src, next_br_D);

endmodule
