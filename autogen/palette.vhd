library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity palette is
 port(
  color_4bit: in std_logic_vector(3 downto 0);
  color_8bit: out std_logic_vector(7 downto 0)
 );
end palette;

architecture Behavioral of palette is
begin
 with color_4bit select color_8bit <=
  X"00" when X"0",
  X"02" when X"1",
  X"03" when X"2",
  X"80" when X"3",
  X"82" when X"4",
  X"e0" when X"5",
  X"e3" when X"6",
  X"49" when X"7",
  X"10" when X"8",
  X"12" when X"9",
  X"90" when X"a",
  X"b6" when X"b",
  X"1c" when X"c",
  X"1f" when X"d",
  X"fc" when X"e",
  X"ff" when X"f",
  X"00" when others;
end Behavioral;
