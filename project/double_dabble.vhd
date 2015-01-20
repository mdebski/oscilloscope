library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity double_dabble is
 generic (
  n: natural := 13; -- #input bits
  m: natural := 4 -- #output decimal digits = 1/4 #output bits
 );
 port (
  input: in std_logic_vector(n-1 downto 0);
  output: out std_logic_vector(4*m-1 downto 0);
  clk, rst: in std_logic
 );
end double_dabble;

architecture Behavioral of double_dabble is
 	COMPONENT add3
	PORT(
		a : IN std_logic_vector(3 downto 0);
		y : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	for all: add3 use entity work.add3(Behavioral);
	signal pre: std_logic_vector(4*m-1 downto 0);
	signal post: std_logic_vector(4*m-1 downto 0);
	constant cnt_length : integer := integer(ceil(log2(real(n))));
	signal cnt: unsigned(cnt_length-1 downto 0);
begin
 add3s: for i in m-1 downto 0 generate
  add: add3 port map (pre(4*i+3 downto 4*i),
                      post(4*i+3 downto 4*i));
 end generate;
 process(clk) begin if rising_edge(clk) then
  if rst = '1' then
   pre <= (0 => input(n-3), 1 => input(n-2), 2 => input(n-1), others => '0');
   cnt <= to_unsigned(n-3, cnt_length);
	 output <= (others => '0');
  else
   if cnt = 0 then
	  output <= pre;
	 else
	  pre <= post(4*m-2 downto 0) & input(to_integer(cnt-1));
	  cnt <= cnt - 1;
	 end if;
  end if;
 end if; end process;
end Behavioral;
