library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity renderer is
 port(
  hcount, vcount: in unsigned(10 downto 0);
  toggle: in std_logic_vector(7 downto 0);
  freq_digits: in DIGIT_ARRAY(3 downto 0);
  selected: in unsigned(3 downto 0);
  line_pos: in unsigned(10 downto 0);
  line2_pos: in unsigned(10 downto 0);
  state: in STATE_TYPE;
  prescale: in unsigned(2 downto 0);

  output: out std_logic_vector(11 downto 0);
  index: out unsigned(2 downto 0);
  select_mem: out std_logic
 );
end renderer;

architecture Behavioral of renderer is
 signal select_x1, select_x2, select_y1, select_y2: unsigned(10 downto 0);
begin
 with selected select select_x2 <=
  "01001110010" when X"0",
  "01000100001" when X"1",
  "01001011100" when X"2",
  line_pos + 3 when X"3",
  line2_pos + 3 when X"4",
  "00000000000" when others;
 with selected select select_y1 <=
  "00110100100" when X"0",
  "00110101000" when X"1",
  "00110101000" when X"2",
  "00000000000" when X"3",
  "00000000000" when X"4",
  "00000000000" when others;
 with selected select select_x1 <=
  "01001100000" when X"0",
  "01000001111" when X"1",
  "01001000010" when X"2",
  line_pos - 1 when X"3",
  line2_pos - 1 when X"4",
  "00000000000" when others;
 with selected select select_y2 <=
  "00110110110" when X"0",
  "00110110010" when X"1",
  "00110110010" when X"2",
  "00111100001" when X"3",
  "00111100001" when X"4",
  "00000000000" when others;
process(hcount, vcount, toggle, line_pos, freq_digits, state, prescale) is begin
 index <= "000";
 if (((hcount = select_x1) or (vcount = select_x2)) and ((hcount = select_y1) or (vcount = select_y1))) then
  output <= X"00d"; select_mem <= '0';

elsif ((hcount >= line2_pos) and (vcount >= 0) and (hcount < line2_pos + 2) and (vcount < 0 + 480)) then
 output <= X"00e"; select_mem <= '0'; 
elsif ((hcount >= line_pos) and (vcount >= 0) and (hcount < line_pos + 2) and (vcount < 0 + 480)) then
 output <= X"00e"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 421) and (hcount < 609 + 16) and (vcount < 421 + 16)) then
 if state=EVERY then
 output <= Std_logic_vector(((vcount-421) * 16) + (hcount-609) + 2152); select_mem <= '0';
elsif state=ONCE then
 output <= Std_logic_vector(((vcount-421) * 16) + (hcount-609) + 2664); select_mem <= '0';
elsif state=ONCE_PROBING then
 output <= Std_logic_vector(((vcount-421) * 16) + (hcount-609) + 1896); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-421) * 16) + (hcount-609) + 2408); select_mem <= '0';
end if;
elsif ((hcount >= 579) and (vcount >= 425) and (hcount < 579 + 24) and (vcount < 425 + 8)) then
 if prescale <= 1 then
 output <= Std_logic_vector(((vcount-425) * 24) + (hcount-579) + 1704); select_mem <= '0';
elsif prescale <= 4 then
 output <= Std_logic_vector(((vcount-425) * 24) + (hcount-579) + 1512); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-425) * 24) + (hcount-579) + 1320); select_mem <= '0';
end if;
elsif ((hcount >= 566) and (vcount >= 432) and (hcount < 566 + 4) and (vcount < 432 + 3)) then
 if prescale = 2 or prescale = 5 then
 output <= Std_logic_vector(((vcount-432) * 4) + (hcount-566) + 1296); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-432) * 4) + (hcount-566) + 1308); select_mem <= '0';
end if;
elsif ((hcount >= 558) and (vcount >= 432) and (hcount < 558 + 4) and (vcount < 432 + 3)) then
 if prescale = 0 or prescale = 3 or prescale = 6 then
 output <= Std_logic_vector(((vcount-432) * 4) + (hcount-558) + 1296); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-432) * 4) + (hcount-558) + 1308); select_mem <= '0';
end if;
elsif ((hcount >= 550) and (vcount >= 432) and (hcount < 550 + 4) and (vcount < 432 + 3)) then
 if prescale = 1 or prescale = 4 or prescale = 7 then
 output <= Std_logic_vector(((vcount-432) * 4) + (hcount-550) + 1296); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-432) * 4) + (hcount-550) + 1308); select_mem <= '0';
end if;
elsif ((hcount >= 568) and (vcount >= 425) and (hcount < 568 + 8) and (vcount < 425 + 8)) then
 output <= Std_logic_vector(((vcount-425) * 8) + (hcount-568) + 656 + (64*to_unsigned(to_integer(freq_digits(0)), 12))); select_mem <= '0';
elsif ((hcount >= 560) and (vcount >= 425) and (hcount < 560 + 8) and (vcount < 425 + 8)) then
 output <= Std_logic_vector(((vcount-425) * 8) + (hcount-560) + 656 + (64*to_unsigned(to_integer(freq_digits(1)), 12))); select_mem <= '0';
elsif ((hcount >= 552) and (vcount >= 425) and (hcount < 552 + 8) and (vcount < 425 + 8)) then
 output <= Std_logic_vector(((vcount-425) * 8) + (hcount-552) + 656 + (64*to_unsigned(to_integer(freq_digits(2)), 12))); select_mem <= '0';
