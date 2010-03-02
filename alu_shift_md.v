`timescale 1 ns / 1 ps
// ALU, Shifter, and multiply/divide
module alu_shift_md(input      [5:0] funct,
                input            rtype, maindecuseshifter, 
                input      [2:0] alushmaincontrol,
                output           useshifter,
                output     [2:0] alushcontrol,
                output           overflowable, syscallD, breakD, 
                                 mdstart, hilosrc, hiloread, hilosel,
                output     [1:0] hilodisable);

  reg [12:0] functcontrol;

  mux2 #(13) alushconmux({9'b0, maindecuseshifter, alushmaincontrol}, 
                         functcontrol, rtype,
                         {overflowable, syscallD, breakD, hiloread, 
                         hilosel, hilodisable, mdstart, hilosrc, useshifter, 
                         alushcontrol});

  always @ ( * )
      case(funct)
          // ALU Ops
          6'b100000: functcontrol <= 13'b1000000000010; // ADD 
          6'b100001: functcontrol <= 13'b0000000000010; // ADDU
          6'b100010: functcontrol <= 13'b1000000000110; // SUB 
          6'b100011: functcontrol <= 13'b0000000000110; // SUBU
          6'b100100: functcontrol <= 13'b0000000000000; // AND
          6'b100101: functcontrol <= 13'b0000000000001; // OR
          6'b100110: functcontrol <= 13'b0000000000100; // XOR
          6'b100111: functcontrol <= 13'b0000000000101; // NOR
          6'b101010: functcontrol <= 13'b0000000000111; // SLT
          6'b101011: functcontrol <= 13'b0000000000011; // SLTU
                                                 
          // Shift Ops                           
          // The lower 3 bits are: {constant, left, rightassociative}
          6'b000000: functcontrol <= 13'b0000000001110; // SLL
          6'b000010: functcontrol <= 13'b0000000001100; // SRL
          6'b000011: functcontrol <= 13'b0000000001101; // SRA
          6'b000100: functcontrol <= 13'b0000000001010; // SLLV
          6'b000110: functcontrol <= 13'b0000000001000; // SRLV
          6'b000111: functcontrol <= 13'b0000000001001; // SRAV
                                                 
          // Branch Ops (These are all don't cares)
                                                 
          // Mult/div/HI/LO Ops                  
          // The lower 3 bits are {dont care, signedop, muldivb}
                                                 
          6'b010000: functcontrol <= 13'b0001000000000; // MFHI
          6'b010001: functcontrol <= 13'b0000010010000; // MTHI
          6'b010010: functcontrol <= 13'b0001100000000; // MFLO
          6'b010011: functcontrol <= 13'b0000001010000; // MTLO
                                                 
          6'b011000: functcontrol <= 13'b0000000100011; // MULT
          6'b011001: functcontrol <= 13'b0000000100001; // MULTU
          6'b011010: functcontrol <= 13'b0000000100010; // DIV
          6'b011011: functcontrol <= 13'b0000000100000; // DIVU
                                               
          // Exceptions                        
          6'b001100: functcontrol <= 13'b0100000000000; // SYSCALL
          6'b001101: functcontrol <= 13'b0010000000000; // BREAK
                                                 
          default:   functcontrol <= 13'b0000000000xxx; // ???
      endcase
endmodule


