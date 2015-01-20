library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity pres_ctrl is
 port(
  clk, rst, slow_clk: in std_logic;
  btn_inc, btn_dec: in std_logic;
  prescale: out unsigned(2 downto 0)
 );
end pres_ctrl;

architecture Behavioral of pres_ctrl is
 signal cnt: unsigned(2 downto 0);
 signal inc_deb, dec_deb: std_logic;
 signal last_inc, last_dec: std_logic;
begin
 prescale <= cnt;
 
 incdeb: entity work.debouncer2 generic map (COUNT => 127, NBIT => 7) port map (
  clk => slow_clk, rst => rst,
  btn => btn_inc, output => inc_deb
 );
 decdeb: entity work.debouncer2 generic map (COUNT => 127, NBIT => 7) port map (
  clk => slow_clk, rst => rst,
  btn => btn_dec, output => dec_deb
 );
 
 process(clk) is begin if rising_edge(clk) then
  if(rst = '1') then
   cnt <= to_unsigned(0, 3);   
  else
   last_inc <= inc_deb;
   last_dec <= dec_deb;
   if(inc_deb = '1' and last_inc = '0') then
    cnt <= cnt + 1;
   elsif(dec_deb = '1' and last_dec = '0') then
    cnt <= cnt - 1;
   end if;
  end if;
 end if; end process;
end Behavioral;

