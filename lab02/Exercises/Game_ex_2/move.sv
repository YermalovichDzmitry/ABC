module move(input logic clk,
 input logic reset,
 input logic W, N, S, E,
 output logic y1,y2);
 
typedef enum logic [3:0] {S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15} 
statetype;
	statetype state,nextstate;
	
	always_ff @(posedge clk,posedge reset)
				if(reset) state <= S0;
				else state <= nextstate;
	
	always_comb
		case (state)
					S0: if(E) nextstate = S1;
						 else nextstate = S0;
						 
					S1: if(W) nextstate = S0;
						 else if(S) nextstate = S2;
						 else nextstate = S1;
						 
					S2: if(N) nextstate = S1;
						  else if(W) nextstate = S3;
						  else if(E) nextstate = S4;
						  else nextstate = S2;
						  
					S4: nextstate = S8;
					
					S3: if(E) nextstate = S5;
						 else nextstate = S3;
						 
					S5:if(N) nextstate = S9;
						  else if(W) nextstate = S3;
						  else if(E) nextstate = S6;
						  else nextstate = S5;
						  
					S9:if(W) nextstate = S10;
						 else if(S) nextstate = S5;
						 else nextstate = S9;
						 
					S10:if(E) nextstate = S9;
						 else nextstate = S10;
					
					S6: nextstate = S7;
					
					S7: nextstate = S7;
					
					S8: nextstate = S8;

					default: nextstate = S0;
				endcase
			
	assign y1 = (state == S7);
	assign y2 = (state == S8);
endmodule
	
	
	