
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY debouncer2_test IS
END debouncer2_test;
 
ARCHITECTURE behavior OF debouncer2_test IS 
 
    COMPONENT debouncer2
    PORT(
         btn : IN  std_logic;
         clk : IN  std_logic;
         rst : IN  std_logic;
         output : OUT  std_logic
        );
    END COMPONENT;
    
   signal btn : std_logic := '0';
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';

   signal output : std_logic;

   constant clk_period : time := 10 ns;
 
BEGIN
 
   uut: debouncer2 PORT MAP (
          btn => btn,
          clk => clk,
          rst => rst,
          output => output
        );

   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   stim_proc: process
begin		
 rst <= '1';
 btn <= '0';
 wait for clk_period*10;
 rst <= '0';      

 btn <= '1';
 wait for clk_period*5;
 assert output = '0';
 wait for clk_period*64;
 assert output = '1';
 
 btn <= not btn;
 wait for clk_period;
 assert output = '1';
 btn <= not btn;
 wait for clk_period;
 assert output = '1';
 btn <= not btn;
 wait for clk_period;
 assert output = '1';
 btn <= not btn;
 wait for clk_period;
 assert output = '1';
 btn <= not btn;
 wait for clk_period;
 assert output = '1';

      wait;
end process;

END;
