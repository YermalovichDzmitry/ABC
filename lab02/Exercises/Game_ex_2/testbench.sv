module testbench(); 
 logic clk, reset;
 logic W, N, S, E, y1, y2, y1_expected, y2_expected;
 logic [31:0] vectornum, errors;
 logic [5:0] testvectors[10000:0];
// инстанцировать тестируемое устройство 
move dut(clk, reset, W, N, S, E, y1, y2); 
// generate clock 
always
 begin
	clk=1; #5; clk=0; #5; 
 end
// на старте теста, загрузите вектора и запустите сброс
initial
 begin
	$readmemb("testWin.tv", testvectors); 
	vectornum = 0; errors = 0; reset = 1; #22; reset = 0; 
 end
// применение тестовых векторов по нарастающему фронту тактового сигнала
always @(posedge clk) 
 begin
	#1; {W, N, S, E, y1_expected, y2_expected} =
		testvectors[vectornum];
 end
always @(negedge clk) 
 if (~reset) begin // skip during reset
	if (y1 !== y1_expected | y2 !== y2_expected) 
	begin  
		$display("Error: inputs = %b", {W, N, S, E});
		$display(" outputs = %b %b (%b %b expected)", y1, y2, y1_expected, y2_expected); 
		errors = errors + 1; 
	end
	else if((y1 === y1_expected & y2 === y2_expected)&(y1 === 1'b1 & y2 === 1'b0))
	begin
		$display("WIN");
	end
	else if((y1 === y1_expected & y2 === y2_expected)&(y1 === 1'b0 & y2 === 1'b1))
	begin
		$display("DIE");
	end
 vectornum = vectornum + 1;
	if (testvectors[vectornum] === 6'bx) begin
		$display("%d tests completed with %d errors", vectornum, errors); 
		//$display("OK");
		$stop;
	end
 end
endmodule
