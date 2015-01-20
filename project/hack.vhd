library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hack is
 port(
  in1, in2, dec: in std_logic;
  output: out std_logic
 );
end hack;

architecture Behavioral of hack is
begin
 with dec select output <=
  in1 when '1',
  in2 when others;
end Behavioral;

