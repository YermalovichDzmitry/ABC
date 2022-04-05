module func_1(input logic s0,s1,s2,tl,
tr, output logic la,lb,lc,ra,rb,rc);

	logic s0_hat,s1_hat,s2_hat;

assign s0_hat = ~s2 & ~s0 |
					 s2 & ~s1 & ~s0;
					 
assign s1_hat = ~s2 & ~s1 & ~s0 & ~tl |
					 ~s2 & ~s1 & s0 |
					 ~s2 & s1 & ~s0|
					 s2 & ~s1 & s0;

assign s2_hat = ~s2 & ~s1 & ~s0 & ~tl |
					 s2 & s1 & s0 & tr|
					 s2 & ~s1;
					 
assign la = ~s2 & ~s1 & s0 |
				~s2 & s1;
				
assign lb = ~s2 & s1;

assign lc = ~s2 & s1 & s0;


assign ra = s2 & ~s1|
				s2 & s1 & ~s0;

assign rb = s2 & ~s1 & s0|
				s2 & s1 & ~s0;

assign rc = s2 & s1 & ~s0;			

endmodule

//module func_1(input logic s0,s1,s2,tl,
//tr, output logic s0_hat,s1_hat,s2_hat);
//
//assign s0_hat = ~s2 & ~s0 |
//					 s2 & ~s1 & ~s0;
//					 
//assign s1_hat = ~s2 & ~s1 & ~s0 & ~tl |
//					 ~s2 & ~s1 & s0 |
//					 ~s2 & s1 & ~s0|
//					 s2 & ~s1 & s0;
//
//assign s2_hat = ~s2 & ~s1 & ~s0 & ~tl |
//					 s2 & s1 & s0 & tr|
//					 s2 & ~s1;
//endmodule
