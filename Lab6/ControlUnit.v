`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:23:34 03/10/2009 
// Design Name: 
// Module Name:    SingleCycleControl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define RTYPEOPCODE 6'b000000
`define LWOPCODE        6'b100011
`define SWOPCODE        6'b101011
`define BEQOPCODE       6'b000100
`define JOPCODE     6'b000010
`define ORIOPCODE       6'b001101
`define ADDIOPCODE  6'b001000
`define ADDIUOPCODE 6'b001001
`define ANDIOPCODE  6'b001100
`define LUIOPCODE       6'b001111
`define SLTIOPCODE  6'b001010
`define SLTIUOPCODE 6'b001011
`define XORIOPCODE  6'b001110

`define SLLFunc  6'b000000
`define SRLFunc  6'b000010
`define SRAFunc  6'b000011

`define AND     4'b0000
`define OR      4'b0001
`define ADD     4'b0010
`define SLL     4'b0011
`define SRL     4'b0100
`define SUB     4'b0110
`define SLT     4'b0111
`define ADDU    4'b1000
`define SUBU    4'b1001
`define XOR     4'b1010
`define SLTU    4'b1011
`define NOR     4'b1100
`define SRA     4'b1101
`define LUI     4'b1110
`define FUNC    4'b1111

module ControlUnit(RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend, ALUOp, UseShamt, Opcode, FuncCode);
   input [5:0] FuncCode;
   input [5:0] Opcode;
   output RegDst;
   output ALUSrc;
   output MemToReg;
   output RegWrite;
   output MemRead;
   output MemWrite;
   output Branch;
   output Jump;
   output SignExtend;
   output [3:0] ALUOp;
   output UseShamt;
     
    reg RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, SignExtend, UseShamt;
    reg  [3:0] ALUOp;
    always @ (Opcode) begin
//    if(Bubble) begin 
//                RegDst <= #2 1'b0;
//                ALUSrc <= #2 1'b0;
//                MemToReg <= #2 1'b0;
//                RegWrite <= #2 1'b0;
//                MemRead <= #2 1'b0;
//                MemWrite <= #2 1'b0;
//                Branch <= #2 1'b0;
//                Jump <= #2 1'b0;
//                SignExtend <= #2 1'b0;
//                ALUOp <= #2 4'b0000;        
//                UseShamt <= #2 1'b0;
//     end
//     else begin
        case(Opcode)
            `RTYPEOPCODE: begin
                RegDst <= #2 1;
                ALUSrc <= #2 0;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 `FUNC;          // R Type Control Signals
                UseShamt <= #2 0;
                if(FuncCode == `SLLFunc || FuncCode == `SRLFunc || FuncCode == `SRAFunc) begin
                UseShamt <= #2 1;
                end
            end

            `LWOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 1;
                RegWrite <= #2 1;
                MemRead <= #2 1;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b1;
                ALUOp <= #2 `ADD;          // LW Type Control Signals
                UseShamt <= #2 0;

            end

            `SWOPCODE: begin
                RegDst <= #2 1'bx;
                ALUSrc <= #2 1;
                MemToReg <= #2 1'bx;
                RegWrite <= #2 0;
                MemRead <= #2 0;
                MemWrite <= #2 1;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b1;
                ALUOp <= #2 `ADD;           // SW Type Control Signals
                UseShamt <= #2 0;
            end

            `BEQOPCODE: begin
                RegDst <= #2 1'bx;
                ALUSrc <= #2 0;
                MemToReg <= #2 1'bx;
                RegWrite <= #2 0;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 1;
                Jump <= #2 0;
                SignExtend <= #2 1'b1;
                ALUOp <= #2 `SUB;           // BEQ Type Control Signals
                UseShamt <= #2 0;
            end

            `JOPCODE: begin
                RegDst <= #2 1'bx;
                ALUSrc <= #2 1'bx;
                MemToReg <= #2 1'bx;
                RegWrite <= #2 0;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 1;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 4'bxxxx;        // J Type Control Signals
                UseShamt <= #2 0;
            end

            `ORIOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 `OR;            // ORI Type Control Signals
                UseShamt <= #2 0;
            end

            `ADDIOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b1;
                ALUOp <= #2 `ADD;           // ADDI Type Control Signals
                UseShamt <= #2 0;
            end

            `ADDIUOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 `ADDU;          // ADDIU Type Control Signals
                UseShamt <= #2 0;
            end

            `ANDIOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 `AND;           // ANDI Type Control Signals
                UseShamt <= #2 0;
            end

            `LUIOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 `LUI;           // LUI Type Control Signals
                UseShamt <= #2 0;
            end

            `SLTIOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b1;
                ALUOp <= #2 `SLT;           // SLTI Type Control Signals
                UseShamt <= #2 0;
            end

            `SLTIUOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 `SLTU;          // SLTIU Type Control Signals
                UseShamt <= #2 0;
            end

            `XORIOPCODE: begin
                RegDst <= #2 0;
                ALUSrc <= #2 1;
                MemToReg <= #2 0;
                RegWrite <= #2 1;
                MemRead <= #2 0;
                MemWrite <= #2 0;
                Branch <= #2 0;
                Jump <= #2 0;
                SignExtend <= #2 1'b0;
                ALUOp <= #2 `XOR;           // XOR Type Control Signals
                UseShamt <= #2 0;
            end

            default: begin
                RegDst <= #2 1'bx;
                ALUSrc <= #2 1'bx;
                MemToReg <= #2 1'bx;
                RegWrite <= #2 1'bx;
                MemRead <= #2 1'bx;
                MemWrite <= #2 1'bx;
                Branch <= #2 1'bx;
                Jump <= #2 1'bx;
                SignExtend <= #2 1'bx;
                ALUOp <= #2 4'bxxxx;        //Default signal values to prevent latch forming
                UseShamt <= #2 1'bx;
            end
        endcase           
        /*
        The above Control Unit logic is a large Switch case (MUX in hardware logic) which selects the values of the numerous control signals used in the ALU design logic.
        */
    end
//    end
endmodule
