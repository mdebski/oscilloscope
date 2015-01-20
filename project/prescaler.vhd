
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity prescaler is
 port(
  clk, rst: in std_logic;
  scale: in unsigned(2 downto 0);
  clk_out: out std_logic
 );
 type TOPS_TYPE is ARRAY(0 to 7) of unsigned(23 downto 0);
 constant tops: TOPS_TYPE := (
  X"000000",
  X"000004",
  X"000031",
  X"0001f3",
  X"001387",
  X"00c34f",
  X"07a11f",
  X"4c4b3f"
 );
end prescaler;

architecture Behavioral of prescaler is
 signal top: unsigned(23 downto 0);
 signal scale_is_zero, pre_clk: std_logic;
begin
 divider: entity work.divider PORT MAP(
		clk_in => clk,
		top => top,
		reset => rst,
		clk_out => pre_clk
	);
 
 with scale select scale_is_zero <=
  '1' when "000",
  '0' when others;
 with scale select top <=
  X"000000" when "000",
  X"000004" when "001",
  X"000031" when "010",
  X"0001f3" when "011",
  X"001387" when "100",
  X"00c34f" when "101",
  X"07a11f" when "110",
  X"4c4b3f" when "111",
  X"000000" when others;

 hack: entity work.hack PORT MAP(
  in1 => clk,
  in2 => pre_clk,
  dec => scale_is_zero,
  output => clk_out
 );
end Behavioral;

