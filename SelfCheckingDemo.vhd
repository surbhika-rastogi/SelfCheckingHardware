library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity NTT_under_test is  --grey to binary code conversion
    port ( a : in std_logic_vector( 3 downto 0 ) ;
            result : out std_logic_vector( 3 downto 0) ) ;
end entity ;
architecture rch1 of NTT_under_test is
begin
   result(3) <= a(3);
	result(2) <= a(3) xor a(2);
	result(1) <= a(3) xor a(2) xor a(1);
	result(0) <= a(3) xor a(2) xor a(1) xor a(0);
end architecture ;





library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SelfCheckingDemo is   
    port (
        clk: in std_logic; --50MHz
        KEY: in std_logic_vector (1 downto 0);
        LEDR: out std_logic_vector (17 downto 0) := ( others => '0' );   
        -- for labsland de-2-115 terasic altera fpga board
		   inp : out std_logic_vector( 3 downto 0 ) := ( others => '0' ) ;
     outp : out std_logic_vector( 3 downto 0 ) := ( others => '0' ) 
    );
end;




architecture behav of SelfCheckingDemo is
    signal a : std_logic_vector( 3 downto 0 ) := ( others => '0' ) ;
    signal result : std_logic_vector( 3 downto 0 ) := ( others => '0' ) ;
    type t_inp_rom is array( 0 to 2**4-1 ) of std_logic_vector(3 downto 0) ;
    constant inp_rom_block : t_inp_rom 
        := (    std_logic_vector(to_unsigned( 0,4)) , 
                std_logic_vector(to_unsigned( 1,4)) , 
                std_logic_vector(to_unsigned( 2,4)) , 
                std_logic_vector(to_unsigned( 3,4)) , 
                std_logic_vector(to_unsigned( 4,4)) , 
                std_logic_vector(to_unsigned( 5,4)) , 
                std_logic_vector(to_unsigned( 6,4)) , 
                std_logic_vector(to_unsigned( 7,4)) , 
                std_logic_vector(to_unsigned( 8,4)) , 
                std_logic_vector(to_unsigned( 9,4)) , 
                std_logic_vector(to_unsigned( 10,4)) , 
                std_logic_vector(to_unsigned( 11,4)) , 
                std_logic_vector(to_unsigned( 12,4)) , 
                std_logic_vector(to_unsigned( 13,4)) , 
                std_logic_vector(to_unsigned( 14,4)) , 
                std_logic_vector(to_unsigned( 15,4)) 
			);
    type t_outp_rom is array( 0 to 2**4-1 ) of std_logic_vector(3 downto 0 ) ;
    constant outp_rom_block : t_outp_rom 
        := ( 
                std_logic_vector(to_unsigned( 0,4)) , 
                std_logic_vector(to_unsigned( 1,4)) , 
                std_logic_vector(to_unsigned( 3,4)) , 
                std_logic_vector(to_unsigned( 2,4)) , 
                std_logic_vector(to_unsigned( 7,4)) , 
                std_logic_vector(to_unsigned( 6,4)) , 
                std_logic_vector(to_unsigned( 4,4)) , 
                std_logic_vector(to_unsigned( 5,4)) , 
                std_logic_vector(to_unsigned( 15,4)) , 
                std_logic_vector(to_unsigned( 14,4)) , 
                std_logic_vector(to_unsigned( 12,4)) , 
                std_logic_vector(to_unsigned( 13,4)) , 
                std_logic_vector(to_unsigned( 8,4)) , 
                std_logic_vector(to_unsigned( 9,4)) , 
                std_logic_vector(to_unsigned( 11,4)) , 
                std_logic_vector(to_unsigned( 10,4)) 
            ) ;
    --signal clk : std_logic := '0' ;
    signal resetn : std_logic := '1' ;
    signal golden_result : std_logic_vector( 2*2-1 downto 0 ) ;
    signal apply_test_flag , check_output_flag : std_logic := '0' ;
begin
    hw_dut : entity work.NTT_under_test(rch1) port map ( a, result ) ;
    resetn <= KEY(0);  
    LEDR(17) <= clk ;
	 
	 inp <= a;
	 outp <= result;
    
    
--    process(CLOCK_50)
--        variable v_count_fast_cycles : integer := 0 ;
--        variable v_slow_down_factor : integer := 4096*4096 ;
--        variable v_slow_down_factor : integer := 2048*2048 ;   
--        variable v_slow_down_factor : integer := 2*2 ;

--Uncomment the 2048*2048 line and comment out 2*2 line For the necessary 
--slow-down needed for visual experience On RemoteFPGA of LabsLand ( I used DE2-115 )
-- In fact slow it down by 4096*4096 ( for almost 1 Hz like freq )
        
---    begin
--        if rising_edge(CLOCK_50) then
--            if ( v_count_fast_cycles < v_slow_down_factor/2 ) then
--                v_count_fast_cycles := v_count_fast_cycles + 1 ;
--            else 
--                clk <= not clk ;
--                v_count_fast_cycles := 0 ;
--            end if ;
--        end if ;    
--    end process ;

    process( clk, resetn)
        variable v_count , v_check_fail : integer := 0 ;
    begin
        if rising_edge( clk ) then
            if resetn = '0' then   -- active low synchronous reset
                v_count := 0 ;
                apply_test_flag <= '1' ;  check_output_flag <= '0' ;
                LEDR(15) <= '1' ;
            elsif ( v_count = 2**4 ) then
                if ( v_check_fail = 0 ) then
                    LEDR(15) <= '0' ;
                end if ;
            elsif ( v_count < 2**4 ) then
                if ( apply_test_flag = '1' ) then
                    a <= inp_rom_block( v_count )(3 downto 0) ;

                    golden_result <= outp_rom_block( v_count ) ;
						  
                    apply_test_flag <= not apply_test_flag ;
                    check_output_flag <= not check_output_flag ;
                elsif ( check_output_flag = '1' ) then
                    if not ( result = golden_result ) then
                        v_check_fail := v_check_fail + 1 ;
                    end if ;
                    v_count := v_count + 1 ;
                    apply_test_flag <= not apply_test_flag ;
                    check_output_flag <= not check_output_flag ;
                end if ;
            end if ;
        end if;
    end process;
end behav;