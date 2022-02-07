module SelfCheckingDemo_tb ;
	reg clk ;	reg [3:0] KEY ;
 wire [9:0] LEDR;
	
	SelfCheckingDemo dut( clk, KEY, LEDR );
	
	
	always #20 clk = ~clk ; 
	
	initial begin
		$dumpvars();
	
		clk = 0;
		KEY[1] = 0;
		KEY[0] = 1;
		#200 KEY[0] = 0;
		#30 KEY[0] = 1;
		
		#8000 $stop;
		@( negedge LEDR[7] ) $display(" Success !!");
	end
	
	
endmodule
