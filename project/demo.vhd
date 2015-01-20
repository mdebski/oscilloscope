library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.common.all;

entity demo is
 port(
  clk: in std_logic; -- 32 Mhz
  
  input: in std_logic_vector(7 downto 0);
  sw: in std_logic_vector(7 downto 0);
  btn: in std_logic_vector(3 downto 0);
  led: out std_logic_vector(7 downto 0);
  jc: in std_logic_vector(3 downto 0);
  
  jd: out std_logic_vector(3 downto 0);
  hsync, vsync: out std_logic;
  vout: out std_logic_vector(7 downto 0)
 );
end demo;

architecture Structural of demo is
 signal pixclk, pixclk180: std_logic; -- 25 MHz
 signal probeclk: std_logic; -- 40,96 MHz
 signal preclk, preclk180: std_logic; -- 40,96 MHz / 10^prescale
 signal slow_clk: std_logic; -- for debouncers.
 signal rst: std_logic;
 signal select_mem: std_logic;
 signal hcount_v, vcount_v: std_logic_vector(10 downto 0);
 signal hcount, vcount: unsigned(10 downto 0);
 signal render_out: std_logic_vector(11 downto 0);
 signal prescale: unsigned(2 downto 0); -- prescale by 10^k
 signal freq: unsigned(11 downto 0);
 signal freq_inc: unsigned(12 downto 0);
 signal freq_dd: std_logic_vector(15 downto 0);
 signal freq_digits: DIGIT_ARRAY(3 downto 0);
 signal line_pos: unsigned(10 downto 0);
 signal state: STATE_TYPE;
 signal video_raw: std_logic_vector(3 downto 0);
 signal data_raw: std_logic_vector(7 downto 0);
 signal daddr: std_logic_vector(8 downto 0);
 signal mux1, mux2: std_logic_vector(7 downto 0);
 signal enable_write: std_logic_vector(0 downto 0);
 signal clk_buf, clk_tmp: std_logic;
 signal dd_rst: std_logic;
 signal index: unsigned(2 downto 0);
begin
 rst <= btn(0);
 hcount <= unsigned(hcount_v);
 vcount <= unsigned(vcount_v);
 
 clk_ibufg: IBUFG port map (I => clk, O => clk_tmp);
 clk_bufg :  BUFG port map (I => clk_tmp, O => clk_buf);

 clk32_25: entity work.clk32_25 PORT MAP(
		CLKIN_IN => clk_buf, RST_IN => rst,
		CLKFX_OUT => pixclk,	CLKFX180_OUT => pixclk180,
		CLK0_OUT => open
	);
 
 clk32_40: entity work.clk32_40 PORT MAP(
		CLKIN_IN => clk_buf, RST_IN => rst,
		CLKFX_OUT => probeclk,	CLKFX180_OUT => open,
		CLK0_OUT => open
	);
 
 sdivider: entity work.sdivider PORT MAP(
		clk_in => pixclk,
		rst => rst,
		clk_out => slow_clk 
	);
 
 controller: entity work.vga_controller_640_60 PORT MAP(
		rst => rst,
		pixel_clk => pixclk,
		HS => hsync,
		VS => vsync,
		hcount => hcount_v,
		vcount => vcount_v,
		blank => open
	);
 
 renderer: entity work.renderer PORT MAP(
		hcount => hcount,
		vcount => vcount,
  toggle => sw,
  freq_digits => freq_digits,
  line_pos => line_pos,
  state => state,
  prescale => prescale,
		output => render_out,
  index => index,
  select_mem => select_mem
	);
 
 mux: entity work.mux PORT MAP(
  in1 => mux1,
  in2 => mux2,
  sel => select_mem,
  output => vout
 );
 
 line_ctrl: entity work.line PORT MAP(
		clk => pixclk, rst => rst,
		btn_inc => jc(0),
		btn_dec => jc(1),
		line_pos => line_pos,
  slow_clk => slow_clk,
  debug => jd(1 downto 0)
	);
 
 pres_ctrl: entity work.pres_ctrl PORT MAP(
  clk => pixclk, rst => rst, slow_clk => slow_clk,
  btn_inc => btn(2), btn_dec => btn(1),
  prescale => prescale
 );
 
 jd(3) <= jc(1);
 jd(2) <= jc(0);
 
 div_ctrl: entity work.div_ctrl PORT MAP(
  clk => pixclk, rst => rst,
  btn_inc => jc(2),
  btn_dec => jc(3),
  slow_clk => slow_clk,
  freq => freq
 );
 
 prescaler: entity work.prescaler PORT MAP(
		clk => probeclk,
		rst => rst,
		scale => prescale,
		clk_out => preclk
	);
 preclk180 <= not preclk;
 
 prober: entity work.prober PORT MAP(
  clk => probeclk, scaled_clk => preclk, slow_clk => slow_clk, rst => rst,
  btn_change => btn(3),
  toggle => sw,
  freq => freq,
  state => state,
  addr => daddr,
  probe => enable_write(0),
  input => input
 );

 dram: entity work.dataram PORT MAP(
		clka => preclk180,
		wea => enable_write,
		addra => daddr,
		dina => input,
		clkb => pixclk180,
		addrb => render_out(8 downto 0),
		doutb => data_raw
	);
 
 vrom: entity work.vrom PORT MAP(
		clka => pixclk180,
		addra => render_out,
		douta => video_raw
	);
 
 vpalette: entity work.palette PORT MAP(
		color_4bit => video_raw,
		color_8bit => mux1
	);
 
 dpalette: entity work.dpalette PORT MAP(
  data => data_raw,
  color_8bit => mux2,
  index => index,
  neg => render_out(11)
 );
 
 freq_inc <= to_unsigned(to_integer(freq) + 1, 13);
 dd: entity work.double_dabble PORT MAP(
  clk => pixclk180, rst => dd_rst,
		input => std_logic_vector(freq_inc),
		output => freq_dd
	);
 
 process(pixclk) is begin if rising_edge(pixclk) then
  if vcount = 480 then
   dd_rst <= '1';
  else
   dd_rst <= '0';
  end if;
 end if; end process;
 
 freq_digits(0) <= unsigned(freq_dd(3  downto 0));
 freq_digits(1) <= unsigned(freq_dd(7  downto 4));
 freq_digits(2) <= unsigned(freq_dd(11 downto 8));
 freq_digits(3) <= unsigned(freq_dd(15 downto 12));
 
 with state select led(2) <=
  '1' when ONCE,
  '0' when others;
 with state select led(1) <=
  '1' when EVERY,
  '0' when others;
 led(7 downto 3) <= (others => '0');
 led(0) <= preclk;
 
end Structural;