elsif ((hcount >= 544) and (vcount >= 425) and (hcount < 544 + 8) and (vcount < 425 + 8)) then
 output <= Std_logic_vector(((vcount-425) * 8) + (hcount-544) + 656 + (64*to_unsigned(to_integer(freq_digits(3)), 12))); select_mem <= '0';
elsif ((hcount >= 528) and (vcount >= 425) and (hcount < 528 + 16) and (vcount < 425 + 8)) then
 output <= Std_logic_vector(((vcount-425) * 16) + (hcount-528) + 528); select_mem <= '0';
elsif ((hcount >= 609) and (vcount >= 382) and (hcount < 609 + 16) and (vcount < 382 + 16)) then
 if toggle(7) = '1' then
 output <= Std_logic_vector(((vcount-382) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-382) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 404) and (hcount < 85 + 512) and (vcount < 404 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "111"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 374) and (hcount < 85 + 512) and (vcount < 374 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "111"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 372) and (hcount < 84 + 514) and (vcount < 372 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 370) and (hcount < 82 + 518) and (vcount < 370 + 40)) then
 output <= X"008"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 332) and (hcount < 609 + 16) and (vcount < 332 + 16)) then
 if toggle(6) = '1' then
 output <= Std_logic_vector(((vcount-332) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-332) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 354) and (hcount < 85 + 512) and (vcount < 354 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "110"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 324) and (hcount < 85 + 512) and (vcount < 324 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "110"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 322) and (hcount < 84 + 514) and (vcount < 322 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 320) and (hcount < 82 + 518) and (vcount < 320 + 40)) then
 output <= X"008"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 282) and (hcount < 609 + 16) and (vcount < 282 + 16)) then
 if toggle(5) = '1' then
 output <= Std_logic_vector(((vcount-282) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-282) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 304) and (hcount < 85 + 512) and (vcount < 304 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "101"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 274) and (hcount < 85 + 512) and (vcount < 274 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "101"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 272) and (hcount < 84 + 514) and (vcount < 272 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 270) and (hcount < 82 + 518) and (vcount < 270 + 40)) then
 output <= X"008"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 232) and (hcount < 609 + 16) and (vcount < 232 + 16)) then
 if toggle(4) = '1' then
 output <= Std_logic_vector(((vcount-232) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-232) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 254) and (hcount < 85 + 512) and (vcount < 254 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "100"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 224) and (hcount < 85 + 512) and (vcount < 224 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "100"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 222) and (hcount < 84 + 514) and (vcount < 222 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 220) and (hcount < 82 + 518) and (vcount < 220 + 40)) then
 output <= X"008"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 182) and (hcount < 609 + 16) and (vcount < 182 + 16)) then
 if toggle(3) = '1' then
 output <= Std_logic_vector(((vcount-182) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-182) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 204) and (hcount < 85 + 512) and (vcount < 204 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "011"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 174) and (hcount < 85 + 512) and (vcount < 174 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "011"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 172) and (hcount < 84 + 514) and (vcount < 172 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 170) and (hcount < 82 + 518) and (vcount < 170 + 40)) then
 output <= X"008"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 132) and (hcount < 609 + 16) and (vcount < 132 + 16)) then
 if toggle(2) = '1' then
 output <= Std_logic_vector(((vcount-132) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-132) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 154) and (hcount < 85 + 512) and (vcount < 154 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "010"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 124) and (hcount < 85 + 512) and (vcount < 124 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "010"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 122) and (hcount < 84 + 514) and (vcount < 122 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 120) and (hcount < 82 + 518) and (vcount < 120 + 40)) then
 output <= X"008"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 82) and (hcount < 609 + 16) and (vcount < 82 + 16)) then
 if toggle(1) = '1' then
 output <= Std_logic_vector(((vcount-82) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-82) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 104) and (hcount < 85 + 512) and (vcount < 104 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "001"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 74) and (hcount < 85 + 512) and (vcount < 74 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "001"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 72) and (hcount < 84 + 514) and (vcount < 72 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 70) and (hcount < 82 + 518) and (vcount < 70 + 40)) then
 output <= X"008"; select_mem <= '0'; 
elsif ((hcount >= 609) and (vcount >= 32) and (hcount < 609 + 16) and (vcount < 32 + 16)) then
 if toggle(0) = '1' then
 output <= Std_logic_vector(((vcount-32) * 16) + (hcount-609) + 272); select_mem <= '0';
else
 output <= Std_logic_vector(((vcount-32) * 16) + (hcount-609) + 16); select_mem <= '0';
end if;
elsif ((hcount >= 85) and (vcount >= 54) and (hcount < 85 + 512) and (vcount < 54 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "000"; output(11) <= '1'; select_mem <= '1';
elsif ((hcount >= 85) and (vcount >= 24) and (hcount < 85 + 512) and (vcount < 24 + 1)) then
 output(10 downto 0) <= std_logic_vector((hcount-85)); index <= "000"; output(11) <= '0'; select_mem <= '1';
elsif ((hcount >= 84) and (vcount >= 22) and (hcount < 84 + 514) and (vcount < 22 + 36)) then
 output <= X"000"; select_mem <= '0'; 
elsif ((hcount >= 82) and (vcount >= 20) and (hcount < 82 + 518) and (vcount < 20 + 40)) then
 output <= X"008"; select_mem <= '0'; 
else
 output <= X"000"; select_mem <= '0';
end if;

end process; end Behavioral;
