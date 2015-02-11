library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity ctrl is
 port(
  clk, rst: in std_logic;
  btn: in std_logic_vector(3 downto 0);
  
  line_pos, line2_pos: out unsigned(10 downto 0);
  freq: out unsigned(11 downto 0);
  prescale: out unsigned(2 downto 0);
  change_mode: out std_logic;
  selected: out unsigned(3 downto 0)
 );
end ctrl;

architecture Behavioral of ctrl is

begin


end Behavioral;

