/*
 * ·Ã´æÄ£¿é  
 * PB10011041 ÍõÔÂÅô 
 */
module MEM (reset, clk, irq, memALUoutput, memTMP, 
			memIRin, memNPCin, memMD,
			memMD_out, memRD, memWE, memMA, 
			memIRout, memNPCout, memData, 
			Pause, memPSR, memPCout, memCond,
			memN, memZ, memP);

	input [15:0] memMD;
	output [15:0] memMD_out;
	
	input reset, clk, irq;
	input [15:0] memALUoutput, memTMP;
	input [15:0] memIRin, memNPCin;

	output memRD, memWE;
	output [15:0] memMA;
	output [15:0] memIRout, memNPCout, memData;
	output Pause;
	output [15:0] memPSR;
	output [15:0] memPCout;
	output memCond;
	output memN, memZ, memP;
	
	
	reg memRD, memWE;
	reg [15:0] memMA;
	reg [15:0] memIRout, memNPCout, memData;
	reg [15:0] memMD_out;
	reg [15:0] memPSR;
	reg memPause;
	reg [15:0] memPCout;
	reg memCond;
	reg Pause;
	reg memN, memZ, memP;
	
	reg [15:0] MA_TMP;	//inside reg for saving indirect instruction's MA
	
	always @(memALUoutput or memMD or memTMP or memIRin or memPause or MA_TMP)
	begin
		casex({memIRin[15:12]})
			4'b0x10:	//LD LDR
			begin
				memMA = memALUoutput;
				memMD_out = 16'h0;
				memRD = 1'b1;
				memWE = 1'b0;
				Pause = 1'b0;
			end
			4'b1010:	//LDI
			begin
				if (memPause == 1'b0)
				begin
					memMA = memALUoutput;
					memMD_out = 16'h0;
					memRD = 1'b1;
					memWE = 1'b0;
					Pause = 1'b1;
				end
				else	//memPause == 1'b1
				begin
					memMA = MA_TMP;
					memMD_out = 16'h0;
					memRD = 1'b1;
					memWE = 1'b0;
					Pause = 1'b0;
				end
			end
			4'b1000:	//RTI
			begin
				if (memPause == 1'b0)
				begin
					memMA = memALUoutput + 16'h1;
					memMD_out = 16'h0;
					memRD = 1'b1;
					memWE = 1'b0;
					Pause = 1'b1;
				end
				else	//memPause == 1'b1
				begin
					memMA = memALUoutput + 16'h2;
					memMD_out = 16'h0;
					memRD = 1'b1;
					memWE = 1'b0;
					Pause = 1'b0;
				end
			end
			4'b0x11:	//ST STR
			begin
				memMA = memALUoutput;
				memMD_out = memTMP;
				memWE = 1'b1;
				memRD = 1'b0;
				Pause = 1'b0;
			end
			4'b1011:	//STI
			begin
				if (memPause == 1'b0)
				begin
					memMA = memALUoutput;
					memMD_out = 16'h0;
					memRD = 1'b1;
					memWE = 1'b0;
					Pause = 1'b1;
				end
				else	//memPause == 1'b1
				begin
					memMA = MA_TMP;
					memMD_out = memTMP;
					memRD = 1'b0;
					memWE = 1'b1;
					Pause = 1'b0;
				end
			end
			4'b1111:	//TRAP
			begin
				memMA = memALUoutput;
				memMD_out = 16'h0;
				memWE = 1'b0;
				memRD = 1'b1;
				Pause = 1'b0;
			end
			default:
			begin
				memMA = 16'h0;
				memMD_out = 16'h0;
				memRD = 1'b0;
				memWE = 1'b0;
				Pause = 1'b0;
			end
		endcase
	end
	
	always @(posedge clk)
	begin
		if (irq == 1'b0)
		begin
		memIRout <= memIRin;
		memNPCout <= memNPCin;
		casex({memIRin[15:12]})
			4'b0x01:		//ADD ADDI AND ANDI
			begin
				memPause <= 1'b0;
				memData <= memALUoutput;
				memCond <= 1'b0;
				memN <= 1'b0;
				memZ <= 1'b0;
				memP <= 1'b0;
			end
			4'b0x10:	//LD LDR
			begin
				memPause <= 1'b0;
				memData <= memMD;
				memCond <= 1'b0;
				memN <= memMD[15];
             	memZ <= (memMD[15:0]==0);
             	memP <= !memMD[15] & !(memMD[14:0]==0);
			end
			4'b1010:	//LDI
			begin
				if (memPause == 1'b0)
				begin
					memPause <= 1'b1;
					MA_TMP <= memMD;
				end
				else
				begin
					memPause <= 1'b0;
					memData <= memMD;
					memN <= memMD[15];
	             	memZ <= (memMD[15:0]==0);
	             	memP <= !memMD[15] & !(memMD[14:0]==0);
				end
				memCond <= 1'b0;
			end
			4'b1110:	//LEA
			begin
				memPause <= 1'b0;
				memData <= memALUoutput;
				memCond <= 1'b0;
				memN <= 1'b0;
				memZ <= 1'b0;
				memP <= 1'b0;
			end
			4'b1001:	//NOT LS RS RSS DPS WPS NOP
			begin
				memN <= 1'b0;
				memZ <= 1'b0;
				memP <= 1'b0;
				if (memIRin[5:0] == 6'b100010)	//WPS
				begin
					memPause <= 1'b0;
					memPSR <= memALUoutput;
					memCond <= 1'b0;
				end
				else if (memIRin[5:0] == 6'b000000) //NOP
				begin
					memPause <= 1'b0;
					memData <= memALUoutput;
					memCond <= 1'b0;
				end
				else					
				begin
					memPause <= 1'b0;
					memData <= memALUoutput;
					memCond <= 1'b0;
				end
			end
			4'b1000:	//RTI
			begin
				memN <= 1'b0;
				memZ <= 1'b0;
				memP <= 1'b0;
				if (memPause == 1'b0)
				begin
					memPause <= 1'b1;
					memPCout <= memMD;
					memCond <= 1'b1;
				end
				else
				begin
					memPause <= 1'b0;
					memPSR <= memMD;
					memData <= memALUoutput + 16'h2;
					memCond <= 1'b0;
				end
			end
			4'b1011:	//STI
			begin
				memN <= 1'b0;
				memZ <= 1'b0;
				memP <= 1'b0;
				memCond <= 1'b0;
				if (memPause == 1'b0)
				begin
					memPause <= 1'b1;
					MA_TMP <= memMD;
				end
				else
				begin
					memPause <= 1'b0;
				end
			end
			4'b1111:	//TRAP
			begin
				memN <= 1'b0;
				memZ <= 1'b0;
				memP <= 1'b0;
				memPause <= 1'b0;
				memPCout <= memMD;
				memCond <= 1'b1;
			end
			default:
			begin
				memN <= 1'b0;
				memZ <= 1'b0;
				memP <= 1'b0;
				memPause <= 1'b0;
				memData <= 16'h0;
			end
		endcase
		end
		else
			memIRout <= 16'h9000;
	end

endmodule
