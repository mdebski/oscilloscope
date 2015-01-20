library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

-- Change state only if was stable for last COUNT cycles.

entity debouncer2 is
 generic(
  COUNT: natural := 10;
  NBIT: natural := 4
 );
 port(
  btn:  in std_logic;
  clk, rst:  in std_logic;
  output: out std_logic
 );
end entity debouncer2;

architecture counter of debouncer2 is
 signal cnt: unsigned(NBIT-1 downto 0);
 signal state: std_logic;
begin
 output <= state;
 process(clk, rst) is begin if rising_edge(clk) then
  if rst = '1' then
   cnt <= to_unsigned(COUNT, NBIT);
   state <= btn;
  elsif cnt = 0 then
   state <= not state;
   cnt <= to_unsigned(COUNT, NBIT);
  elsif btn /= state then
   cnt <= cnt - 1;
  end if;
 end if; end process;
end counter;
