library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add3 is
 port (
  a: in std_logic_vector(3 downto 0);
  y: out std_logic_vector(3 downto 0)
 );
end add3;

architecture Behavioral of add3 is
begin
 process(a) begin
 if Unsigned(a) < 5 then
  y <= a;
 else
  y <= std_logic_vector(Unsigned(a) + To_unsigned(3, 4));
 end if;
 end process;
end Behavioral;