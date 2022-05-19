// controller.sv
//
// This file is for HMC E85A Lab 5.
// Place controller.tv in same computer directory as this file to test your multicycle controller.
//
// Starter code last updated by Ben Bracker (bbracker@hmc.edu) 1/14/21
// - added opcodetype enum
// - updated testbench and hash generator to accomodate don't cares as expected outputs
// Solution code by ________ (________) ________

typedef enum logic[6:0] {r_type_op=7'b0110011, i_type_alu_op=7'b0010011, lw_op=7'b0000011, sw_op=7'b0100011, beq_op=7'b1100011, jal_op=7'b1101111} opcodetype;

module controller(input  logic       clk,
                  input  logic       reset,  
                  input  opcodetype  op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic       Zero,
                  output logic [1:0] ImmSrc,
                  output logic [1:0] ALUSrcA, ALUSrcB,
                  output logic [1:0] ResultSrc, 
                  output logic       AdrSrc,
                  output logic [2:0] ALUControl,
                  output logic       IRWrite, PCWrite, 
                  output logic       RegWrite, MemWrite);
						
logic PCUpdate,Branch, buf_value;
logic [1:0] ALUOp;

aludec  ad(op[5], funct3, funct7b5, ALUOp, ALUControl);

DistinguishImmSrc dist_imm_src(op, ImmSrc);

state_machine st_machine(clk, reset, op, PCUpdate,Branch, 
	RegWrite, MemWrite,IRWrite, 
	ALUSrcA, ALUSrcB, ResultSrc, AdrSrc, ALUOp);

and a1(buf_value, Zero, Branch);
or a2(PCWrite, buf_value, PCUpdate);   
         
endmodule


module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic       funct7b5, 
              input  logic [1:0] ALUOp,
              output logic [2:0] ALUControl);

  logic  RtypeSub;
  assign RtypeSub = funct7b5 & opb5;  // TRUE for R-type subtract instruction

  always_comb
    case(ALUOp)
      2'b00:                ALUControl = 3'b000; // addition
      2'b01:                ALUControl = 3'b001; // subtraction
      default: case(funct3) // R-type or I-type ALU
                 3'b000:  if (RtypeSub) 
                            ALUControl = 3'b001; // sub
                          else          
                            ALUControl = 3'b000; // add, addi
                 3'b010:    ALUControl = 3'b101; // slt, slti
                 3'b110:    ALUControl = 3'b011; // or, ori
                 3'b111:    ALUControl = 3'b010; // and, andi
                 default:   ALUControl = 3'bxxx; // ???
               endcase
    endcase
endmodule



module state_machine(input  logic       clk,
               input  logic       reset,
               input  opcodetype  op,
					output logic PCUpdate, 
					output logic Branch,
               output logic RegWrite, MemWrite,
					output logic IRWrite,
               output logic [1:0] ALUSrcA, ALUSrcB,
					output logic [1:0] ResultSrc, 
               output logic AdrSrc,
					output logic [1:0] ALUOp);

