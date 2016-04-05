/*
 * 译码模块 
 * PB10011041 王月鹏 
 */

module ID(clk, reset, irq, pause, idIRin, idNPCin, idPSR,
		  idR0, idR1, idR2, idR3, idR4, idR5, idR6, idR7,
		  idA, idB, idImm, idIRout, idNPCout,
		  idPCout, idCond, idEXCout);

	input clk, reset, irq, pause;
	input [15:0] idIRin;
	input [15:0] idNPCin;
	input [15:0] idPSR;
	input [15:0] idR0, idR1, idR2, idR3, idR4, idR5, idR6, idR7;
	output [15:0] idA, idB, idImm;
	output [15:0] idIRout, idNPCout;
	output [15:0] idPCout;
	output idCond, idEXCout;

	reg [15:0] idA, idB, idImm;
	reg [15:0] idIRout, idNPCout;

	reg [15:0] idPCout;
	reg idCond, idEXCout;

	always @(negedge clk)
	begin
		if (pause == 1'b0 && irq == 1'b0)
		begin
		idIRout <= idIRin;
		idNPCout <= idNPCin;
		casex({idIRin[15:12], idIRin[5]})
			5'b0x01_0:		//0001 ADD 0101 AND
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				case(idIRin[8:6])
					3'b000: idA <= idR0;
					3'b001: idA <= idR1;
					3'b010: idA <= idR2;
					3'b011: idA <= idR3;
					3'b100: idA <= idR4;
					3'b101: idA <= idR5;
					3'b110: idA <= idR6;
					3'b111: idA <= idR7;
				endcase
				case(idIRin[2:0])
					3'b000: idB <= idR0;
					3'b001: idB <= idR1;
					3'b010: idB <= idR2;
					3'b011: idB <= idR3;
					3'b100: idB <= idR4;
					3'b101: idB <= idR5;
					3'b110: idB <= idR6;
					3'b111: idB <= idR7;
				endcase
			end
			5'b0x01_1:		//ADDI ANDI
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				case(idIRin[8:6])
					3'b000: idA <= idR0;
					3'b001: idA <= idR1;
					3'b010: idA <= idR2;
					3'b011: idA <= idR3;
					3'b100: idA <= idR4;
					3'b101: idA <= idR5;
					3'b110: idA <= idR6;
					3'b111: idA <= idR7;
				endcase
				if (idIRin[4] == 0)
					idImm <= {11'h0, idIRin[4:0]};
				else
					idImm <= {11'h7FF, idIRin[4:0]};
			end
			5'b0000_x:	//BR
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				if (idIRin[8] == 0)
					idImm <= {7'h0, idIRin[8:0]};
				else
					idImm <= {7'h7F, idIRin[8:0]};
			end
			5'b1100_x:	//JMP
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b1;
				case(idIRin[8:6])
					3'b000: idPCout <= idR0;
					3'b001: idPCout <= idR1;
					3'b010: idPCout <= idR2;
					3'b011: idPCout <= idR3;
					3'b100: idPCout <= idR4;
					3'b101: idPCout <= idR5;
					3'b110: idPCout <= idR6;
					3'b111: idPCout <= idR7;	//RET
				endcase	
			end
			5'b0100_x:	//JSR JSRR
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b1;
				case(idIRin[11:10])
				2'b11:			//JSR
				begin
					idPCout <= idNPCin + {5'h1F, idIRin[10:0]};
				end
				2'b10:			//JSR
				begin
					idPCout <= idNPCin + {5'h0, idIRin[10:0]};
				end
				default:		//JSRR
				begin
					case(idIRin[8:6])
						3'b000: idPCout <= idR0;
						3'b001: idPCout <= idR1;
						3'b010: idPCout <= idR2;
						3'b011: idPCout <= idR3;
						3'b100: idPCout <= idR4;
						3'b101: idPCout <= idR5;
						3'b110: idPCout <= idR6;
						3'b111: idPCout <= idR7;
					endcase
				end
				endcase
			end
			5'b0010_x:	//LD
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				if (idIRin[8] == 1'b0)
					idImm <= {7'h0, idIRin[8:0]};
				else
					idImm <= {7'h7F, idIRin[8:0]};
			end
			5'b1010_x:	//LDI
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				if (idIRin[8] == 1'b0)
					idImm <= {7'h0, idIRin[8:0]};
				else
					idImm <= {7'h7F, idIRin[8:0]};
			end
			5'b0110_x:	//LDR
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				case(idIRin[8:6])
					3'b000: idA <= idR0;
					3'b001: idA <= idR1;
					3'b010: idA <= idR2;
					3'b011: idA <= idR3;
					3'b100: idA <= idR4;
					3'b101: idA <= idR5;
					3'b110: idA <= idR6;
					3'b111: idA <= idR7;
				endcase
				if (idIRin[5] == 0)
					idImm <= {10'h0, idIRin[5:0]};
				else
					idImm <= {10'h3FF, idIRin[5:0]};								
			end
			5'b1110_x:	//LEA
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				if (idIRin[8] == 0)
					idImm <= {7'h0, idIRin[8:0]};
				else
					idImm <= {7'h7F, idIRin[8:0]};
			end
			5'b1000_x:	//RTI
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				idA <= idR6;
			end
			5'b0011_x:	//ST
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				case(idIRin[11:9])
					3'b000: idA <= idR0;
					3'b001: idA <= idR1;
					3'b010: idA <= idR2;
					3'b011: idA <= idR3;
					3'b100: idA <= idR4;
					3'b101: idA <= idR5;
					3'b110: idA <= idR6;
					3'b111: idA <= idR7;
				endcase
				if (idIRin[8] == 0)
					idImm <= {7'h0, idIRin[8:0]};
				else
					idImm <= {7'h7F, idIRin[8:0]};			
			end
			5'b1011_x:	//STI
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				case(idIRin[11:9])
					3'b000: idA <= idR0;
					3'b001: idA <= idR1;
					3'b010: idA <= idR2;
					3'b011: idA <= idR3;
					3'b100: idA <= idR4;
					3'b101: idA <= idR5;
					3'b110: idA <= idR6;
					3'b111: idA <= idR7;
				endcase
				if (idIRin[8] == 0)
					idImm <= {7'h0, idIRin[8:0]};
				else
					idImm <= {7'h7F, idIRin[8:0]};
			end
			5'b0111_x:	//STR
			begin
				idEXCout <= 1'b0;
				idCond <= 1'b0;
				case(idIRin[11:9])
					3'b000: idA <= idR0;
					3'b001: idA <= idR1;
					3'b010: idA <= idR2;
					3'b011: idA <= idR3;
					3'b100: idA <= idR4;
					3'b101: idA <= idR5;
					3'b110: idA <= idR6;
					3'b111: idA <= idR7;
				endcase
				case(idIRin[8:6])
					3'b000: idB <= idR0;
					3'b001: idB <= idR1;
					3'b010: idB <= idR2;
					3'b011: idB <= idR3;
					3'b100: idB <= idR4;
					3'b101: idB <= idR5;
					3'b110: idB <= idR6;
					3'b111: idB <= idR7;
				endcase
				if (idIRin[5] == 0)
					idImm <= {10'h0, idIRin[5:0]};
				else
					idImm <= {10'h3FF, idIRin[5:0]};				
			end
			5'b1111_x:	//TRAP
			begin
				idCond <= 1'b0;
				idImm <= {8'h0, idIRin[7:0]};
				idEXCout <= 1'b0;
			end
			5'b1101_x:	//EXC
			begin
					idEXCout <= ~clk;
			end
			5'b1001_x:	//NOT + 补充指令  
			begin
				idCond <= 1'b0;
				idEXCout <= 1'b0;
				case(idIRin[5:4])
					2'b11:		//NOT
					begin
						case(idIRin[8:6])
							3'b000: idA <= idR0;
							3'b001: idA <= idR1;
							3'b010: idA <= idR2;
							3'b011: idA <= idR3;
							3'b100: idA <= idR4;
							3'b101: idA <= idR5;
							3'b110: idA <= idR6;
							3'b111: idA <= idR7;
						endcase
					end
					2'b10:		//RRS DPS WPS
					begin
						if (idIRin[5:0] == 6'b100001)	//DPS
							idA <= idPSR;
						else
						begin
							case(idIRin[8:6])
								3'b000: idA <= idR0;
								3'b001: idA <= idR1;
								3'b010: idA <= idR2;
								3'b011: idA <= idR3;
								3'b100: idA <= idR4;
								3'b101: idA <= idR5;
								3'b110: idA <= idR6;
								3'b111: idA <= idR7;
							endcase
						end
					end
					default:	//LS RS NOP
					begin
						case(idIRin[8:6])
							3'b000: idA <= idR0;
							3'b001: idA <= idR1;
							3'b010: idA <= idR2;
							3'b011: idA <= idR3;
							3'b100: idA <= idR4;
							3'b101: idA <= idR5;
							3'b110: idA <= idR6;
							3'b111: idA <= idR7;
						endcase
						idImm <= {12'h0, idIRin[3:0]};
					end
				endcase
			end
			default:
			begin
				idCond <= 1'b0;
				idA <= 16'h0;
				idB <= 16'h0;
				idImm <= 16'h0;
				idEXCout <= 1'b0;
			end
		endcase
		end
		else if (irq == 1'b1)
			idIRout <= 16'h9000;
	end
endmodule
