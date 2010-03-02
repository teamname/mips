`timescale 1 ns / 1 ps
module forward(
              input            rs_D, rt_D, rs_E, rt_E,
              input            rs_wr_DM, rt_wr_DM, rs_wr_EM, rs_wr_EW,
              input            rt_wr_EM, rt_wr_EW, rt_rs_ED, rt_rt_ED,
              input            rs_wr_DE, rt_wr_DE,
              input            regwriteE, regwriteM, regwriteW,
              
              output           forwardaD, forwardbD,
              output     [1:0] forwardaE, forwardbE);

  
  assign forwardaD = (rs_D & rs_wr_DM & regwriteM);
  assign forwardbD = (rt_D & rt_wr_DM & regwriteM);

  
  assign forwardaE[1] = (rs_E) & (rs_wr_EM & regwriteM);
  assign forwardaE[0] = (rs_E) & (rs_wr_EW & regwriteW) & 
                          ~forwardaE[1];
  
  assign forwardbE[1] = (rt_E) & (rt_wr_EM & regwriteM);
  assign forwardbE[0] = (rt_E) & (rt_wr_EW & regwriteW) 
                          & ~forwardbE[1];

endmodule



