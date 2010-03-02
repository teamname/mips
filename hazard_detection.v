`timescale 1 ns / 1 ps
module hazard_detection(input            clk, reset,
              input            rs_D, rt_D, rs_E, rt_E,
              input            rs_wr_DM, rt_wr_DM, rs_wr_EM, rs_wr_EW,
              input            rt_wr_EM, rt_wr_EW, rt_rs_ED, rt_rt_ED,
              input            rs_wr_DE, rt_wr_DE,
              input            regwriteE, regwriteM, regwriteW,
              input            memtoregE, memtoregM, 
              input            branchD, jumpregD,
              input            instrackF, dataackM,
              input            hiloaccessD, mdrunE,

              output           stallF, stallD, stallE, stallM, stallW, 
              output           flushD, flushE, flushM, activeexception);

  wire lwstallD, branchstallD, instrmissF, datamissM, multdivDE;

  wire executecleared;


  
  assign  lwstallD = memtoregE & (rt_rs_ED | rt_rt_ED);

  
  assign  datamissM = ~dataackM;

  
  assign  multdivDE = hiloaccessD & mdrunE;

  
  assign  instrmissF = ~instrackF;

  
  assign  branchstallD = (branchD | jumpregD) & 
             (regwriteE & ((rs_wr_DE) | 
                          (rt_wr_DE)) |
              memtoregM & ((rs_wr_DM) | 
                          (rt_wr_DM)));
  
  
  assign  memstallexception = instrmissF | datamissM;

 
  assign  brstallexception = executecleared;

  
  flopr #(1) execclearreg(clk, reset, (flushE | executecleared) & stallD, 
                          executecleared);


  
  assign  activeexception =  ~memstallexception & 
                              ~brstallexception;

  assign  stallD = lwstallD | branchstallD | datamissM | multdivDE
                     | instrmissF; 

  assign  stallF =  stallD;     

  
  assign  stallE = datamissM | memstallexception; 

  
  assign  {stallM, stallW} = {2{datamissM}};

  
  assign  flushD = activeexception;  

  
  assign  flushE =    (~datamissM & stallD & ~memstallexception)
                      | activeexception;
 
  
  assign  flushM = (~stallM & memstallexception) | activeexception;

endmodule

