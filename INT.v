/*
 * �ж�ģ��   
 * PB10011056 ����ΰ  
 */

//interrupt module
module INT (intMDin,clk,reset,int_r,intPSR,intR6,intPC,intEXC,//input				
				intNPC,intMAout,intMDout,rd,we,int_r_out,flag,intR6out, intPMout, phase); //output
	input clk,reset,int_r,intEXC;
	input[15:0] intPSR,intR6,intMDin,intPC;
	output rd,we,int_r_out,flag;
	output[15:0] intNPC,intMAout,intMDout,intR6out;
	output intPMout;
	output [2:0] phase;
	reg rd,we,int_r_out;	
	reg[15:0] intMDout,intNPC,intMAout,intR6out;
	reg[2:0] phase;
	reg	flag;
	reg intPMout;


	always @(intPSR or intR6 or intPC or phase or int_r or reset or intEXC)
	begin
		if(reset)
			begin
			flag<=1'b0;
			intMAout <= 16'h0;
			intMDout <= 16'h0;
			we<=1'b0;
			rd<=1'b0;
			end
		else
		begin
		if(int_r==1'b1)
		case(phase[2:0])
			3'b001: //save PSR
			begin
				intMAout <= intR6;
				intMDout<=intPSR;
				we<=1'b1; 
				rd<=1'b0;
				flag <= 1'b0; 				
			end
			3'b010://save pc
			begin
				intMAout<=intR6 - 16'h1;
				intMDout<=intPC - 16'h4;
				we<=1'b1;  
				rd<=1'b0;
				flag<=1'b0;						
			end
			3'b011: //read address of interrupt service routine
			begin
				if (intEXC == 1'b0)
					intMAout<=16'h0040;
				else
					intMAout<=16'h0044;
				intMDout<=16'h0;
				rd<=1'b1; 
				we<=1'b0;
				flag <= 1'b1;			
			end
			3'b100:
			begin
				intMAout<=16'h0;
				intMDout<=16'h0;
				rd<=1'b0; 
				we<=1'b0;
				flag<=1'b1;	
			end
			3'b101:
			begin
				intMAout<=16'h0;
				intMDout<=16'h0;
				rd<=1'b0; 
				we<=1'b0;
				flag<=1'b0;
			end	
			default:
			begin
				intMAout<=16'h0;
				intMDout<=16'h0;
				rd<=1'b0; 
				we<=1'b0;
				flag<=1'b0;
			end
		endcase
		else
		begin
				intMAout<=16'h0;
				intMDout<=16'h0;
				rd<=1'b0; 
				we<=1'b0;
				flag<=1'b0;
		end
		end
	end

	always @(posedge clk)
	begin
		if (phase != 3'b100)
			intR6out <= intR6;
		else // if (phase == 3'b100)
			intR6out <= intR6 - 16'h2;
	end
	
	always @(posedge clk)
	begin
		if(reset)
			begin
			phase <= 3'b000;	
			end
		else
		begin
		if(int_r==1'b1)
		case(phase[2:0])
			3'b000:
			begin
				phase<=3'b001;
			end
			3'b001:
			begin		
				phase<=3'b010;
				int_r_out<=1'b0;
				intPMout <= 1'b0;
			end
			3'b010:
			begin
				phase<=3'b011;
				int_r_out<=1'b0;
			end
			3'b011:
			begin
				intNPC<=intMDin;			
				phase<=3'b100;
				int_r_out<=1'b0;
			end
			3'b100:
			begin
				phase<=3'b101;
				int_r_out<=1'b0;		
			end
			3'b101:
			begin			
				phase<=3'b000;
				int_r_out<=1'b1;
			end
			default:
			begin
				phase <= 3'b111;
				int_r_out<=1'b0;
			end
		endcase
		end
	end
endmodule