typedef enum logic[3:0] {S0=4'b0000, S1=4'b0001, S2=4'b0010, S3=4'b0011, S4=4'b0100, S5=4'b0101, S6=4'b0110, S7=4'b0111, S8=4'b1000, S9=4'b1001,  S10=4'b1010} statetype;

statetype state, nextstate;

  always @(posedge clk, posedge reset)
    begin
      if (reset) state <= S0;
      else state <= nextstate;
    end

  always_comb
    case (state)
		 S0: nextstate = S1;
	 
		 S1: if (op == lw_op || op == sw_op) nextstate = S2;
			  else if (op == r_type_op) nextstate = S6;
			  else if (op == i_type_alu_op) nextstate = S8;
			  else if (op == jal_op) nextstate = S9;
			  else if (op == beq_op) nextstate = S10;
			  else  nextstate = S1;
	 
		 S2: if (op == lw_op) nextstate = S3;
			  else if (op == sw_op) nextstate = S5;
			  else nextstate = S2;

		 S3: nextstate = S4;
	 
		 S4: nextstate = S0;
	 
		 S5: nextstate = S0;
	 
		 S6: nextstate = S7;
	 
		 S7: nextstate = S0;
	 
		 S8: nextstate = S7;
	 
		 S9: nextstate = S7;
	 
		 S10: nextstate = S0;
	 
		 default: nextstate = S0;
 
    endcase

  assign AdrSrc = (state == S3 || state == S5);
  assign IRWrite = (state == S0);
  assign ALUSrcA[1] = (state == S2 || state == S6 || state == S8 || state == S10);
  assign ALUSrcA[0] = (state == S9 || state == S1);
  assign ALUSrcB[1] = (state == S9 || state == S0);
  assign ALUSrcB[0] = (state == S2  || state == S8 || state == S1);
  assign ALUOp[1] = (state == S6  || state == S8);
  assign ALUOp[0] = (state == S10);
  assign ResultSrc[1] = (state == S0);
  assign ResultSrc[0] = (state == S4);
  assign PCUpdate = (state == S0 || state == S9);
  assign MemWrite = (state == S5);
  assign RegWrite = (state == S4 || state == S7);
  assign Branch = (state == S10);
  
endmodule



module DistinguishImmSrc(input opcodetype  op, output logic [1:0] ImmSrc);

always_comb
    case (op)
	  
	  r_type_op: ImmSrc = 2'bxx;
	  
	  i_type_alu_op: ImmSrc = 2'b00;
	  
	  lw_op: ImmSrc = 2'b00;
	  
     sw_op: ImmSrc =  2'b01;
	  
     beq_op: ImmSrc = 2'b10;
	  
	  jal_op: ImmSrc = 2'b11;
	  
     default: ImmSrc = 2'bxx;
	  
    endcase
  

endmodule





module testbench();

  logic        clk;
  logic        reset;
  
  opcodetype  op;
  logic [2:0] funct3;
  logic       funct7b5;
  logic       Zero;
  logic [1:0] ImmSrc;
  logic [1:0] ALUSrcA, ALUSrcB;
  logic [1:0] ResultSrc;
  logic       AdrSrc;
  logic [2:0] ALUControl;
  logic       IRWrite, PCWrite;
  logic       RegWrite, MemWrite;
  
  logic [31:0] vectornum, errors;
  logic [39:0] testvectors[10000:0];
  
  logic        new_error;
  logic [15:0] expected;
  logic [6:0]  hash;


  // instantiate device to be tested
  controller dut(clk, reset, op, funct3, funct7b5, Zero,
                 ImmSrc, ALUSrcA, ALUSrcB, ResultSrc, AdrSrc, ALUControl, IRWrite, PCWrite, RegWrite, MemWrite);
  
  // generate clock
  always 
    begin
      clk = 1; #5; clk = 0; #5;
    end

  // at start of test, load vectors and pulse reset
  initial
    begin
      $readmemb("controller.tv", testvectors);
      vectornum = 0; errors = 0; hash = 0;
      reset = 1; #22; reset = 0;
    end
	 
  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1; {op, funct3, funct7b5, Zero, expected} = testvectors[vectornum];
    end

  // check results on falling edge of clk
  always @(negedge clk)
    if (~reset) begin // skip cycles during reset
      new_error=0; 

      if ((ImmSrc!==expected[15:14])&&(expected[15:14]!==2'bxx))  begin
        $display("   ImmSrc = %b      Expected %b", ImmSrc,     expected[15:14]);
        new_error=1;
      end
      if ((ALUSrcA!==expected[13:12])&&(expected[13:12]!==2'bxx)) begin
        $display("   ALUSrcA = %b     Expected %b", ALUSrcA,    expected[13:12]);
        new_error=1;
      end
      if ((ALUSrcB!==expected[11:10])&&(expected[11:10]!==2'bxx)) begin
        $display("   ALUSrcB = %b     Expected %b", ALUSrcB,    expected[11:10]);
        new_error=1;
      end
      if ((ResultSrc!==expected[9:8])&&(expected[9:8]!==2'bxx))   begin
        $display("   ResultSrc = %b   Expected %b", ResultSrc,  expected[9:8]);
        new_error=1;
      end
      if ((AdrSrc!==expected[7])&&(expected[7]!==1'bx))           begin
        $display("   AdrSrc = %b       Expected %b", AdrSrc,     expected[7]);
        new_error=1;
      end
      if ((ALUControl!==expected[6:4])&&(expected[6:4]!==3'bxxx)) begin
        $display("   ALUControl = %b Expected %b", ALUControl, expected[6:4]);
        new_error=1;
      end
      if ((IRWrite!==expected[3])&&(expected[3]!==1'bx))          begin
        $display("   IRWrite = %b      Expected %b", IRWrite,    expected[3]);
        new_error=1;
      end
      if ((PCWrite!==expected[2])&&(expected[2]!==1'bx))          begin
        $display("   PCWrite = %b      Expected %b", PCWrite,    expected[2]);
        new_error=1;
      end
      if ((RegWrite!==expected[1])&&(expected[1]!==1'bx))         begin
        $display("   RegWrite = %b     Expected %b", RegWrite,   expected[1]);
        new_error=1;
      end
      if ((MemWrite!==expected[0])&&(expected[0]!==1'bx))         begin
        $display("   MemWrite = %b     Expected %b", MemWrite,   expected[0]);
        new_error=1;
      end

      if (new_error) begin
        $display("Error on vector %d: inputs: op = %h funct3 = %h funct7b5 = %h", vectornum, op, funct3, funct7b5);
        errors = errors + 1;
      end
      vectornum = vectornum + 1;
      hash = hash ^ {ImmSrc&{2{expected[15:14]!==2'bxx}}, ALUSrcA&{2{expected[13:12]!==2'bxx}}} ^ {ALUSrcB&{2{expected[11:10]!==2'bxx}}, ResultSrc&{2{expected[9:8]!==2'bxx}}} ^ {AdrSrc&{expected[7]!==1'bx}, ALUControl&{3{expected[6:4]!==3'bxxx}}} ^ {IRWrite&{expected[3]!==1'bx}, PCWrite&{expected[2]!==1'bx}, RegWrite&{expected[1]!==1'bx}, MemWrite&{expected[0]!==1'bx}};
      hash = {hash[5:0], hash[6] ^ hash[5]};
      if (testvectors[vectornum] === 40'bx) begin 
        $display("%d tests completed with %d errors", vectornum, errors);
	      $display("hash = %h", hash);
        $stop;
      end
    end
endmodule

