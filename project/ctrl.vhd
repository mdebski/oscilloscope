library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;
use work.common.ALL;

entity ctrl is
 port(
  clk, rst, slow_clk: in std_logic;
  btn: in std_logic_vector(3 downto 0);

  line_pos, line2_pos: out HCOORD;
  line_dist: out unsigned(9 downto 0);
  freq: out unsigned(11 downto 0);
  prescale: out unsigned(2 downto 0);
  change_mode: out std_logic;
  selected: out unsigned(2 downto 0)
 );
end ctrl;

architecture Behavioral of ctrl is
 constant BTN_PREV: integer := 3;
 constant BTN_NEXT: integer := 2;
 constant BTN_DEC: integer := 1;
 constant BTN_INC: integer := 0;
 constant SEL_FREQ: unsigned(2 downto 0) := to_unsigned(0, 3);
 constant SEL_SCALE: unsigned(2 downto 0) := to_unsigned(1, 3);
 constant SEL_MODE: unsigned(2 downto 0) := to_unsigned(2, 3);
 constant SEL_LINE: unsigned(2 downto 0) := to_unsigned(3, 3);
 constant SEL_LINE2: unsigned(2 downto 0) := to_unsigned(4, 3);
 constant SELECTED_MIN: unsigned(2 downto 0) := to_unsigned(0, 3);
 constant SELECTED_MAX: unsigned(2 downto 0) := to_unsigned(4, 3);
 constant LINE_MIN: unsigned(10 downto 0) := to_unsigned(85, 11);
 signal last: std_logic_vector(BTN_PREV downto BTN_NEXT);
 signal sline_pos, sline2_pos: unsigned(8 downto 0);
 signal sselected: unsigned(2 downto 0);
 signal sprescale: unsigned(2 downto 0);
 signal sfreq: unsigned(11 downto 0);
 signal btn_speed: unsigned(6 downto 0);
 constant MAX_BTN_SPEED: unsigned(6 downto 0) := to_unsigned(127, 5);
 signal cnt: unsigned(16 downto 0);
 signal last_slow_clk: std_logic;
begin
 line_pos <= sline_pos + LINE_MIN; line2_pos <= sline2_pos + LINE_MIN;
 prescale <= sprescale; selected <= sselected; freq <= sfreq;
process(clk) is begin if rising_edge(clk) then
 if rst = '1' then
  sline_pos <= to_unsigned(0, 9);
  sline2_pos <= to_unsigned(511, 9);
  change_mode <= '0';
  sselected <= SELECTED_MIN;
  sprescale <= to_unsigned(0, 3);
  sfreq <= to_unsigned(4095, 11);
  cnt <= (others => '0');
  btn_speed <= to_unsigned(1, 5);
 else
  last <= btn(BTN_PREV downto BTN_NEXT);
  last_slow_clk <= slow_clk;
  change_mode <= '0';
  if(sline_pos < sline2_pos) then
   line_dist <= sline2_pos - sline_pos;
  else
   line_dist <= sline_pos - sline2_pos;
  end if;
  if(btn(BTN_PREV) = '1' and last(BTN_PREV) = '0') then
   case sselected is
    when SELECTED_MIN => sselected <= SELECTED_MAX;
    when others => sselected <= sselected - 1;
   end case;
  elsif(btn(BTN_NEXT) = '1' and last(BTN_NEXT) = '0') then
   case sselected is
    when SELECTED_MAX => sselected <= SELECTED_MIN;
    when others => sselected <= sselected + 1;
   end case;
  end if;
  if(slow_clk = '1' and last_slow_clk = '0') then
   cnt <= cnt+1;
   if(cnt(10 downto 0) = "00000000000") then -- repeat button
    if(cnt(14 downto 0) = "000000000000000" and btn_speed < MAX_BTN_SPEED) then -- increase speed
     btn_speed <= btn_speed + 1;
    end if;
    if(btn(BTN_INC) /= btn(BTN_DEC)) then
     if(btn(BTN_INC) = '1') then
      case sselected is
       when SEL_MODE => change_mode <= '1';
       when SEL_FREQ => sfreq <= sfreq + btn_speed;
       when SEL_SCALE => sprescale <= sprescale - 1;
       when SEL_LINE => sline_pos <= sline_pos + btn_speed;
       when SEL_LINE2 => sline2_pos <= sline2_pos + btn_speed;
      end case;
     else
      case sselected is
       when SEL_MODE => change_mode <= '1';
       when SEL_FREQ => sfreq <= sfreq - btn_speed;
       when SEL_SCALE => sprescale <= sprescale + 1;
       when SEL_LINE => sline_pos <= sline_pos - btn_speed;
       when SEL_LINE2 => sline2_pos <= sline2_pos - btn_speed;
      end case;
     end if;
    else
     btn_speed <= to_unsigned(1, 5);
    end if;
   end if;
  end if;
 end if;
end if; end process; end Behavioral;
