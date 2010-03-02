`timescale 1 ns / 1 ps
module mips(input         clk, reset,
            output [31:0] pc_F,
            input  [31:0] inst_F,

            output        mem_write_M, mem_or_alu_M,
            output [3:0]  byte_repeat_en_M,
            output [31:0] alu_out_M, write_data_M,
            input  [31:0] read_data_M,
            input         inst_mem_ack_F, data_mem_ack_M);

  wire [5:0]  opcode_D, function_D;
  wire [4:0]  rs_D, rt_D, rd_E;
  wire        reg_dst_E, alu_src_E, 
              unsigned_D, sign_extend_en_M, rd_sel_D, link_D, luiE,
              of_en_E, of_E,
              alu_or_mem_E,  alu_or_mem_W, rw_E, rw_M, rw_W,
              byte_repeat_M, halfword_repeat_M,
              a_eq_z_D, a_eq_b_D, a_gt_z_D, a_lt_z_D, md_run_E, branch_D, jump_D,
              bdsE, syscallE, breakE, riE, fpuE,
              adesableE, adelableE;
  wire [2:0]  alu_cnt_E;
  wire [1:0]  branch_src_D, alu_out_E, pc_sle_FD;
  wire        stall_D, stall_E, stall_M, stall_W, flush_E, flush_M;
  wire [31:0] write_data_W;
  wire [31:0] pc_E;
  wire [4:0]  wr_w;
  wire [1:0]  hilodisableE;
  wire        hiloaccessD, md_start_E, hilosrcE;
  // Globals
  wire        activeexception;

  controller cont(
                 clk, reset, 
              
                 opcode_D, function_D, rs_D, rt_D, 
                 stall_D, stall_E, stall_M, stall_W,
                 flush_E, flush_M, 
                 a_eq_z_D, a_eq_b_D, a_gt_z_D, a_lt_z_D, md_run_E,

               
                 alu_or_mem_E, mem_or_alu_M, alu_or_mem_W, mem_write_M, 
                 byte_repeat_M, halfword_repeat_M, branch_D,
                 alu_src_E, unsigned_D, sign_extend_en_M,
                 reg_dst_E, rw_E, rw_M, 
                 rw_W, jumpD, jump_D, of_en_E,
                 alu_out_E, alu_cnt_E, link_D, luiE,
                 rd_sel_D, pc_sle_FD, branch_src_D, 
                 bdsE,
                 syscallE, breakE, riE, fpuE,
                 adesableE, adelableE, halfword_E,
                 specialregsrcE, hilodisableE,
                 hiloaccessD, md_start_E, hilosrcE);

  datapath dp(
                clk, reset, inst_F, 
                
                read_data_M, inst_mem_ack_F, data_mem_ack_M, 
                
                alu_or_mem_E, mem_or_alu_M, alu_or_mem_W, 
                byte_repeat_M, halfword_repeat_M,
                branch_D, jump_D,
                unsigned_D, sign_extend_en_M, alu_src_E, reg_dst_E, rw_E, 
                rw_M, rw_W, alu_out_E, luiE,
                rd_sel_D, 
                specialregsrcE, hilodisableE, hiloaccessD, md_start_E, hilosrcE,
                pc_sle_FD, branch_src_D, alu_cnt_E, 
                pc_F, alu_out_M,
                write_data_M, byte_repeat_en_M, 
                opcode_D, function_D, rs_D, rt_D, rd_E, a_eq_z_D, a_eq_b_D, a_gt_z_D, a_lt_z_D, 
                stall_D, stall_E, stall_M, stall_W, flush_E, flush_M, of_E,
                md_run_E, 
                pc_E, 
                write_data_W, wr_w, 
                activeexception);

endmodule

