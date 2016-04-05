module PCMUX (ifPCout, idPCout, exPCout, memPCout, intPCout,
			  idCond, exCond, memCond, intCond,
			  PCval);
	input [15:0] ifPCout, idPCout, exPCout, memPCout, intPCout;
	input idCond, exCond, memCond, intCond;
	
	output [15:0] PCval;
	
	reg [15:0] PCval;
	
	always @(ifPCout or idPCout or exPCout or memPCout or intPCout or idCond or exCond or memCond or intCond)
	begin
		if (intCond == 1'b1)
			PCval = intPCout;
		else if (memCond == 1'b1)
			PCval = memPCout;
		else if (exCond == 1'b1)
			PCval = exPCout;
		else if (idCond == 1'b1)
			PCval = idPCout;
		else
			PCval = ifPCout;
	end	 
endmodule
