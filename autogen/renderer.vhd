library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity renderer is
 port(
  hcount: in HCOORD;
  vcount: in VCOORD;
  toggle: in std_logic_vector(7 downto 0);
  freq_digits: in DIGIT_ARRAY(3 downto 0);
  dist_digits: in DIGIT_ARRAY(2 downto 0);
  selected: in unsigned(2 downto 0);
  line_pos, line2_pos: in HCOORD;
  state: in STATE_TYPE;
  prescale: in unsigned(2 downto 0);

  output: out std_logic_vector(11 downto 0);
  index: out unsigned(2 downto 0);
  select_mem: out std_logic
 );
end renderer;

architecture Behavioral of renderer is
 signal select_x1, select_x2: HCOORD;
 signal select_y1, select_y2: VCOORD;
begin
 with selected select select_x2 <=
  "1000011100" when "000",
  "1001011011" when "001",
  "1001110001" when "010",
  line_pos + 1 when "011",
  line2_pos + 1 when "100",
  "0000000000" when others;
 with selected select select_y1 <=
  "110110000" when "000",
  "110110000" when "001",
  "110101100" when "010",
  "000000000" when "011",
  "000000000" when "100",
  "000000000" when others;
 with selected select select_x1 <=
  "1000001111" when "000",
  "1001000010" when "001",
  "1001100000" when "010",
  line_pos - 1 when "011",
  line2_pos - 1 when "100",
  "0000000000" when others;
 with selected select select_y2 <=
  "110111001" when "000",
  "110111001" when "001",
  "110111101" when "010",
  "111100000" when "011",
  "111100000" when "100",
  "000000000" when others;
process(hcount, vcount, toggle, line_pos, line2_pos, freq_digits, state, prescale, select_x1, select_x2, select_y1, select_y2) is begin
 index <= "000";
 if (((hcount >= select_x1) and (hcount <= select_x2)) and ((vcount = select_y1) or (vcount = select_y2))) then
  output <= X"00d"; select_mem <= '0';

elsif (((hcount = select_x1) or (hcount = select_x2)) and ((vcount >= select_y1) and (vcount <= select_y2))) then
  output <= X"00d"; select_mem <= '0';

elsif ((hcount = line2_pos) and (vcount >= 0) and (vcount < 0 + 480)) then
 output <= X"00e"; select_mem <= '0';
elsif ((hcount = line_pos) and (vcount >= 0) and (vcount < 0 + 480)) then
 output <= X"00e"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 429) and (vcount < 429 + 16)) then
 if state=EVERY then
 output <= Std_logic_vector(((vcount-429) * 16) + (hcount-609) + 2152); select_mem <= '0';
elsif state=ONCE then
 output <= Std_logic_vector(((vcount-429) * 16) + (hcount-609) + 2664); select_mem <= '0';
elsif state=ONCE_PROBING then
 output <= Std_logic_vector(((vcount-429) * 16) + (hcount-609) + 1896); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-429) * 16) + (hcount-609) + 2408); select_mem <= '0';
end if;
elsif ((hcount >= 579) and (hcount < 579 + 24) and (vcount >= 433) and (vcount < 433 + 8)) then
 if prescale <= 1 then
 output <= Std_logic_vector(((vcount-433) * 24) + (hcount-579) + 1704); select_mem <= '0';
elsif prescale <= 4 then
 output <= Std_logic_vector(((vcount-433) * 24) + (hcount-579) + 1512); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-433) * 24) + (hcount-579) + 1320); select_mem <= '0';
end if;
elsif ((hcount >= 566) and (hcount < 566 + 4) and (vcount >= 440) and (vcount < 440 + 3)) then
 if prescale = 2 or prescale = 5 then
 output <= Std_logic_vector(((vcount-440) * 4) + (hcount-566) + 1296); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-440) * 4) + (hcount-566) + 1308); select_mem <= '0';
end if;
elsif ((hcount >= 558) and (hcount < 558 + 4) and (vcount >= 440) and (vcount < 440 + 3)) then
 if prescale = 0 or prescale = 3 or prescale = 6 then
 output <= Std_logic_vector(((vcount-440) * 4) + (hcount-558) + 1296); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-440) * 4) + (hcount-558) + 1308); select_mem <= '0';
end if;
elsif ((hcount >= 550) and (hcount < 550 + 4) and (vcount >= 440) and (vcount < 440 + 3)) then
 if prescale = 1 or prescale = 4 or prescale = 7 then
 output <= Std_logic_vector(((vcount-440) * 4) + (hcount-550) + 1296); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-440) * 4) + (hcount-550) + 1308); select_mem <= '0';
end if;
elsif ((hcount >= 568) and (hcount < 568 + 8) and (vcount >= 445) and (vcount < 445 + 8)) then
 output <= Std_logic_vector(((vcount-445) * 8) + (hcount-568) + 656 + (64*to_unsigned(to_integer(dist_digits(0)), 12))); select_mem <= '0';
