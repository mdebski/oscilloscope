library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity impulser_drv is
 port (
  clk, rst: in std_logic;
  imp1, imp2: in std_logic;
  lstrobe, rstrobe: out std_logic
 );
end impulser_drv;

architecture Behavioral of impulser_drv is
 type IMP_STATE_TYPE is (WAIT_FOR_BOTH_OFF, BOTH_OFF, FIRST1, FIRST2);
 signal state: IMP_STATE_TYPE;
begin
 process(clk) is begin if rising_edge(clk) then
  lstrobe <= '0';
  rstrobe <= '0';
  if(rst = '1') then
   state <= WAIT_FOR_BOTH_OFF ;
  else
   if state = WAIT_FOR_BOTH_OFF and imp1 = '0' and imp2 = '0' then
    state <= BOTH_OFF;
   elsif state = BOTH_OFF then
    if imp1 = '1' then
     state <= FIRST1;
    elsif imp2 = '1' then
     state <= FIRST2;
    end if;
   elsif state = FIRST1 and imp2 = '1' then
    lstrobe <= '1';
    state <= WAIT_FOR_BOTH_OFF;
   elsif state = FIRST2 and imp1 = '1' then
    rstrobe <= '1';
    state <= WAIT_FOR_BOTH_OFF;
   end if;
  end if;
end if; end process; end Behavioral;