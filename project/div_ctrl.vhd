library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity div_ctrl is
 port(
  clk, rst, slow_clk: in std_logic;
  btn_inc, btn_dec: in std_logic;
  freq: out unsigned(11 downto 0)
 );
end div_ctrl;

architecture Behavioral of div_ctrl is
 signal sfreq: unsigned(11 downto 0);
 signal inc_deb, dec_deb, inc_strobe, dec_strobe: std_logic;
begin
 freq <= sfreq;

 incdeb: entity work.debouncer2 port map (
  clk => slow_clk, rst => rst,
  btn => btn_inc, output => inc_deb
 );
 decdeb: entity work.debouncer2 port map (
  clk => slow_clk, rst => rst,
  btn => btn_dec, output => dec_deb
 );

 imp: entity work.impulser_drv port map (
  clk => clk, rst => rst,
  imp1 => inc_deb, imp2 => dec_deb,
  rstrobe => inc_strobe,
  lstrobe => dec_strobe
 );

 process(clk) is begin if rising_edge(clk) then
  if(rst = '1') then
   sfreq <= to_unsigned(2047, 12);
  else
   if(inc_strobe = '1' and sfreq < 4096 - 16) then
    sfreq <= sfreq + 16;
   elsif(dec_strobe = '1' and sfreq > 16) then
    sfreq <= sfreq - 16;
   end if;
  end if;
end if; end process; end Behavioral;
