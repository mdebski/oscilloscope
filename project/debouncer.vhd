library ieee;
use ieee.std_logic_1164.all;

-- If button is pressed produce one-cycle strobe on output,
-- but not more often then once every MAX_COUNT cycles.

entity debouncer is
 generic(
  MAX_COUNT: natural := 1000000
 );
 port(
  btn:  in std_logic;
  clk, rst:  in std_logic;
  output: out std_logic := '0'
 );
end entity debouncer;

architecture counter of debouncer is
 signal count: natural range 1 to MAX_COUNT := 1;
begin process(clk, rst) is begin
 if rst = '1' then
  count <= 1;
 elsif rising_edge(clk) then
  if btn = '1' and count = 1 then
   count <= MAX_COUNT;
   output <= '1';
  else
   if(count > 1) then
    count <= count - 1;
   end if;
   output <= '0';
  end if;
 end if;
end process; end counter;
