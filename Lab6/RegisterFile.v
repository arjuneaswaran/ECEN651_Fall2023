`timescale 1ns / 1ps
module RegisterFile(
  output reg [31:0] BusA,
  output reg [31:0] BusB,
  input [31:0] BusW,
  input  [4:0] RA,
  input  [4:0] RB,
  input  [4:0] RW,
  input  RegWr,
  input  Clk
);                //defining inputs
  reg [31:0] register [31:0]; // creating a register reg with 32 32 bit elements
  integer i;
  initial begin
  register[0] = 0;
  end                        // in the initial block wiring register[0] to 0
  
  always @(posedge Clk) begin
    if(RegWr == 1 & RW!=0)
      register[RW] <= BusW;
  end                        // at the negedge of clock if Write Enable is true write
  always @(*) begin
      BusA <= register[RA];
      BusB <= register[RB];
  end                       // asynchronously reading using Buses A and B
endmodule
      

      
    
  