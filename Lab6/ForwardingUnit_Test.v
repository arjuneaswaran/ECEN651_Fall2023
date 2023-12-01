`timescale 1ns / 1ps

module ForwardingUnit_Test;
    task passTest;
        input [31:0] actualOut, expectedOut;
        input [`STRLEN*8:0] testType;
        inout [7:0] passed;

        if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
        else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
    endtask

    task allPassed;
        input [7:0] passed;
        input [7:0] numTests;

        if(passed == numTests) $display ("All tests passed");
        else $display("Some tests failed: %d of %d passed", passed, numTests);
    endtask

    // input UseShamt, UseImmed;
    // input[4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
    // input EX_RegWrite, MEM_RegWrite;
    // output reg [1:0] AluOpCtrlA, AluOpCtrlB;
    // output reg DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;

    reg UseShamt, UseImmed;
    reg [4:0] ID_Rs, ID_Rt, EX_Rw, MEM_Rw;
    reg EX_RegWrite, MEM_RegWrite;
    reg [7:0] passed;

    wire [1:0] AluOpCtrlA, AluOpCtrlB;
    wire DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM;

    ForwardingUnit uut(.UseShamt(UseShamt), .UseImmed(UseImmed), .ID_Rs(ID_Rs), .ID_Rt(ID_Rt), 
    .EX_Rw(EX_Rw, .MEM_Rw(MEM_Rw), .EX_RegWrite(EX_RegWrite), .MEM_RegWrite(MEM_RegWrite),
    .AluOpCtrlA(AluOpCtrlA), .AluOpCtrlB(AluOpCtrlB), .DataMemForwardCtrl_EX(DataMemForwardCtrl_EX),
    .DataMemForwardCtrl_MEM(DataMemForwardCtrl_MEM));

    initial begin
        
        passed = 0;

        //Tests 1 and 2: Check if Original value is chosen when Write Register of either EX instruction or MEM Instruction is R0
        #10
        EX_Rw = {5{1'bX}};
        MEM_Rw = 1;
        passTest({AluOpCtrlA, AluOpCtrlB}, 4'b0);

        #10
        EX_Rw = {5{1'bX}};
        MEM_Rw = 0;
        passTest({AluOpCtrlA, AluOpCtrlB}, 4'b0);

        //Checking if its normal value when RegWrite variables are not enabled.

        #10
        EX_RegWrite = 1'b0;
        MEM_RegWrite = 1'b0;
        passTest({AluOpCtrlA, AluOpCtrlB}, 4'b0);


        //Test 4: Checking UseImmed and UseShamt working

        #10
        UseShamt = 1'b1;
        UseImmed = 1'b1;
        passTest({AluOpCtrlA, AluOpCtrlB}, 4'b1111);

        #10
        UseShamt = 1'b0;
        UseImmed = 1'b0;

        //Test 5 and 6: Testing all possible states of AluOpCtrlA and AluOpCtrlB

        #10
        EX_Rw = 10;
        MEM_Rw = 14;
        ID_Rt = 0;
        EX_RegWrite = 1'b1;
        MEM_RegWrite = 1'b1;

        #10
        ID_Rs = 14;
        passTest(AluOpCtrlA, 2'b10);

        #10
        ID_Rs = 10;
        passTest(AluOpCtrlA, 2'b01);

        #10
        ID_Rs = 9;
        passTest(AluOpCtrlA, 2'b00);

        #10
        EX_Rw = 11;
        MEM_Rw = 11;
        ID_Rs = 11;
        passTest(AluOpCtrlA, 2'b01);

        #10
        EX_Rw = 10;
        MEM_Rw = 14;
        ID_Rs = 0;

        #10
        ID_Rt = 14;
        passTest(AluOpCtrlB, 2'b10);

        #10
        ID_Rt = 10;
        passTest(AluOpCtrlB, 2'b01);

        #10
        ID_Rt = 9;
        passTest(AluOpCtrlB, 2'b00);

        #10
        EX_Rw = 11;
        MEM_Rw = 11;
        ID_Rt = 11;
        passTest(AluOpCtrlB, 2'b01);

        //Resetting to random normal state values

        #10
        EX_Rw = 10;
        MEM_Rw = 14;
        ID_Rt = 5;
        ID_Rs = 7;


        //Test 7: Checking DataMemory MUX signal states

        #10
        ID_Rt = 14;
        passTest({DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM}, 2'b10);

        #10
        MEM_RegWrite = 1'b0;
        passTest({DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM}, 2'b00);

        #10
        ID_Rt = 10;
        passTest({DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM}, 2'b01);

        #10
        EX_RegWrite = 1'b0;
        passTest({DataMemForwardCtrl_EX, DataMemForwardCtrl_MEM}, 2'b00);


        allPassed(passed, 16);
        
        ForwardingUnit uut(.UseShamt(UseShamt), .UseImmed(UseImmed);



        









    end





endmodule