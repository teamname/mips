`timescale 1 ns / 1 ps
module controller(input        clk, reset, 
                  input  [5:0] opD, functD,
                  input  [4:0] rsD, rtD,
                  input        stallD, stallE, stallM, stallW, flushE, flushM,
                  input        aeqzD, aeqbD, agtzD, altzD, mdrunE,
                  output       memtoregE, memtoregM, memtoregW, memwriteM,
                  output       byteM, halfwordM,
                  output       branchD, alusrcE, unsignedD, 
                  output       loadsignedM,
                  output       regdstE, regwriteE, regwriteM, regwriteW,
                  output       jumpD, jumpregD, overflowableE,
                  output [1:0] aluoutsrcE, 
                  output [2:0] alushcontrolE, 
                  output       linkD, luiE,
                  output       rdsrcD, 
                  output [1:0] pcsrcFD, pcbranchsrcD,
                  output       bdsE,
                  output       syscallE, breakE, riE, fpuE,
                  output       adesableE, adelableE, halfwordE,
                  output [1:0] hilodisableE,
                  output       hiloaccessD, mdstartE, hilosrcE);

  wire       memtoregD, memwriteD, alusrcD, mainregwrite, luiD, rtypeD,
             regdstD, regwriteD, maindecuseshifterD, maindecregdstD, 
             alu_shift_mdoverflowableD, maindecoverflowableD, overflowableD,
             useshifterD, 
             loadsignedD, loadsignedE,
             syscallD, breakD, riD, fpuD,
             adesableD, adelableD, 
             mdstartD, hilosrcD,
             hiloreadD, hiloselD;
  wire       byteD, halfwordD, byteE;
  wire [1:0] hilodisablealushD, hilodisablealushE, aluoutsrcD;
  wire       ltD, gtD, eqD, brsrcD;
  wire [2:0] alushcontmaindecD, alushcontrolD;
  wire       memwriteE;
  wire       bdsF, bdsD;

  assign  regwriteD = mainregwrite | linkD ;
  assign  regdstD = maindecregdstD;
  assign  overflowableD = maindecoverflowableD | alu_shift_mdoverflowableD;
  assign  bdsF = branchD | jumpD;
  
  assign  hiloaccessD = mdstartD | hiloreadD;

  maindec md(opD, memtoregD, memwriteD, byteD, halfwordD, loadsignedD,
             alusrcD, maindecregdstD, mainregwrite, unsignedD, luiD,
             maindecuseshifterD, maindecoverflowableD, alushcontmaindecD,
             rtypeD,
             riD, fpuD, adesableD, adelableD);

  
  alu_shift_md  ad(functD, rtypeD, maindecuseshifterD, alushcontmaindecD, 
               useshifterD,
               alushcontrolD, alu_shift_mdoverflowableD, syscallD, breakD,
               mdstartD, hilosrcD, hiloreadD, hiloselD, 
               hilodisablealushD);

  
  mux2 #(2) hilodismux(hilodisablealushE, 2'b00, mdrunE, hilodisableE);
  
  
  branch_dec bd(opD, rtD, functD, jumpD, branchD, ltD, gtD, eqD, brsrcD, linkD);

  
  br_control  bc(reset, jumpD, branchD, linkD, 
                       aeqzD, aeqbD, agtzD, altzD, 
                       ltD, gtD, eqD, brsrcD, rdsrcD, pcsrcFD, pcbranchsrcD,
                       jumpregD);
  

  
  assign  aluoutsrcD = {linkD | hiloreadD,
                          useshifterD | hiloreadD};

    
  flopenr #(1) regD(clk, reset, ~stallD, {bdsF}, {bdsD});
  flopenrc #(31) regE(clk, reset, ~stallE, flushE,
                  {memtoregD, memwriteD, alusrcD, regdstD, regwriteD, 
                  aluoutsrcD, alushcontrolD, loadsignedD, luiD,
                  byteD, halfwordD, overflowableD, bdsD,
                  syscallD, breakD, riD, fpuD,
                  adesableD, adelableD, 
                  mdstartD, hilosrcD, hiloselD, hilodisablealushD}, 
                  {memtoregE, memwriteE, alusrcE, regdstE, regwriteE,  
                  aluoutsrcE, alushcontrolE, loadsignedE, luiE, 
                  byteE, halfwordE, overflowableE, bdsE,
                  syscallE, breakE, riE, fpuE,
                  adesableE, adelableE, 
                  mdstartE, hilosrcE, hiloselE, hilodisablealushE, 
                  specialregsrcE});
  flopenrc #(7) regM(clk, reset, ~stallM, flushM,
                  {memtoregE, memwriteE, regwriteE, loadsignedE,
                  byteE, halfwordE},
                  {memtoregM, memwriteM, regwriteM, loadsignedM,
                  byteM, halfwordM});
  flopenr #(3) regW(clk, reset, ~stallW,
                  {memtoregM, regwriteM},
                  {memtoregW, regwriteW});
endmodule

module maindec(input  [5:0] op,
               output       memtoreg, memwrite, byte, halfword, loadsignedD,
               output       alusrc,
               output       regdst, regwrite, 
               output       unsignedD, lui, useshift, overflowable,
               output [2:0] alushcontrol, 
               output       rtype, riD, fpuD,
               output       adesableD, adelableD);

  reg [19:0] controls;
 
  assign {regwrite, 
          regdst,   
          overflowable, 
          alusrc,
          memwrite,
          memtoreg, byte, halfword, loadsignedD,
          useshift, alushcontrol /* 3 bits */, rtype,
          unsignedD, lui, adesableD, adelableD, fpuD, riD} = controls;

  always @ ( * )
    case(op)
      6'b000000: controls <= 21'b11000000001011000000; //R-type
      6'b000001: controls <= 21'b01000000000100000000; //Opcode 1 (branches)
      6'b100000: controls <= 21'b10010110100100000000; //LB (assume big endian)
      6'b100001: controls <= 21'b10010101100100000100; //LH
      6'b100011: controls <= 21'b10010100100100000100; //LW
      6'b100100: controls <= 21'b10010110000100100000; //LBU
      6'b100101: controls <= 21'b10010101000100100000; //LHU
      6'b101000: controls <= 21'b00011010000100000000; //SB
      6'b101001: controls <= 21'b00011001000100001000; //SH
      6'b101011: controls <= 21'b00011000000100001000; //SW
      6'b001000: controls <= 21'b10110000000100000000; //ADDI
      6'b001001: controls <= 21'b10010000000100000000; //ADDIU
      6'b001010: controls <= 21'b10010000001110000000; //SLTI
      6'b001011: controls <= 21'b10010000000110000000; //SLTIU 
      6'b001100: controls <= 21'b10010000000000100000; //ANDI
      6'b001101: controls <= 21'b10010000000010100000; //ORI
      6'b001110: controls <= 21'b10010000001000100000; //XORI
      6'b001111: controls <= 21'b10010000010100110000; //LUI
      6'b000010: controls <= 21'b00000000000100000000; //J
      6'b000011: controls <= 21'b11000000000100000000; //JAL
      6'b000100: controls <= 21'b00000000001100000000; //BEQ
      6'b000101: controls <= 21'b00000000001100000000; //BNE
      6'b000110: controls <= 21'b00000000001100000000; //BLEZ
      6'b000111: controls <= 21'b00000000001100000000; //BGTZ
      default:   controls <= 21'bxxxxxxxxxxxxxxxxxxx1; //??? (exception)
    endcase
endmodule
