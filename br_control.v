`timescale 1 ns / 1 ps
module br_control(input             reset, jump, branch,
                                          link, aeqz, aeqb, agtz, altz,
                        input             lt, gt, eq, src,
                        output            rdsrc, 
                        output      [1:0] pcsrc,
                        output      [1:0] pcbranchsrc,
                        output            jumpreg);

  
  wire abcompare = (eq & aeqb) | (~eq & ~aeqb);
  wire azcompare = (~eq & ~lt & ~gt) | (eq & aeqz) | (gt & agtz) | (lt & altz);

  
  assign  rdsrc = ((jump & ~src) | branch) & link;
  assign  jumpreg = jump & src;

  // pcsrc values
  // 2'b00 reset vector
  // 2'b01 interrupt vector
  // 2'b10 PC+4
  // 2'b11 branch
  assign pcsrc = {~reset, 
                        ~reset & (jump 
                        | (branch & ((src & abcompare) | (~src & azcompare))))};

  // pcbranchsrc
  // 2'b00 branch to pc+4 + offset
  // 2'b01 jump to register value
  // 2'b10 jump to immediate
  assign  pcbranchsrc = {jump & src, jump & ~src};

endmodule
           
