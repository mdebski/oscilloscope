library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dpalette is
 port(
  data: in std_logic_vector(7 downto 0);
  color_8bit: out std_logic_vector(7 downto 0);
  index: in unsigned(2 downto 0);
  neg: in std_logic
 );
end dpalette;

architecture Behavioral of dpalette is
 signal binval: std_logic;
begin
 binval <= data(to_integer(index)) xor neg;
 with binval select color_8bit <=
  X"1c" when '1',
  X"00" when others;
end Behavioral;
