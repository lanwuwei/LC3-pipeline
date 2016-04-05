/*
 * 执行模块  
 * PB10011041 王月鹏 
 */
module EX(clk, reset, irq, pause, exA, exB, exImm, exIRin, exNPCin,
		  exPSRin,	//for BR RRS
		  exIRout, exNPCout, exALUoutput, exTMP,
		  exN, exZ, exP, exVFn, exVFp, exCond, exPCout, exPSRout);

	input clk, reset, irq, pause;
	input [15:0] exA, exB, exImm;
	input [15:0] exIRin, exNPCin;
	input [15:0] exPSRin;
	output [15:0] exIRout, exNPCout;
	output [15:0] exALUoutput, exTMP;
	output exN, exZ, exP, exVFn, exVFp;
	output exCond;
	output [15:0] exPCout;
	
	output [15:0] exPSRout;
	
	assign exPSRout = exPSRin;
	
	reg [15:0] exIRout;
	reg [15:0] exNPCout;
	reg [15:0] result, TMP;
	reg [15:0] exALUoutput, exTMP;
	reg exN, exZ, exP, exVFn, exVFp;
	reg exCond;
	reg [15:0] exPCout;
	reg Cond;
	reg [15:0] PCout;

	always @(posedge clk)
	begin
		if (pause == 1'b0 && irq == 1'b0)
		begin
		exNPCout <= exNPCin;
		exIRout <= exIRin;
		exALUoutput <= result;
		exTMP <= TMP;
		exCond <= Cond;
		exPCout <= PCout;
		casex({exIRin[15:12], exIRin[5]})
			5'b0001_0:		//ADD
			begin
                exVFn  <=    exA[15] &  exB[15] & !result[15];
                exN    <=   (exA[15] &  exB[15] & !result[15])
                       	 | (!(!exA[15] & !exB[15] &  result[15]) & result[15]);
                exVFp  <=    !exA[15] & !exB[15] &  result[15];
                exP    <=   (!exA[15] & !exB[15] &  result[15])  
                         | (!(exA[15] &  exB[15] & !result[15]) & !result[15] & !(result[14:0]==0));     
                exZ    <= (result[14:0]==0) & (exA[15] ^ exB[15]);
			end
			5'b0001_1:		//ADDI
			begin
                exVFn  <=    exA[15] &  exImm[15] & !result[15];
                exN    <=   (exA[15] &  exImm[15] & !result[15])
                       	| (!(!exA[15] & !exImm[15] &  result[15]) & result[15]);
                exVFp  <=    !exA[15] & !exImm[15] &  result[15];
                exP    <=   (!exA[15] & !exImm[15] &  result[15])  
                       	| (!(exA[15] &  exImm[15] & !result[15]) & !result[15] & !(result[14:0]==0));     
                exZ    <= (result[14:0]==0) & (exA[15] ^ exImm[15]);
			end
			5'b0101_0:		//AND
			begin
				exN <= result[15];
             	exZ <= (result[15:0]==0);
             	exP <= !result[15] & !(result[14:0]==0);
			end
			5'b0101_1:		//ANDI
			begin
				exN <= result[15];
             	exZ <= (result[15:0]==0);
             	exP <= !result[15] & !(result[14:0]==0);
			end
			5'b1001_x:
			begin
				case(exIRin[5:4])
				2'b11:		//NOT
				begin
					exN <= result[15];
             		exZ <= (result[15:0]==0);
             		exP <= !result[15] & !(result[14:0]==0);
				end
				2'b00:		//LS NOP
				begin
					if (exIRin[5:0] != 6'b000000)
					begin
						exN <= result[15];
	             		exZ <= (result[15:0]==0);
	             		exP <= !result[15] & !(result[14:0]==0);
					end
				end
				2'b10:		//DPS WPS RRS
				begin		//RRS should consider the PSR
					if (exIRin[5:0] == 6'b100000)	//RRS
					begin
						exVFp <= exA[0];
					end
					if (exIRin[5:0] == 6'b100010)	//WPS
					begin
						exVFn <= exA[4];
						exVFp <= exA[3];
						exN <= exA[2];
						exZ <= exA[1];
						exP <= exA[0];
					end
				end
				2'b01:		//RS
				begin
					exN <= result[15];
             		exZ <= (result[15:0]==0);
             		exP <= !result[15] & !(result[14:0]==0);
				end
				endcase
			end
		endcase
		end
		else if (irq == 1'b1)
			exIRout <= 16'h9000;
	end

	always @(exA or exB or exImm or exIRin or exNPCin or exPSRin)
	begin
		casex({exIRin[15:12], exIRin[5]})
			5'b0001_0:		//ADD
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exA + exB;
				TMP = 16'h0;
			end
			5'b0001_1:		//ADDI
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exA + exImm;
				TMP = 16'h0;
			end
			5'b0101_0:		//AND
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exA & exB;
				TMP = 16'h0;
			end
			5'b0101_1:		//ANDI
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exA & exImm;
				TMP = 16'h0;
			end
			5'b0000_x:	//BR
			begin
				TMP = 16'h0;
				result = 16'h0;
				if ((exIRin[11] == 1'b1 && exPSRin[2] == 1'b1) 
						 || (exIRin[10] == 1'b1 && exPSRin[1] == 1'b1) 
						 || (exIRin[9] == 1'b1 && exPSRin[0] == 1'b1)
			         	 || ((exIRin[11:9] == 3'b000) && (exPSRin[4] == 1'b1 || exPSRin[3] == 1'b1))
						)
					begin
						Cond = 1'b1;
						PCout = exNPCin + exImm;
					end
				else
					begin
						Cond = 1'b0;
						PCout = 16'h0;
					end
			end
			5'b0010_x:	//LD
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exNPCin + exImm;
				TMP = 16'h0;
			end
			5'b1010_x:	//LDI
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exNPCin + exImm;
				TMP = 16'h0;
			end
			5'b0110_x:	//LDR
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exA + exImm;
				TMP = 16'h0;
			end
			5'b1110_x:	//LEA
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exNPCin + exImm;
				TMP = 16'h0;
			end
			5'b1000_x:	//RTI
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exA;
				TMP = 16'h0;
			end
			5'b0011_x:	//ST
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exNPCin + exImm;
				TMP = exA;		
			end
			5'b1011_x:	//STI
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exNPCin + exImm;
				TMP = exA;
			end
			5'b0111_x:	//STR
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exB + exImm;
				TMP = exA;
			end
			5'b1111_x:	//TRAP
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = exImm;
				TMP = 16'h0;
			end
			5'b1001_x:
			begin
				TMP = 16'h0;
				Cond = 1'b0;
				PCout = 16'h0;
				case(exIRin[5:4])
				2'b11:		//NOT
				begin
					result = ~exA;
				end
				2'b10:		//DPS WPS RRS
				begin		//RRS should consider the PSR
					if (exIRin[5:0] == 6'b100000)	//RRS
					begin
						result[15] = exPSRin[3];
						result[14:0] = exA[15:1];
						// VFp <= exA[0]; 时序逻辑  
					end
					else
					begin
						result = exA;
					end
				end
				2'b00:		//LS NOP
				begin
					result = exA << exImm;
				end
				2'b01:		//RS
				begin
					result = exA >> exImm;
				end
				endcase
			end
			default:		//JMP RET JSR JSRR BR
			begin
				Cond = 1'b0;
				PCout = 16'h0;
				result = 16'h0;
				TMP = 16'h0;
			end
		endcase
	end
endmodule
