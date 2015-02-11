library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common.all;

entity prober is
 port(
  clk, scaled_clk, slow_clk, rst: in std_logic;
  change_mode: in std_logic;
  freq: in unsigned(11 downto 0);
  toggle, input: in std_logic_vector(7 downto 0);

  state: out STATE_TYPE;
  addr: out std_logic_vector(8 downto 0);
  probe: out std_logic
 );
end prober;

architecture Behavioral of prober is
 signal cnt: unsigned(11 downto 0);
 signal got: unsigned(9 downto 0);
 signal sstate: STATE_TYPE;
 signal repeat: std_logic;
 signal last_input: std_logic_vector(7 downto 0);
 signal last_chg: std_logic;
begin

 addr <= Std_logic_vector(got(8 downto 0));
 state <= sstate;

 -- mode change
 process(clk) is begin if rising_edge(clk) then 
  last_chg <= change_mode;
  if rst = '1' then
   repeat <= '1';
  elsif(change_mode /= last_chg) then
   repeat <= not repeat;
  end if;
 end if; end process;

 process(scaled_clk) is begin if rising_edge(scaled_clk) then
  if(rst = '1') then
   got <= to_unsigned(0, 10);
   cnt <= to_unsigned(0, 12);
   sstate <= EVERY;
  else
  
   if sstate = EVERY and repeat = '0' then
    sstate <= ONCE;
    got <= to_unsigned(0, 10);
    cnt <= to_unsigned(0, 12);
   elsif sstate /= EVERY and repeat = '1' then
    sstate <= EVERY;
    got <= to_unsigned(0, 10);
    cnt <= to_unsigned(0, 12);
   end if;
    
   last_input <= input;
   probe <= '0';
   cnt <= cnt + 1;
   
   -- toggle
   if(((last_input xor input) and toggle) /= "00000000") then
    if sstate = ONCE then
     sstate <= ONCE_PROBING;
    elsif got = 512 then
     got <= to_unsigned(0, 10);
    end if;
   end if;
   
   if sstate = ONCE_PROBING and got = 512 then -- finish if once
    sstate <= ONCE_DONE;
   end if;
   
   -- get probe
   if got < 512 and (sstate = ONCE_PROBING or sstate = EVERY) then
    if ((cnt * freq) + cnt) rem 4096 < freq then
     got <= got + 1;
     probe <= '1';
    end if; 
   end if;
   
  end if;
 end if; end process;
end Behavioral;

