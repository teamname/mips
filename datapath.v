`timescale 1 ns / 1 ps
module datapath(input         clk, reset,
                input  [31:0] inst_F, read_data_M, 
                input         inst_mem_ack, data_mem_ack, 
                input         mem_or_alu_sel_E, mem_or_alu_sel_M, mem_or_alu_sel_W, 
                input         byte_repeat_M, halfword_repeat_M,
                input         branch_D, jump_reg_D, unsigned_D, sign_extend_M,
                input         alu_src_sel_E, reg_dst_E,
                input         rw_E, rw_M, rw_W, 
                input  [1:0]  alu_out_E, 
                input         luiE,
                input         rd_D, 
                input         hiloaccessD, mdstartE, hilosrcE,
                input  [1:0]  pc_sel_FD, branch_sel_D,
                input  [2:0]  alu_cnt_E,
                output [31:0] pc_F,
                output [31:0] alu_out_M, write_data_M,
                output [3:0]  byte_en_M, 
                output [5:0]  opcode_D, function_D,
                output [4:0]  rs_D, rt_D, rd_E,
                output        a_eq_z_D, a_eq_b_D, a_gt_z_D, a_lt_z_D,
                output        stall_D, stall_E, stall_M, stall_W, 
                output        flush_E, flush_M, of_E,
                output        md_run_E, 
                
                output [31:0] pc_E,
                output [31:0] write_data_W,
                output [4:0]  write_reg_W,
                output        activeexception);

  wire        forwardaD, forwardbD;
  wire [1:0]  forwardaE, forwardbE;
  wire        stallF, flushD;
  
 
  wire [31:0] writedataM;
  wire [31:0] readdata2M;
  wire [31:0] pcnextbrFD, pcplus4D, pcplus4F;
  wire [31:0] signimmD, signimmE;
  wire [31:0] srca2D, srcaE;
  wire [31:0] srcb2D, srcbE, srcb2E;
  wire [31:0] instrD;
  wire [31:0] aluoutE, aluoutW;
  wire [31:0] readdataW, resultW;
  wire [31:0] pcD;
 
  wire        rsonD, rtonD, rsonE, rtonE;
  wire        rseqwrDM, rteqwrDM, rseqwrEM, rseqwrEW;
  wire        rteqwrEM, rteqwrEW, rteqrsED, rteqrtED;
  wire        rseqwrd_E, rteqwrd_E;
  wire [4:0]  rdD;
  
  fivebitdp fivebitdp(
                      clk, reset,
                      stall_E, stall_M, stall_W, flush_E, flush_M,
                      rs_D, rt_D, rdD, rd_D, reg_dst_E,
                     
                      rsonD, rtonD, rsonE, rtonE,
                      rseqwrDM, rteqwrDM, rseqwrEM, rseqwrEW,
                      rteqwrEM, rteqwrEW, rteqrsED, rteqrtED,
                      rseqwrd_E, rteqwrd_E,
                      rd_E, write_reg_W);
  
  
  forward    fwd(
                  rsonD, rtonD, rsonE, rtonE,
                  rseqwrDM, rteqwrDM, rseqwrEM, rseqwrEW,
                  rteqwrEM, rteqwrEW, rteqrsED, rteqrtED,
                  rseqwrd_E, rteqwrd_E, 
                  rw_E, rw_M, rw_W, 
                            
              forwardaD, forwardbD, forwardaE, forwardbE);
              
  hazard_detection    hazard(
              clk, reset,
                  
                  rsonD, rtonD, rsonE, rtonE,
                  rseqwrDM, rteqwrDM, rseqwrEM, rseqwrEW,
                  rteqwrEM, rteqwrEW, rteqrsED, rteqrtED,
                  rseqwrd_E, rteqwrd_E, 
              rw_E, rw_M, rw_W, 
              mem_or_alu_sel_E, mem_or_alu_sel_M, branch_D, jump_reg_D,
              inst_mem_ack, data_mem_ack, hiloaccessD, md_run_E,
              
              forwardaD, forwardbD, forwardaE, forwardbE,
              stallF, stall_D, stall_E, stall_M, stall_W, flushD, flush_E, flush_M,
              activeexception);


  fetch fetch(
                        clk, reset, stallF, pc_sel_FD, pcnextbrFD,
                        
                        pc_F, pcplus4F);

  
  flopenr #(32) r1D(clk,  reset, ~stall_D, pc_F, pcD);
  flopenrc #(32) r2D(clk,  reset, ~stall_D, flushD, inst_F, instrD);

  flopenr #(32) r4D(clk,  reset, ~stall_D, pcplus4F, pcplus4D);

  dec dec(
                          clk,  unsigned_D, 
                          instrD, pcplus4D, resultW, 
                          alu_out_M, rw_W, write_reg_W, forwardaD, forwardbD,
                          branch_sel_D,
                          
                          opcode_D, function_D, rs_D, rt_D, 
                          srca2D, srcb2D, signimmD, pcnextbrFD,
                          a_eq_b_D, a_eq_z_D, a_gt_z_D, a_lt_z_D, rdD);

  
  flopenrc #(32) r1E(clk,  reset, ~stall_E, flush_E, srca2D, srcaE); 
  flopenrc #(32) r2E(clk,  reset, ~stall_E, flush_E, srcb2D, srcbE); 
  flopenrc #(32) r3E(clk,  reset, ~stall_E, flush_E, signimmD, signimmE);
  flopenrc #(32) r9E(clk,  reset, ~stall_E, flush_E, pcD, pc_E);
  
  exe exe(
                            clk, reset, alu_src_sel_E, 
                            luiE, mdstartE, 
                            alu_out_E,
                            forwardaE, forwardbE, 
                            alu_cnt_E, 
                            srcaE, srcbE, resultW, alu_out_M, signimmE, pc_E, 
                        
                            srcb2E, aluoutE, of_E, md_run_E);

  
  flopenrc #(32) r1M(clk,  reset, ~stall_M, flush_M, srcb2E, writedataM);
  flopenrc #(32) r2M(clk,  reset, ~stall_M, flush_M, aluoutE, alu_out_M);
  

  mem mem(
                          byte_repeat_M, halfword_repeat_M, sign_extend_M, 
                          writedataM, read_data_M, alu_out_M, 
                          // outputs
                          write_data_M, readdata2M, byte_en_M);

 
  flopenr #(32) r1W(clk,  reset, ~stall_W, alu_out_M, aluoutW);
  flopenr #(32) r2W(clk,  reset, ~stall_W, readdata2M, readdataW);
  flopenr #(32) r4W(clk,  reset, ~stall_W, writedataM, write_data_W);

  mux2 #(32)  resmux(aluoutW, readdataW, mem_or_alu_sel_W, resultW);

endmodule


module fivebitdp(input         clk, reset,
                 input         stall_E, stall_M, stall_W,
                 input         flush_E, flush_M,
                 input  [4:0]  rs_D, rt_D, rdD,
                 input         rd_D, reg_dst_E,
                 output        rsonD, rtonD, rsonE, rtonE, rseqwrDM, rteqwrDM, 
                               rseqwrEM, rseqwrEW, rteqwrEM, rteqwrEW, 
                               rteqrsED, rteqrtED, rseqwrd_E, rteqwrd_E,
                 output [4:0] rd_E, write_reg_W);
    
  wire [4:0] rsE, rtE, rd2D;
  wire [4:0] writeregM, writeregE;
  
 
  neqzerocmp #(5) ez1(rs_D, rsonD);
  neqzerocmp #(5) ez2(rt_D, rtonD);
  neqzerocmp #(5) ez3(rsE, rsonE);
  neqzerocmp #(5) ez4(rtE, rtonE);
  eqcmp #(5) e1(rs_D, writeregM, rseqwrDM);
  eqcmp #(5) e2(rt_D, writeregM, rteqwrDM);
  eqcmp #(5) e3(rsE, writeregM, rseqwrEM);
  eqcmp #(5) e4(rsE, write_reg_W, rseqwrEW);
  eqcmp #(5) e5(rtE, writeregM, rteqwrEM);
  eqcmp #(5) e6(rtE, write_reg_W, rteqwrEW);
  eqcmp #(5) e7(rtE, rs_D, rteqrsED);
  eqcmp #(5) e8(rtE, rt_D, rteqrtED);
  eqcmp #(5) e9(rs_D, writeregE, rseqwrd_E);
  eqcmp #(5) e0(rt_D, writeregE, rteqwrd_E);
  
  mux2 #(5)   rdmux(rdD, 5'b11111, rd_D, rd2D);
  
  mux2 #(5)   wrmux(rtE, rd_E, reg_dst_E, writeregE);
  
  flopenrc #(5)  r4E(clk, reset, ~stall_E, flush_E, rs_D, rsE);
  flopenrc #(5)  r5E(clk, reset, ~stall_E, flush_E, rt_D, rtE);
  flopenrc #(5)  r6E(clk, reset, ~stall_E, flush_E, rd2D, rd_E);
  
  flopenrc #(5)  r3M(clk, reset, ~stall_M, flush_M, writeregE, writeregM);

  flopenr #(5)  r3W(clk, reset, ~stall_W, writeregM, write_reg_W);
  
endmodule
