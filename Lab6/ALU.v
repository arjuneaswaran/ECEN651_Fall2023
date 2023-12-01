`timescale 1ns / 1ps



`define AND 4'b0000
`define OR 4'b0001
`define ADD 4'b0010
`define SLL 4'b0011
`define SRL 4'b0100
`define SUB 4'b0110
`define SLT 4'b0111
`define ADDU 4'b1000
`define SUBU 4'b1001
`define XOR 4'b1010
`define SLTU 4'b1011
`define NOR 4'b1100
`define SRA 4'b1101
`define LUI 4'b1110    // `define functions for readability
module ALU(BusW, Zero, BusA, BusB, ALUCtrl
    );
input wire [31:0] BusA, BusB;
output reg [31:0] BusW;
input wire [3:0] ALUCtrl ;
output wire Zero ;  //input and output declarations


assign Zero = (BusW==32'b0) ? 1 : 0;  // zero to check if BusW is 0 or not continuously
always@(*)begin	
	
	case (ALUCtrl)       //case statement(mux in hardware) to select ALU operation
	`AND:   BusW <=  BusA & BusB;
	`OR:    BusW <=  BusA | BusB;
	`ADD:   BusW <=  BusA + BusB;
	`ADDU:  BusW <=  BusA + BusB;
	`SLL:   BusW <=  BusB << BusA;
	`SRL:   BusW <=  BusB >> BusA;
	`SUB:   BusW <=  BusA - BusB;
	`SUBU:  BusW <=  BusA - BusB;
	`XOR:   BusW <=  BusA ^ BusB;
	`NOR:   BusW <=  ~(BusA | BusB);
	`SLT:   BusW <=  $signed(BusA) < $signed(BusB);
	`SLTU:  BusW <=  (BusA<BusB)?1:0;
//    `SRA:  begin
//                if(BusB > 32)
//                    BusW <= (BusA[31] == 1)? 32'hFFFFFFFF : 32'b0;
//                else
//                    BusW <= (BusA[31]==1) ? ((BusA >> BusB) | ~(32'hFFFFFFFF >> BusB)) : (BusA >> BusB);
//           end
// SRA can be done using signed keyword and also above logic which has been designed. But for simplicity signed keyword is used
    `SRA: BusW <= ($signed(BusB)) >>> BusA;
    `LUI:   BusW <=  {BusB[15:0], 16'b0};  // each operation designed as per functionality
	default:BusW <=  32'b0; // default will be 0
	endcase
end
endmodule