`timescale 1 ns / 1 ps
module alu(input      [31:0] a, b, 
           input      [2:0]  control, 
           output reg [31:0] alu_res,
           output            of);
           
  wire [31:0] b2, sum, aorb;
  wire sltSigned, sltUnsigned;

  assign  b2 = control[2] ? ~b:b; 
  assign  sum = a + b2 + control[2];
  assign  sltSigned = sum[31];
  
  assign  sltUnsigned = a < b;
  assign  aorb = a | b;

  assign  of = (a[31] == b2[31] & a[31] != sum[31]);

  
  always@( * )
    case(control[2:0])
      3'b000: alu_res <=  a & b;      // and
      3'b001: alu_res <=  aorb;       // or
      3'b010: alu_res <=  sum;        // add
      3'b110: alu_res <=  sum;        // sub
      3'b111: alu_res <=  sltSigned;  // slt signed
      3'b011: alu_res <=  sltUnsigned;// slt unsigned
      3'b100: alu_res <=  a ^ b;      // xor
      3'b101: alu_res <=  ~aorb;      // nor
    endcase
endmodule
