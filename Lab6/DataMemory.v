`timescale 1ns / 1ps


module DataMemory(
  output reg [31:0] ReadData,
  input [5:0] Address,
  input [31:0] WriteData,
  input MemoryRead,
  input MemoryWrite,
  input Clock);  // defining inputs
  
  reg [31:0] mem [63:0];  // defining a 256 x 8 word addressible Memory( 32 * 64)
  integer i;


  
  
  always @(posedge Clock) begin
    if(MemoryRead == 1)
      ReadData = mem[Address];
  end                      // at posedge of clock if Memoryread is true read the data from memory
  
  always @(negedge Clock) begin
    if(MemoryWrite == 1)
      mem[Address] = WriteData;  
  end                      // at negedge of clock if MemoryWrute is true write data to memory
endmodule
  