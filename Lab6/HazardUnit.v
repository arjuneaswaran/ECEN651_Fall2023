module HazardUnit(
  output reg IFwrite,
  output reg PCwrite,
  output reg bubble,
  output reg[1:0] addrSel,
  input Jump,
  input Branch,
  input ALUZero,
  input memReadEX,
  input Clk,
  input Rst,
  input UseShamt,
  input UseImmed,
  input[4:0] currRs,
  input[4:0] currRt,
  input[4:0] prevRt
);

    parameter NoControlHazard_state = 3'b000, Jump_Encountered = 3'b001, Branch_Encountered = 3'b010, Branch_Taken = 3'b011, LoadHazard_state = 3'b100;

    wire LdHazard;
    assign LdHazard = ((((currRs == prevRt) && (UseShamt == 0)) || ((currRt == prevRt) && (UseImmed == 0))) && memReadEX && (prevRt!=0)) ? 1 : 0;


    reg [1:0] FSM_state, FSM_nxt_state;



    //Sequential Logic
    always @(negedge Clk) begin
		if(Rst == 0) 
			FSM_state <= NoControlHazard_state;
		else
			FSM_state <= FSM_nxt_state;
	end



    //Combinatory Logic
    always @(*) begin
        case(FSM_state) 
            NoControlHazard_state: begin
                if(Jump == 1'b1) begin
                    IFwrite = 1'b0;
                    PCwrite = 1'b1;
                    bubble = 1'b0;
                    addrSel = 2'b01; 
                    FSM_nxt_state = Jump_Encountered;
                end

                else if(LdHazard == 1'b1) begin
                    IFwrite = 1'b0;
                    PCwrite = 1'b0;
                    bubble = 1'b1;
                    addrSel = 2'b00;
                    FSM_nxt_state = LoadHazard_state;
                end
                
                else if(Branch == 1'b1) begin
                    IFwrite = 1'b0;
                    PCwrite = 1'b0;
                    bubble = 1'b0;
                    addrSel = 2'b00; 
                    FSM_nxt_state = Branch_Encountered;
                end
                else begin
                    IFwrite = 1'b1;
                    PCwrite = 1'b1;
                    bubble = 1'b0;
                    addrSel = 2'b00; 
                    FSM_nxt_state = NoControlHazard_state;
                end
                
            end
            
            LoadHazard_state: begin
                    IFwrite = 1'b1;
                    PCwrite = 1'b1;
                    bubble = 1'b0;
                    addrSel = 2'b00; 
                    FSM_nxt_state = NoControlHazard_state;
                    end

            Jump_Encountered: begin
                    IFwrite = 1'b1;
                    PCwrite = 1'b1;
                    bubble = 1'b1;
                    addrSel = 2'b00; 
                    FSM_nxt_state = NoControlHazard_state;
            end

            Branch_Encountered: begin
                if(ALUZero==1) begin
                    IFwrite = 1'b0;
                    PCwrite = 1'b1;
                    bubble = 1'b1;
                    addrSel = 2'b10; 
                    FSM_nxt_state = Branch_Taken;
                end
                else begin
                    IFwrite = 1'b1;
                    PCwrite = 1'b1;
                    bubble = 1'b1;
                    addrSel = 2'b00; 
                    FSM_nxt_state = NoControlHazard_state;
                end
            end

            Branch_Taken: begin
                    IFwrite = 1'b1;
                    PCwrite = 1'b1;
                    bubble = 1'b1;
                    addrSel = 2'b00; 
                    FSM_nxt_state = NoControlHazard_state;
            end
            
            default : begin
                    IFwrite = 1'bx;
                    PCwrite = 1'bx;
                    bubble = 1'bx;
                    addrSel = 2'bxx; 
                    FSM_nxt_state = NoControlHazard_state;
            end
        endcase
    end


endmodule