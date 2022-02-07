library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
--use std.env.finish;
 
entity SelfCheckingDemo_tb is
end SelfCheckingDemo_tb;
 
architecture sim of SelfCheckingDemo_tb is
	signal clk : std_logic := '0' ;
  signal bin : std_logic_vector(3 downto 0) := (others => '0');
  signal gray : std_logic_vector(3 downto 0);
  signal key : std_logic_vector (1 downto 0);
  signal led : std_logic_vector (17 downto 0);
 
begin
 
  DUT : entity work.SelfCheckingDemo(behav)
  port map (
      clk => clk,
        KEY 	=> key,
        LEDR 	=> led,
		   inp 	=> gray,
			outp 	=> bin
  );
  
  process begin
    clk <= '0' ;
    for i in 0 to 150 loop
      wait for 20 ps ; clk <= '1' ; wait for 20 ps ; clk <= '0' ;
    end loop ;
    wait ;
  end process ;
  
  process begin
		
    key<="11";
    wait for 200 ps ; key(0) <= '0' ;
	 wait for 30 ps ; key(0) <= '1' ;
    wait for 2000 ps ;
    assert false report "Finishing" severity failure ;
  end process ;
  
  
 
end architecture;