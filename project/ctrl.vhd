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
  selected: out unsigned(2 downto 0)
 );
end ctrl;

architecture Behavioral of ctrl is
 constant BTN_LEFT: integer := 0;
 constant BTN_RIGHT: integer := 1;
 constant BTN_DOWN: integer := 2;
 constant BTN_UP: integer := 3;
 constant SEL_MODE: unsigned(2 downto 0) := to_unsigned(0, 3);
 constant SEL_FREQ: unsigned(2 downto 0) := to_unsigned(1, 3);
 constant SEL_SCALE: unsigned(2 downto 0) := to_unsigned(2, 3);
 constant SEL_LINE: unsigned(2 downto 0) := to_unsigned(3, 3);
 constant SEL_LINE2: unsigned(2 downto 0) := to_unsigned(4, 3);
 constant LINE_MIN: unsigned(10 downto 0) := to_unsigned(82, 11);
 constant LINE_MAX: unsigned(10 downto 0) := to_unsigned(598, 11);
 constant SELECTED_MIN: unsigned(2 downto 0) := to_unsigned(0, 3);
 constant SELECTED_MAX: unsigned(2 downto 0) := to_unsigned(4, 3);
 constant FREQ_MAX: unsigned(11 downto 0) := to_unsigned(4095, 11);
 signal last: std_logic_vector(3 downto 0);
 signal sline_pos, sline2_pos: unsigned(10 downto 0);
 signal sselected: unsigned(2 downto 0);
 signal sprescale: unsigned(2 downto 0);
 signal sfreq: unsigned(11 downto 0);
begin
 line_pos <= sline_pos; line2_pos <= sline2_pos; prescale <= sprescale; selected <= sselected; freq <= sfreq;
process(clk) is begin if rising_edge(clk) then 
 if rst = '1' then
  sline_pos <= LINE_MIN;
  sline2_pos <= LINE_MAX;
  change_mode <= '0';
  sselected <= SELECTED_MIN;
  sprescale <= to_unsigned(0, 3); 
  sfreq <= FREQ_MAX;  
 else
  last <= btn;
  change_mode <= '0';
  if(btn(BTN_LEFT) = '1' and last(BTN_LEFT) = '0') then
   case sselected is
    when SELECTED_MIN => sselected <= SELECTED_MAX;
    when others => sselected <= sselected - 1;
   end case;
  elsif(btn(BTN_RIGHT) = '1' and last(BTN_RIGHT) = '0') then
   case sselected is
    when SELECTED_MAX => sselected <= SELECTED_MIN;
    when others => sselected <= sselected + 1;
   end case;
  end if;
  if(btn(BTN_UP) = '1' and last(BTN_UP) = '0') then
   case sselected is
    when SEL_MODE => change_mode <= '1';
    when SEL_FREQ => sfreq <= sfreq + 1;
    when SEL_SCALE => sprescale <= sprescale + 1;
    when SEL_LINE => sline_pos <= sline_pos + 1;
    when SEL_LINE2 => sline2_pos <= sline2_pos + 1;
   end case;
  elsif(btn(BTN_DOWN) = '1' and last(BTN_DOWN) = '0') then
   case sselected is
    when SEL_MODE => change_mode <= '1';
    when SEL_FREQ => sfreq <= sfreq - 1;
    when SEL_SCALE => sprescale <= sprescale - 1;
    when SEL_LINE => sline_pos <= sline_pos - 1;
    when SEL_LINE2 => sline2_pos <= sline2_pos - 1;
   end case;
  end if;
 end if;
end if; end process; end Behavioral;

