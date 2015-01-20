----------------------------------------------------------------------------------
-- Company: University of Warsaw
-- Author: Marcin Peczarski
-- 
-- Creation date: 01.02.2011 
-- Modification date: 18.03.2013 
-- Target device: Basys 2, Spartan3E 100K
-- Tool version: ISE 14.4
--
-- Description: PLD lecture - sequential circuits
-- lecture demo
----------------------------------------------------------------------------------

-- A simple frequency divider

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider is
  --                  1
  -- f_out = f_in ----------
  --              2(top + 1)
  -- nbit >= ceil(log2(top+1))
  generic(nbit: natural := 24);
  port(clk_in:  in    std_logic;
       top: in unsigned(nbit - 1 downto 0);
       reset:   in    std_logic;
       clk_out: inout std_logic);
end entity divider;

architecture counter of divider is
  signal cnt: unsigned(nbit - 1 downto 0);
begin
  process(clk_in, reset)
  begin
    if reset = '1' then
      cnt <= (others => '0');
      clk_out <= '0';
    elsif rising_edge(clk_in) then
      if cnt = 0 then
        cnt <= top;
        clk_out <= not clk_out;
      else
        cnt <= cnt - 1;
      end if;
    end if;
  end process;
end architecture counter;