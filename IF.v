/*
 * 取指模块  
 * PB10011041 王月鹏 
 */

module IF(clk, reset, irq, pause, ifMD, ifPC,
		  ifMA, ifIR, ifNPC, ifPCout);
		
	input clk, reset, irq, pause;
	input [15:0]ifMD;
	input [15:0]ifPC;

	output [15:0]ifMA;
	output [15:0]ifIR;
	output [15:0]ifNPC;
	output [15:0]ifPCout;
	
	reg [15:0]ifMA;
	reg [15:0]ifIR;
	reg [15:0]ifNPC;
	reg [15:0]ifPCout;
	
	always @(posedge clk)
	begin
		if (irq == 1'b1)
		begin
			ifPCout <= ifPC + 16'h0001;
			ifMA <= ifPC;
			ifIR <= ifMD;
			ifNPC <= ifPC;
		end
		else
		begin
			if (pause == 1'b0)
			begin
				ifMA <= ifPC;
				ifIR <= ifMD;
				ifNPC <= ifPC;
				ifPCout <= ifPC + 16'h0001;
			end
		end
	end
endmodule
