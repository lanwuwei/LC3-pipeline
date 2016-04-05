/*
 * ÅÔÂ·Ä£¿é  
 * PB10011056 À¼ÎäÎ° 
 */

	//forwarding----fd
	module FD(_idexA,_idexB,idexIR,exmemIR,memwbIR,exmemALUout,memwbDataout,_fd_A,_fd_B);
	input[15:0] _idexA,_idexB,idexIR,exmemIR,memwbIR,exmemALUout,memwbDataout;
	output[15:0] _fd_A,_fd_B;
	reg[15:0] _fd_A,_fd_B; //_fd_A(SR1),_fd_B(SR2)
	always @(_idexA or _idexB or idexIR or exmemIR or memwbIR or exmemALUout or memwbDataout)
	begin
		if((exmemIR[13:12]==2'b10 || exmemIR[15:12]==4'b0001 || exmemIR[15:12]==4'b0101 || (exmemIR[15:12]==4'b1001 && exmemIR[5:0]!=6'b100010 && exmemIR[5:0]!=6'b000000))&&
			(memwbIR[13:12]==2'b10 || memwbIR[15:12]==4'b0001 || memwbIR[15:12]==4'b0101 || (memwbIR[15:12]==4'b1001 && memwbIR[15:12]!=6'b100010 && exmemIR[5:0]!=6'b000000)))
			begin
				if((idexIR[15:12]==4'b0001 && idexIR[5]==0) || (idexIR[15:12]==4'b0101 && idexIR[5]==0)) //instruction with two operands such as SR1 and SR2
					begin
					if(idexIR[8:6]==exmemIR[11:9])
							_fd_A<=exmemALUout;
					else if(idexIR[8:6]!=exmemIR[11:9] && idexIR[8:6]==memwbIR[11:9])
							_fd_A<=memwbDataout;
					else
							_fd_A<=_idexA;
					if(idexIR[2:0]==exmemIR[11:9])
							_fd_B<=exmemALUout;
					else if(idexIR[2:0]!=exmemIR[11:9] && idexIR[2:0]==memwbIR[11:9])
							_fd_B<=memwbDataout;					
					else
							_fd_B<=_idexB;
					end
				else if(idexIR[15:12]==4'b0111) //STR instruction contains SR and BaseR
					begin
					if(idexIR[11:9]==exmemIR[11:9])
							_fd_A<=exmemALUout;
					else if(idexIR[11:9]!=exmemIR[11:9] && idexIR[11:9]==memwbIR[11:9])
							_fd_A<=memwbDataout;
					else
							_fd_A<=_idexA;
					if(idexIR[8:6]==exmemIR[11:9])
							_fd_B<=exmemALUout;
					else if(idexIR[8:6]!=exmemIR[11:9] && idexIR[8:6]==memwbIR[11:9])
							_fd_B<=memwbDataout;
					else
							_fd_B<=_idexB;							
					end
				else if(idexIR[14:12]==3'b011) //ST and STI instructions
					begin
					if(idexIR[11:9]==exmemIR[11:9])
							begin
							_fd_A<=exmemALUout;
							_fd_B<=_idexB;
							end
					else if(idexIR[11:9]!=exmemIR[11:9] && idexIR[11:9]==memwbIR[11:9])
							begin
							_fd_A<=memwbDataout;
							_fd_B<=_idexB;
							end
					else
							begin
							_fd_A<=_idexA;
							_fd_B<=_idexB;
							end
					end
				else if((idexIR[15:12]==4'b1001 && idexIR[5:0]!=6'b100001) || idexIR[14:12]==3'b100 || idexIR[15:12]==4'b0110
							|| (idexIR[15:12]==4'b0101 && idexIR[5]==1) || (idexIR[15:12]==4'b0001 && idexIR[5]==1))
					begin //instruction such as ADD(I),AND(I),JMP,JSRR,LDR and NOT has only one SR.
					if(idexIR[8:6]==exmemIR[11:9])
							begin
							_fd_A<=exmemALUout;
							_fd_B<=_idexB;
							end
					else if(idexIR[8:6]!=exmemIR[11:9] && idexIR[8:6]==memwbIR[11:9])
							begin
							_fd_A<=memwbDataout;
							_fd_B<=_idexB;
							end
					else
							begin
							_fd_A<=_idexA;
							_fd_B<=_idexB;
							end
					end
				else
					begin
					_fd_A<=_idexA;
					_fd_B<=_idexB;
					end
			end
		else if((exmemIR[13:12]==2'b10 || exmemIR[15:12]==4'b0001 || exmemIR[15:12]==4'b0101 || (exmemIR[15:12]==4'b1001 && exmemIR[5:0]!=6'b100010 && exmemIR[5:0]!=6'b000000))&&
			~(memwbIR[13:12]==2'b10 || memwbIR[15:12]==4'b0001 || memwbIR[15:12]==4'b0101 || (memwbIR[15:12]==4'b1001 && memwbIR[15:12]!=6'b100010 && exmemIR[5:0]!=6'b000000)))
			begin
				if((idexIR[15:12]==4'b0001 && idexIR[5]==0) || (idexIR[15:12]==4'b0101 && idexIR[5]==0)) //instruction with two operands such as SR1 and SR2
					begin
					if(idexIR[8:6]==exmemIR[11:9])
							_fd_A<=exmemALUout;
					else
							_fd_A<=_idexA;
					if(idexIR[2:0]==exmemIR[11:9])
							_fd_B<=exmemALUout;					
					else
							_fd_B<=_idexB;
					end
				else if(idexIR[15:12]==4'b0111) //STR instruction contains SR and BaseR
					begin
					if(idexIR[11:9]==exmemIR[11:9])
							_fd_A<=exmemALUout;
					else
							_fd_A<=_idexA;
					if(idexIR[8:6]==exmemIR[11:9])
							_fd_B<=exmemALUout;
					else
							_fd_B<=_idexB;							
					end	
				else if(idexIR[14:12]==3'b011) //ST and STI instructions
					begin
					if(idexIR[11:9]==exmemIR[11:9])
							begin
							_fd_A<=exmemALUout;
							_fd_B<=_idexB;
							end
					else
							begin
							_fd_A<=_idexA;
							_fd_B<=_idexB;
							end
					end	
				else if((idexIR[15:12]==4'b1001 && idexIR[5:0]!=6'b100001) || idexIR[14:12]==3'b100 || idexIR[15:12]==4'b0110
							|| (idexIR[15:12]==4'b0101 && idexIR[5]==1) || (idexIR[15:12]==4'b0001 && idexIR[5]==1))
					begin //instruction such as ADD(I),AND(I),JMP,JSRR,LDR and NOT has only one SR.
					if(idexIR[8:6]==exmemIR[11:9])
							begin
							_fd_A<=exmemALUout;
							_fd_B<=_idexB;
							end
					else
							begin
							_fd_A<=_idexA;
							_fd_B<=_idexB;
							end
					end
				else
					begin
					_fd_A<=_idexA;
					_fd_B<=_idexB;
					end	
			end
		else if(~(exmemIR[13:12]==2'b10 || exmemIR[15:12]==4'b0001 || exmemIR[15:12]==4'b0101 || (exmemIR[15:12]==4'b1001 && exmemIR[5:0]!=6'b100010 && exmemIR[5:0]!=6'b000000))&&
			(memwbIR[13:12]==2'b10 || memwbIR[15:12]==4'b0001 || memwbIR[15:12]==4'b0101 || (memwbIR[15:12]==4'b1001 && memwbIR[15:12]!=6'b100010 && exmemIR[5:0]!=6'b000000)))	
			begin
				if((idexIR[15:12]==4'b0001 && idexIR[5]==0) || (idexIR[15:12]==4'b0101 && idexIR[5]==0)) //instruction with two operands such as SR1 and SR2
					begin
					if(idexIR[8:6]==memwbIR[11:9])
							_fd_A<=memwbDataout;
					else
							_fd_A<=_idexA;
					if(idexIR[2:0]==memwbIR[11:9])
							_fd_B<=memwbDataout;					
					else
							_fd_B<=_idexB;
					end
				else if(idexIR[15:12]==4'b0111) //STR instruction contains SR and BaseR
					begin
					if(idexIR[11:9]==memwbIR[11:9])
							_fd_A<=memwbDataout;
					else
							_fd_A<=_idexA;
					if(idexIR[8:6]==memwbIR[11:9])
							_fd_B<=memwbDataout;
					else
							_fd_B<=_idexB;							
					end
				else if(idexIR[14:12]==3'b011) //ST and STI instructions
					begin
					if(idexIR[11:9]==memwbIR[11:9])
							begin
							_fd_A<=memwbDataout;
							_fd_B<=_idexB;
							end
					else
							begin
							_fd_A<=_idexA;
							_fd_B<=_idexB;
							end
					end
				else if((idexIR[15:12]==4'b1001 && idexIR[5:0]!=6'b100001) || idexIR[14:12]==3'b100 || idexIR[15:12]==4'b0110
							|| (idexIR[15:12]==4'b0101 && idexIR[5]==1) || (idexIR[15:12]==4'b0001 && idexIR[5]==1))
					begin //instruction such as ADD(I),AND(I),JMP,JSRR,LDR and NOT has only one SR.
					if(idexIR[8:6]==memwbIR[11:9])
							begin
							_fd_A<=memwbDataout;
							_fd_B<=_idexB;
							end
					else
							begin
							_fd_A<=_idexA;
							_fd_B<=_idexB;
							end
					end
				else
					begin
					_fd_A<=_idexA;
					_fd_B<=_idexB;
					end
			end	
		else			
			begin
			_fd_A<=_idexA;
			_fd_B<=_idexB;
			end
	end			
	endmodule