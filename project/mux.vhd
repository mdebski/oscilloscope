library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
 port(
  in1, in2: in std_logic_vector(7 downto 0);
  sel: in std_logic;
  output: out std_logic_vector(7 downto 0)
 );
end mux;

architecture Behavioral of mux is
begin
 with sel select output <=
  in1 when '0',
  in2 when '1',
  "00000000" when others;
end Behavioral;

