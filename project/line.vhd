library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity line is
 port(
  clk, rst, slow_clk: in std_logic;
  btn_inc, btn_dec: in std_logic;
  line_pos: out unsigned(10 downto 0);
  debug: out std_logic_vector(1 downto 0)
 );
end line;

architecture Behavioral of line is
 signal linepos: unsigned(10 downto 0);
 signal inc_deb, dec_deb: std_logic;
 signal inc_strobe, dec_strobe: std_logic;
begin
 line_pos <= linepos;

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
 
 debug(0) <= dec_deb;
 debug(1) <= inc_deb;
 
 process(clk) is begin if rising_edge(clk) then
  if(rst = '1') then
   linepos <= to_unsigned(82, 11); 
  else
   if(inc_strobe = '1' and linepos < 598) then
    if(linepos+8 > 598) then
     linepos <= to_unsigned(598, 11);
    else
     linepos <= linepos + 8;
    end if;
   elsif(dec_strobe = '1' and linepos > 82) then
    if(linepos-8 < 82) then
     linepos <= to_unsigned(82, 11);
    else
     linepos <= linepos - 8;
    end if;
   end if;
  end if;
end if; end process; end Behavioral;