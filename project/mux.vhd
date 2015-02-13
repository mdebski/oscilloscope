library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
 port(
  in1, in2: in std_logic_vector(7 downto 0);
  sel, blank: in std_logic;
  
  output: out std_logic_vector(7 downto 0)
 );
end mux;

architecture Behavioral of mux is
 signal dec: std_logic_vector(1 downto 0);
begin
 dec(0) <= sel;
 dec(1) <= blank;
 with dec select output <=
  in1 when "00",
  in2 when "10",
  "00000000" when others;
end Behavioral;

