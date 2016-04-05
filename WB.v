/*
 * д��ģ��  
 * PB10011041 ������ 
 */
module WB (reset, clk, irq, pause, wbIR, wbNPC, wbData, phase,
		   wbR0, wbR1, wbR2, wbR3, wbR4, wbR5, wbR6, wbR7,
		   wbINTF, wbEXC);
		
	input reset, clk, irq, pause;
	input [2:0] phase;
	input [15:0] wbIR, wbNPC;
	input [15:0] wbData;
	output [15:0] wbR0, wbR1, wbR2, wbR3, wbR4, wbR5, wbR6, wbR7;
	output wbINTF, wbEXC;
	
	reg [15:0] wbR0, wbR1, wbR2, wbR3, wbR4, wbR5, wbR6, wbR7;
	reg wbINTF, wbEXC;

	always@(posedge clk)
	begin
	if (pause == 1'b0 && irq == 1'b0)
	begin
		casex(wbIR[15:12])
			4'b0x01:		//ADD ADDI AND ANDI
			begin
				case(wbIR[11:9])
					3'b000: wbR0 <= wbData;
					3'b001: wbR1 <= wbData;
					3'b010: wbR2 <= wbData;
					3'b011: wbR3 <= wbData;
					3'b100: wbR4 <= wbData;
					3'b101: wbR5 <= wbData;
					3'b110: wbR6 <= wbData;
					3'b111: wbR7 <= wbData;
				endcase
				wbINTF <= 1'b0;
				wbEXC <= 1'b0;
			end
			4'b0100:	//JSR JSRR
			begin
				wbR7 <= wbNPC;
				wbINTF <= 1'b0;
				wbEXC <= 1'b0;
			end
			4'b0x10:	//LD LDR
			begin
				case(wbIR[11:9])
					3'b000: wbR0 <= wbData;
					3'b001: wbR1 <= wbData;
					3'b010: wbR2 <= wbData;
					3'b011: wbR3 <= wbData;
					3'b100: wbR4 <= wbData;
					3'b101: wbR5 <= wbData;
					3'b110: wbR6 <= wbData;
					3'b111: wbR7 <= wbData;
				endcase
				wbINTF <= 1'b0;
				wbEXC <= 1'b0;
			end
			4'b1010:	//LDI
			begin
				case(wbIR[11:9])
					3'b000: wbR0 <= wbData;
					3'b001: wbR1 <= wbData;
					3'b010: wbR2 <= wbData;
					3'b011: wbR3 <= wbData;
					3'b100: wbR4 <= wbData;
					3'b101: wbR5 <= wbData;
					3'b110: wbR6 <= wbData;
					3'b111: wbR7 <= wbData;
				endcase
				wbINTF <= 1'b0;
				wbEXC <= 1'b0;
			end
			4'b1110:	//LEA
			begin
				case(wbIR[11:9])
					3'b000: wbR0 <= wbData;
					3'b001: wbR1 <= wbData;
					3'b010: wbR2 <= wbData;
					3'b011: wbR3 <= wbData;
					3'b100: wbR4 <= wbData;
					3'b101: wbR5 <= wbData;
					3'b110: wbR6 <= wbData;
					3'b111: wbR7 <= wbData;
				endcase
				wbINTF <= 1'b0;
				wbEXC <= 1'b0;
			end
			4'b1001:	//NOT LS RS RSS DPS NOP
			begin
				if (wbIR[5:0] != 6'b100010)
				begin
					case(wbIR[11:9])
						3'b000: wbR0 <= wbData;
						3'b001: wbR1 <= wbData;
						3'b010: wbR2 <= wbData;
						3'b011: wbR3 <= wbData;
						3'b100: wbR4 <= wbData;
						3'b101: wbR5 <= wbData;
						3'b110: wbR6 <= wbData;
						3'b111: wbR7 <= wbData;
					endcase
					wbINTF <= 1'b0;
					wbEXC <= 1'b0;
				end
				else	//WPS
				begin
					wbINTF <= 1'b0;
					wbEXC <= 1'b0;
				end
			end
			4'b1000:	//RTI
			begin
				wbR6 <= wbData;
				wbINTF <= 1'b1;
				wbEXC <= 1'b0;
			end
			4'b1111:	//TRAP
			begin
				wbR7 <= wbNPC;
				wbINTF <= 1'b0;
				wbEXC <= 1'b0;
			end
			default:	//BR JMP RET ST STR STI
			begin
				wbINTF <= 1'b0;
				wbEXC <= 1'b0;
			end
		endcase
	end
	else if (phase == 3'b100)
		wbR6 <= wbR6 - 16'h2;
	end
endmodule
