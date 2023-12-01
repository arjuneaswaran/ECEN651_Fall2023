`timescale 1ns / 1ps

module PipelinedProc(CLK, Reset_L, startPC, dMemOut);
	input CLK;
	input Reset_L;
	input [31:0] startPC;
	output [31:0] dMemOut;
	
	//Hazard
	wire Bubble;
	wire PCWrite;
	wire IFWrite;
	wire [1:0] addrSel;

	//Sign Extended Immediate
	wire [31:0] signExtImm;
	reg [31:0] signExtImm3;
	
	//Jump and Branch Targets
	wire [31:0] jumpTarget, branchTarget;
	
	
	//Control Unit WIRES
	wire regDst, aluSrc, memToReg, regWrite, memRead, memWrite, branch, jump, signExtend, UseImmed, UseShamt;
	wire [3:0] AluOp;
	wire	[5:0]	opcode;
	wire	[4:0]	rs, rt, rd;
	wire	[15:0]	imm16;
	wire	[4:0]	shamt;
	wire	[5:0]	func;
	
	
	//Forwarding Unit Outputs
	wire [1:0] AluOpCtrlA, AluOpCtrlB;
	wire DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;
	//Alu Zero
	wire aluZero;
	
	//ALU Stage
	wire [31:0] busA,busB;
	reg [31:0] ALUAIn3, ALUBIn3;
	wire aluOut, aluCtrl;
	
	//Memory
	wire [31:0] dataMemIn, memOut;

	//Stage 1
	reg [31:0]	currentPC;
	wire [31:0]	currentInstruction;
	reg [31:0] nextPC;
	reg	[31:0]	currentPCPlus4;
	
	//Stage 2
	reg [31:0] currentInstruction2;
	reg [25:0] instruction_26_bit;
	
	//Stage 3
	reg memRead3;
	wire [4:0] rt3, rd3;
	reg [4:0] rw3;
	reg regWrite3;
	reg regDst3, memToReg3, memWrite3, branch3;
	reg [3:0] aluOp3;
	reg [1:0] AluOpCtrlA3, AluOpCtrlB3;
	reg DataMemForwardCtrl_MEM3, DataMemForwardCtrl_EX3;
	wire [4:0] Shamt3;
	wire [5:0] FuncCode3;
	wire [31:0] dataMemInput3;
	
	
	
	//Stage 4
	reg [4:0] rw4;
	reg regWrite4;
	reg [31:0] aluOut4;
	reg [31:0] dataMemInput4;
	reg memToReg4, memRead4, memWrite4, DataMemForwardCtrl_MEM4;
	
	
	
	//Stage 5
	reg regWrite5;
	wire [31:0] regWriteData5;
	reg [4:0] rw5;
	reg [31:0] aluOut5;
	reg [31:0] memOut5;
	reg memToReg5;
	
	
	


	always @ (*) begin
		case(addrSel)
			2'b00: nextPC = currentPCPlus4;
			2'b01: nextPC = jumpTarget;
			2'b10: nextPC = branchTarget;
			default: nextPC = currentPCPlus4;
		endcase
	 end

	 assign jumpTarget = {currentPCPlus4 [31:28], currentInstruction2[25:0], 2'b0};
	 assign branchTarget = currentPCPlus4 + {signExtImm[29:0], 2'b0};

	 always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L)
			currentPC = startPC;
		else if(PCWrite)
			currentPC = nextPC;
	end
	
    InstructionMemory instrMemory(.Data(currentInstruction), .Address(currentPC));


	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			currentInstruction2 = 32'b0;
			currentPCPlus4 = startPC;
		end
		else 
		  if(IFWrite) begin
			currentInstruction2 = currentInstruction;
			currentPCPlus4 = currentPC + 4;
		  end
	    
	end


	assign {opcode, rs, rt, rd, shamt, func} = currentInstruction2;

	ControlUnit PCC1 (.RegDst(regDst), .UseShamt(UseShamt),.ALUSrc(UseImmed), .MemToReg(memToReg), .RegWrite(regWrite), 
					  .MemRead(memRead), .MemWrite(memWrite), .Branch(branch), .Jump(jump), .SignExtend(signExtend), 
					  .ALUOp(AluOp), .Opcode(opcode), .FuncCode(func));


	assign signExtImm = !signExtend ? {16'b0, imm16[15:0]} : { {16{imm16[15]}}, imm16[15:0] }; 

	HazardUnit Hazard (.IFwrite(IFWrite), .PCwrite(PCWrite), .bubble(Bubble), .addrSel(addrSel), .Jump(jump), .Branch(branch), .ALUZero(aluZero),
					   .memReadEX(memRead3), .currRs(rs), .currRt(rt), .prevRt(rt3), 
					   .UseShamt(UseShamt), .UseImmed(UseImmed), .Clk(CLK), .Rst(Reset_L));

	
	RegisterFile Registers(.BusA(busA), .BusB(busB), .BusW(regWriteData5), 
	.RA(rs), .RB(rt), .RW(rw5), .RegWr(regWrite5), .Clk(CLK));


	ForwardingUnit Forward( .UseShamt(UseShamt), .UseImmed(UseImmed), .ID_Rs(rs),.ID_Rt(rt), 
							.EX_Rw(rw3),.MEM_Rw(rw4), .EX_RegWrite(regWrite3), .MEM_RegWrite(regWrite4), 
							.AluOpCtrlA(AluOpCtrlA), .AluOpCtrlB(AluOpCtrlB),
							.DataMemForwardCtrl_EX(DataMemForwardCtrl_EX), .DataMemForwardCtrl_MEM(DataMemForwardCtrl_MEM) );
	


	always @ (negedge CLK or negedge Reset_L) begin
			if(~Reset_L) begin
					ALUAIn3 <= 0;
					ALUBIn3 <= 0;
					instruction_26_bit <= 0;
					signExtImm3 <= 0;
					rw3 <= 0;
					regDst3 <= 0;
					memToReg3 <= 0;
					regWrite3 <= 0;
					memRead3 <= 0;
					memWrite3 <= 0;
					branch3 <= 0;
					aluOp3 <= 0;
					AluOpCtrlA3 <= 0;
					AluOpCtrlB3 <= 0;
					DataMemForwardCtrl_EX3 <= 0;
					DataMemForwardCtrl_MEM3 <= 0;
					end
			else if(Bubble) begin
					ALUAIn3 <= 0;
					ALUBIn3 <= 0;
					instruction_26_bit <= 0;
					signExtImm3 <= 0;
					rw3 <= 0;
					regDst3 <= 0;
					memToReg3 <= 0;
					regWrite3 <= 0;
					memRead3 <= 0;
					memWrite3 <= 0;
					branch3 <= 0;
					aluOp3 <= 0;
					AluOpCtrlA3 <= 0;
					AluOpCtrlB3 <= 0;
					DataMemForwardCtrl_EX3 <= 0;
					DataMemForwardCtrl_MEM3 <= 0;
					end
				else begin
						ALUAIn3 <= busA;
						ALUBIn3 <= busB;
						instruction_26_bit <= currentInstruction2[25:0];
						signExtImm3 <= signExtImm;
						rw3 <= regWrite;
						regDst3 <= regDst;
						memToReg3 <= memToReg;
						regWrite3 <= regWrite;
						memRead3 <= memRead;
						memWrite3 <= memWrite;
						branch3 <= branch;
						aluOp3 <= AluOp;
						AluOpCtrlA3 <= AluOpCtrlA;
						AluOpCtrlB3 <= AluOpCtrlB;
						DataMemForwardCtrl_EX3 <= DataMemForwardCtrl_EX;
						DataMemForwardCtrl_MEM3 <= DataMemForwardCtrl_MEM;
					end
			end

	

	

	assign rt3 = instruction_26_bit[20:16];
	assign rd3 = instruction_26_bit[15:11];
	assign Shamt3 = instruction_26_bit[10:6];
	assign FuncCode3 = instruction_26_bit[5:0];


	always @(*)begin 
			case (AluOpCtrlA3)
			2'b00: ALUAIn3 = {27'b0, Shamt3};
			2'b01: ALUAIn3 = regWriteData5;
			2'b10: ALUAIn3 = aluOut4;
			2'b11: ALUAIn3 = ALUAIn3;
			endcase
		end 
		always @(*)begin 
			case (AluOpCtrlB3)
			2'b00: ALUBIn3 = signExtImm3;
			2'b01: ALUBIn3 = regWriteData5;
			2'b10: ALUBIn3 = aluOut4;
			2'b11: ALUBIn3 = ALUBIn3;
			endcase
	end 

	ALU mainALU(.BusW(aluOut), .Zero(aluZero), .BusA(ALUAIn3), .BusB(ALUBIn3), .ALUCtrl(aluCtrl));

	ALUControl mainALUControl(.ALUCtrl(aluCtrl), .ALUop(aluOp3), .FuncCode(FuncCode3));

	assign dataMemInput3 = DataMemForwardCtrl_EX3 ?  regWriteData5 : ALUBIn3;

	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			dataMemInput4 <= 0;
			aluOut4 <= 0;
			rw4 <= 0;
			memToReg4 <= 0;
			regWrite4 <= 0;
			memRead4 <= 0;
			memWrite4 <= 0;
			DataMemForwardCtrl_MEM4 <= 0;
		end
		else begin
			dataMemInput4 <= dataMemInput3;
			aluOut4 <= aluOut;
			rw4 <= rw3;
			memToReg4 <= memToReg3;
			regWrite4 <= regWrite3;
			memRead4 <= memRead3;
			memWrite4 <= memWrite3;
			DataMemForwardCtrl_MEM4 <= DataMemForwardCtrl_MEM3;
		end
	end


	assign dataMemIn = DataMemForwardCtrl_MEM4 ?  regWriteData5 : ALUBIn3;

	DataMemory dmem(.ReadData(memOut), .Address(aluOut4), .WriteData(dataMemIn), 
					.MemoryRead(memRead4), .MemoryWrite(memWrite4), .Clock(CLK));

	always @ (negedge CLK or negedge Reset_L) begin
		if(~Reset_L) begin
			memOut5 <= 0;
			aluOut5 <= 0;
			rw5 <= 0;
			memToReg5 <= 0;
			regWrite5 <= 0;
		end
		else begin
			memOut5 <= memOut;
			aluOut5 <= aluOut4;
			rw5 <= rw4;
			memToReg5 <= memToReg4;
			regWrite5 <= regWrite4;
		end
	end

	assign regWriteData5 = memToReg5 ? memOut5 : aluOut5;

	assign dMemOut = memOut5;


endmodule