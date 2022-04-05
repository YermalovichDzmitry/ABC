module lab2_08(input logic clk,
					input logic reset,
					input logic left,right,
					output logic la,lb,lc,ra,rb,rc);
typedef enum logic [2:0] {S0,S1,S2,S3,S4,S5,S6,S7}
statetype;
	statetype state,nextstate;

	always_ff @(posedge clk,posedge reset)
		if (reset) state <= S0;
		else state <= nextstate;
		
	always_comb
		case (state)
			S0: if(left) nextstate = S1;
				 else if(right) nextstate = S4;
				 else nextstate = S0;
			S1: nextstate = S2;
			S2: nextstate = S3;
			S3: nextstate = S0;
			S4: nextstate = S5;
			S5: nextstate = S6;
			S6: nextstate = S0;
			default: nextstate = S0;
		endcase
	
	assign la = (state==S1);
	assign lb = (state==S2);
	assign lc = (state==S3);
	assign ra = (state==S4);
	assign rb = (state==S5);
	assign rc = (state==S6);
endmodule
