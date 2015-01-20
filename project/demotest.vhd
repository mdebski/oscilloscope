LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
USE ieee.numeric_std.ALL;
 
ENTITY demotest IS
END demotest;
 
ARCHITECTURE behavior OF demotest IS 
 
    COMPONENT demo
    PORT(
         clk : IN  std_logic;
         btn : IN  std_logic_vector(3 downto 0);
         hsync : OUT  std_logic;
         vsync : OUT  std_logic;
         vout : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;

   signal clk : std_logic := '0';
   signal btn : std_logic_vector(3 downto 0) := "0000";

   signal hsync : std_logic;
   signal vsync : std_logic;
   signal vout : std_logic_vector(7 downto 0);

   constant clk_period : time := 31250 ps;
 
BEGIN
 
   uut: demo PORT MAP (
          clk => clk,
          btn => btn,
          hsync => hsync,
          vsync => vsync,
          vout => vout
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
      btn(3) <= '1';
      wait for clk_period*10;
      btn(3) <= '0';
      wait;
   end process;

END;
