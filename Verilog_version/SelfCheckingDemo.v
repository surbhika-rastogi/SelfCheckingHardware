module NTT_under_test ( input [4-1:0] a,
 output [4-1 : 0] result ) ;
 
    assign result[3] = a[3];
    assign result[2] = a[3] ^ a[2];
	assign result[1] = a[3] ^ a[2] ^ a[1];
	assign result[0] = a[3] ^ a[2] ^ a[1] ^ a[0];
endmodule


module SelfCheckingDemo ( input CLOCK_50 , input [3:0] KEY ,output reg [9:0] LEDR ) ;
 localparam width_dut_inp=4 ;
 localparam width_dut_outp=4 ;
 localparam n_tv = 2**width_dut_inp ; // number of test vectors
 reg [width_dut_inp-1 : 0] dut_inp = 0 ;
 wire [width_dut_outp-1 : 0] dut_outp ;
 reg [width_dut_inp-1 : 0] inp_rom_block [0 : n_tv-1 ] ;
 initial begin
 $readmemh("file_inp_rom_bits.hex", inp_rom_block ) ;
 end
 reg [width_dut_outp-1 : 0] outp_rom_block [0 : n_tv-1 ] ;
 initial begin
 $readmemh("file_outp_rom_bits.hex", outp_rom_block ) ;
 end
 
 wire clk , resetn ;
 reg [width_dut_outp-1 : 0] golden_result = 0 ;
 reg apply_test_flag = 1 ;
 reg check_output_flag = 0 ;

 NTT_under_test hw_dut ( dut_inp[3:0] , dut_outp ) ;

 assign resetn = KEY[0];
 always @(*) LEDR[9] = clk ;
 always @(*) begin
 LEDR[3:0] = dut_outp ;
 end

  //localparam log2_slow_down_factor = 25 ; // for labsland remote fpga ( Hz freq )
 localparam log2_slow_down_factor = 2 ; // for modelsim simulation
 reg [log2_slow_down_factor-1 : 0] k_bit_counter = 0 ;
 assign clk = k_bit_counter[ log2_slow_down_factor-1 ] ;
 
 
 always @(posedge CLOCK_50) begin
	k_bit_counter = k_bit_counter + 1 ;
 end

 integer v_count=0;
 reg v_check_fail=0 ;
 
 always @( posedge clk , negedge resetn ) begin
 
	if ( resetn == 0 ) begin //asynchronous active low
			LEDR[7] <= 1;
			apply_test_flag = 1;
			check_output_flag = 0;
			v_count = 0;
			v_check_fail = 0;
		end
		
	else if ( v_count == n_tv ) begin
		if ( v_check_fail == 0 ) begin
			LEDR[7] <= 0 ;
		end
	end 
	else if ( v_count < n_tv ) begin
		if ( apply_test_flag == 1 ) begin
			$display( "applying test vector" ) ;
			dut_inp <= inp_rom_block[ v_count ] ;
 
			golden_result <= outp_rom_block[ v_count ] ;
			apply_test_flag <= ~ apply_test_flag ;
			check_output_flag <= ~ check_output_flag ;
		end 
		else if ( check_output_flag == 1 ) begin
			$display( "checking result of applied test" ) ;
			if ( dut_outp != golden_result ) begin
				v_check_fail = v_check_fail + 1 ;
			end
			v_count = v_count + 1 ;
			apply_test_flag <= ~ apply_test_flag ;
			check_output_flag <= ~ check_output_flag ;
		end
	end
 end
endmodule