elsif ((hcount >= 560) and (hcount < 560 + 8) and (vcount >= 445) and (vcount < 445 + 8)) then
 output <= Std_logic_vector(((vcount-445) * 8) + (hcount-560) + 656 + (64*to_unsigned(to_integer(dist_digits(1)), 12))); select_mem <= '0';
elsif ((hcount >= 552) and (hcount < 552 + 8) and (vcount >= 445) and (vcount < 445 + 8)) then
 output <= Std_logic_vector(((vcount-445) * 8) + (hcount-552) + 656 + (64*to_unsigned(to_integer(dist_digits(2)), 12))); select_mem <= '0';
elsif ((hcount >= 568) and (hcount < 568 + 8) and (vcount >= 433) and (vcount < 433 + 8)) then
 output <= Std_logic_vector(((vcount-433) * 8) + (hcount-568) + 656 + (64*to_unsigned(to_integer(freq_digits(0)), 12))); select_mem <= '0';
elsif ((hcount >= 560) and (hcount < 560 + 8) and (vcount >= 433) and (vcount < 433 + 8)) then
 output <= Std_logic_vector(((vcount-433) * 8) + (hcount-560) + 656 + (64*to_unsigned(to_integer(freq_digits(1)), 12))); select_mem <= '0';
elsif ((hcount >= 552) and (hcount < 552 + 8) and (vcount >= 433) and (vcount < 433 + 8)) then
 output <= Std_logic_vector(((vcount-433) * 8) + (hcount-552) + 656 + (64*to_unsigned(to_integer(freq_digits(2)), 12))); select_mem <= '0';
elsif ((hcount >= 544) and (hcount < 544 + 8) and (vcount >= 433) and (vcount < 433 + 8)) then
 output <= Std_logic_vector(((vcount-433) * 8) + (hcount-544) + 656 + (64*to_unsigned(to_integer(freq_digits(3)), 12))); select_mem <= '0';
elsif ((hcount >= 528) and (hcount < 528 + 16) and (vcount >= 433) and (vcount < 433 + 8)) then
 output <= Std_logic_vector(((vcount-433) * 16) + (hcount-528) + 528); select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 388) and (vcount < 388 + 16)) then
 if toggle(7) = '1' then
 output <= Std_logic_vector(((vcount-388) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-388) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 412)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "111"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 380)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "111"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 420) and (vcount < 420 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 338) and (vcount < 338 + 16)) then
 if toggle(6) = '1' then
 output <= Std_logic_vector(((vcount-338) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-338) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 362)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "110"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 330)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "110"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 370) and (vcount < 370 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 288) and (vcount < 288 + 16)) then
 if toggle(5) = '1' then
 output <= Std_logic_vector(((vcount-288) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-288) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 312)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "101"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 280)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "101"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 320) and (vcount < 320 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 238) and (vcount < 238 + 16)) then
 if toggle(4) = '1' then
 output <= Std_logic_vector(((vcount-238) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-238) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 262)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "100"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 230)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "100"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 270) and (vcount < 270 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 188) and (vcount < 188 + 16)) then
 if toggle(3) = '1' then
 output <= Std_logic_vector(((vcount-188) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-188) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 212)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "011"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 180)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "011"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 220) and (vcount < 220 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 138) and (vcount < 138 + 16)) then
 if toggle(2) = '1' then
 output <= Std_logic_vector(((vcount-138) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-138) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 162)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "010"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 130)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "010"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 170) and (vcount < 170 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 88) and (vcount < 88 + 16)) then
 if toggle(1) = '1' then
 output <= Std_logic_vector(((vcount-88) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-88) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 112)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "001"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 80)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "001"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 120) and (vcount < 120 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 609) and (hcount < 609 + 16) and (vcount >= 38) and (vcount < 38 + 16)) then
 if toggle(0) = '1' then
 output <= Std_logic_vector(((vcount-38) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-38) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 62)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "000"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (hcount < 85 + 512) and (vcount = 30)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "000"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 82) and (hcount < 82 + 518) and (vcount >= 70) and (vcount < 70 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 84) and (hcount < 84 + 516) and (vcount >= 20) and (vcount < 20 + 2)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 598) and (hcount < 598 + 2) and (vcount >= 20) and (vcount < 20 + 400)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 82) and (hcount < 82 + 2) and (vcount >= 20) and (vcount < 20 + 400)) then
 output <= X"008"; select_mem <= '0';
elsif ((hcount >= 634) and (hcount < 634 + 5) and (vcount = 479)) then
 output <= X"007"; select_mem <= '0';
elsif ((hcount = 639) and (vcount >= 474) and (vcount < 474 + 5)) then
 output <= X"007"; select_mem <= '0';
elsif ((hcount = 0) and (vcount >= 1) and (vcount < 1 + 4)) then
 output <= X"007"; select_mem <= '0';
elsif ((hcount >= 0) and (hcount < 0 + 5) and (vcount = 0)) then
 output <= X"007"; select_mem <= '0';
else
 output <= X"000"; select_mem <= '0';
end if;

end process; end Behavioral;
