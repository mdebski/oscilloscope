library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- given clk produces four phases of two times slower clock.
entity progclkgen is
 port(
  clk, rst: in std_logic;
  clk0, clk90, clk180, clk270: out std_logic
 );
end progclkgen;

architecture Behavioral of progclkgen is
 signal notclk: std_logic;
 signal c0, c90: std_logic;
 
begin
 clk0 <= c0;
 clk90 <= c90;
 clk180 <= not c0;
 clk270 <= not c90;
 notclk <= not clk;
 process(clk, rst) begin
  if rst = '1' then
   c0 <= '0';
  elsif rising_edge(clk) then
    c0 <= not c0;
  end if;
 end process;
 process(notclk, rst) begin
   if rst = '1' then
   c90 <= '1';
  elsif rising_edge(notclk) then
    c90 <= not c90;
  end if;
 end process;
end Behavioral;

