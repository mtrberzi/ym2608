----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:04:07 08/03/2014 
-- Design Name: 
-- Module Name:    fm2608 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- Top-level component for the FM2608, a clean-room implementation of the
-- YM2608 (OPNA) sound chip.
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fm2608 is port (
	clk: in std_logic;
	rst: in std_logic;
	addr: in std_logic_vector(8 downto 0);
	we: in std_logic;
	data: in std_logic_vector(7 downto 0);
	-- TODO external channel hard-masking
	mute_fm: in std_logic_vector(5 downto 0); -- channel mute for FM
	
	irq: out std_logic;
	pcm_out: out signed(17 downto 0);
	pcm_valid: out std_logic
); end fm2608;

architecture Behavioral of fm2608 is
	component pulse_generator generic (
		N: integer
	); port (
		clk: in std_logic;
		rst: in std_logic;
		pulse: out std_logic
	); end component;
	signal timera_tick: std_logic;
	signal timerb_tick: std_logic;
	signal sample_tick: std_logic;
	
	component timerb Port (
		clk : in  STD_LOGIC;
      data : in  STD_LOGIC_VECTOR (7 downto 0);
      we : in  STD_LOGIC;
      run : in  STD_LOGIC;
      irqen : in  STD_LOGIC;
      tick : in  STD_LOGIC;
      irq : out  STD_LOGIC
	); end component;
	signal timerb_we: std_logic;
	signal timerb_irq: std_logic;
	
	component fm_channel port (
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;

		addr: in std_logic_vector(8 downto 0);
		we: in std_logic;
		data: in std_logic_vector(7 downto 0);

		key: in std_logic_vector(3 downto 0);
		nxt: in std_logic;
		output: out signed(17 downto 0);
		valid: out std_logic
	); end component;
	-- shared write-enable signal for all fm channels (decodes addr(7 downto 2))
	signal fm_we: std_logic; 
	-- individual write-enable signals decode addr(8) & addr(1 downto 0)
	signal fm0_we: std_logic;
	signal fm1_we: std_logic;
	signal fm2_we: std_logic;
	signal fm3_we: std_logic;
	signal fm4_we: std_logic;
	signal fm5_we: std_logic;
	-- key-on/key-off signals
	type fm_key_type is array(0 to 5) of std_logic_vector(3 downto 0);
	
	signal fm0_output: signed(17 downto 0);
	signal fm0_valid: std_logic;
	signal fm1_output: signed(17 downto 0);
	signal fm1_valid: std_logic;
	signal fm2_output: signed(17 downto 0);
	signal fm2_valid: std_logic;
	signal fm3_output: signed(17 downto 0);
	signal fm3_valid: std_logic;
	signal fm4_output: signed(17 downto 0);
	signal fm4_valid: std_logic;
	signal fm5_output: signed(17 downto 0);
	signal fm5_valid: std_logic;
	
	
	component mixer2 Port (
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		
		A_in: in signed(21 downto 0);
		A_valid: in std_logic;
		A_mute: in std_logic;
		B_in: in signed(21 downto 0);
		B_valid: in std_logic;
		B_mute: in std_logic;
		
		mix_out: out signed(21 downto 0);
		mix_valid: out std_logic
	); end component;
	
	-- sign-extended mixer inputs
	signal mix_fm0: signed(21 downto 0);
	signal mix_fm1: signed(21 downto 0);
	signal mix_fm2: signed(21 downto 0);
	signal mix_fm3: signed(21 downto 0);
	signal mix_fm4: signed(21 downto 0);
	signal mix_fm5: signed(21 downto 0);
	
	-- level-1 mixes
	signal mix_fm01: signed(21 downto 0);
	signal mix_fm01_valid: std_logic;
	signal mix_fm23: signed(21 downto 0);
	signal mix_fm23_valid: std_logic;
	signal mix_fm45: signed(21 downto 0);
	signal mix_fm45_valid: std_logic;
	signal mix_ssg01: signed(21 downto 0);
	signal mix_ssg01_valid: std_logic;
	
	-- level-2 mixes
	signal mix_fm0123: signed(21 downto 0);
	signal mix_fm0123_valid: std_logic;
	signal mix_fm45ssg01: signed(21 downto 0);
	signal mix_fm45ssg01_valid: std_logic;

	-- level-3 mixes
	signal mix_fmssg01: signed(21 downto 0);
	signal mix_fmssg01_valid: std_logic;
	
	
	type reg_type is record
		timer_control: std_logic_vector(7 downto 0); -- $27
		fm_key: fm_key_type;
	end record;
	
	constant reg_reset: reg_type := (
		timer_control => "00000000",
		fm_key => (others=>"0000")
	);
	
	signal reg: reg_type := reg_reset;
	signal ci_next: reg_type;
begin

COMB: process(reg, rst, addr, we, data)
	variable ci: reg_type;
begin
	ci := reg;
	if(rst = '1') then
		ci := reg_reset;
	elsif(we = '1') then
		case addr is
			when "0" & X"27" => -- Timer control
				ci.timer_control := data;
			when "0" & X"28" => -- FM key-on/key-off
				case data(2 downto 0) is
					when "000" => ci.fm_key(0) := data(7 downto 4);
					when "001" => ci.fm_key(1) := data(7 downto 4);
					when "010" => ci.fm_key(2) := data(7 downto 4);
					when "100" => ci.fm_key(3) := data(7 downto 4);
					when "101" => ci.fm_key(4) := data(7 downto 4);
					when "110" => ci.fm_key(5) := data(7 downto 4);
					when others => null; -- bogus channel
				end case;
			when others => null;
		end case;
	end if;
	ci_next <= ci;
end process COMB;

SEQ: process(clk, ci_next)
begin
	if(rising_edge(clk)) then
		reg <= ci_next;
	end if;
end process SEQ;

-- 48kHz * 166 = 7.968MHz
CLKGEN_SAMPLE: pulse_generator generic map (
	N => 166
) port map (
	clk => clk,
	rst => rst,
	pulse => sample_tick
);

CLKGEN_TIMERA: pulse_generator generic map (
	N => 72 * 2
) port map (
	clk => clk,
	rst => rst,
	pulse => timera_tick
);

CLKGEN_TIMERB: pulse_generator generic map (
	--N => 1152
	N => 1152*2
) port map (
	clk => clk,
	rst => rst,
	pulse => timerb_tick
);

timerb_we <= '1' when (addr = "0" & X"26" and we = '1') else '0';
TIMER_B: timerb port map (
	clk => clk,
	data => data,
	we => timerb_we,
	run => reg.timer_control(1), -- $27.LOAD_B
	irqen => reg.timer_control(3), -- $27.ENABLE_B
	tick => timerb_tick,
	irq => timerb_irq
);
-- TODO interrupt controller and acknowledge logic
irq <= timerb_irq;

FM0: fm_channel port map (
	clk => clk,
	rst => rst,
	addr => addr,
	we => fm0_we,
	data => data,
	key => reg.fm_key(0),
	nxt => sample_tick,
	output => fm0_output,
	valid => fm0_valid
);
FM1: fm_channel port map (
	clk => clk,
	rst => rst,
	addr => addr,
	we => fm1_we,
	data => data,
	key => reg.fm_key(1),
	nxt => sample_tick,
	output => fm1_output,
	valid => fm1_valid
);
FM2: fm_channel port map (
	clk => clk,
	rst => rst,
	addr => addr,
	we => fm2_we,
	data => data,
	key => reg.fm_key(2),
	nxt => sample_tick,
	output => fm2_output,
	valid => fm2_valid
);
FM3: fm_channel port map (
	clk => clk,
	rst => rst,
	addr => addr,
	we => fm3_we,
	data => data,
	key => reg.fm_key(3),
	nxt => sample_tick,
	output => fm3_output,
	valid => fm3_valid
);
FM4: fm_channel port map (
	clk => clk,
	rst => rst,
	addr => addr,
	we => fm4_we,
	data => data,
	key => reg.fm_key(4),
	nxt => sample_tick,
	output => fm4_output,
	valid => fm4_valid
);
FM5: fm_channel port map (
	clk => clk,
	rst => rst,
	addr => addr,
	we => fm5_we,
	data => data,
	key => reg.fm_key(5),
	nxt => sample_tick,
	output => fm5_output,
	valid => fm5_valid
);

-- decode addresses $30 - $B6 (and $130 - $1B6)
fm_we <= '1' when (unsigned(addr(7 downto 0)) >= to_unsigned(48, 8) and unsigned(addr(7 downto 0)) <= to_unsigned(182, 8)) and (we = '1') else '0';
-- individual decodes
fm0_we <= '1' when (addr(8) = '0' and addr(1 downto 0) = "00") and (fm_we = '1') else '0';
fm1_we <= '1' when (addr(8) = '0' and addr(1 downto 0) = "01") and (fm_we = '1') else '0';
fm2_we <= '1' when (addr(8) = '0' and addr(1 downto 0) = "10") and (fm_we = '1') else '0';
fm3_we <= '1' when (addr(8) = '1' and addr(1 downto 0) = "00") and (fm_we = '1') else '0';
fm4_we <= '1' when (addr(8) = '1' and addr(1 downto 0) = "01") and (fm_we = '1') else '0';
fm5_we <= '1' when (addr(8) = '1' and addr(1 downto 0) = "10") and (fm_we = '1') else '0';

-- intermediate mixer inputs
mix_fm0 <= resize(fm0_output, 22);
mix_fm1 <= resize(fm1_output, 22);
mix_fm2 <= resize(fm2_output, 22);
mix_fm3 <= resize(fm3_output, 22);
mix_fm4 <= resize(fm4_output, 22);
mix_fm5 <= resize(fm5_output, 22);

-- level-1 mixing
MIXER_FM01: mixer2 port map (
	clk => clk,
	rst => rst,
	A_in => mix_fm0,
	A_valid => fm0_valid,
	A_mute => mute_fm(0),
	B_in => mix_fm1,
	B_valid => fm1_valid,
	B_mute => mute_fm(1),
	mix_out => mix_fm01,
	mix_valid => mix_fm01_valid
);
MIXER_FM23: mixer2 port map (
	clk => clk,
	rst => rst,
	A_in => mix_fm2,
	A_valid => fm2_valid,
	A_mute => mute_fm(2),
	B_in => mix_fm3,
	B_valid => fm3_valid,
	B_mute => mute_fm(3),
	mix_out => mix_fm23,
	mix_valid => mix_fm23_valid
);
MIXER_FM45: mixer2 port map (
	clk => clk,
	rst => rst,
	A_in => mix_fm4,
	A_valid => fm4_valid,
	A_mute => mute_fm(4),
	B_in => mix_fm5,
	B_valid => fm5_valid,
	B_mute => mute_fm(5),
	mix_out => mix_fm45,
	mix_valid => mix_fm45_valid
);

-- level-2 mixing
MIXER_FM0123: mixer2 port map (
	clk => clk,
	rst => rst,
	A_in => mix_fm01,
	A_valid => mix_fm01_valid,
	B_in => mix_fm23,
	B_valid => mix_fm23_valid,
	A_mute => '0',
	B_mute => '0',
	mix_out => mix_fm0123,
	mix_valid => mix_fm0123_valid
);
MIXER_FM45SSG01: mixer2 port map (
	clk => clk,
	rst => rst,
	A_in => mix_fm45,
	A_valid => mix_fm45_valid,
	B_in => (others=>'0'), -- TODO mix from SSG0/1
	B_valid => mix_fm45_valid,
	A_mute => '0',
	B_mute => '0',
	mix_out => mix_fm45ssg01,
	mix_valid => mix_fm45ssg01_valid
);

-- level-3 mixing
MIXER_FMSSG01: mixer2 port map (
	clk => clk,
	rst => rst,
	A_in => mix_fm0123,
	A_valid => mix_fm0123_valid,
	B_in => mix_fm45ssg01,
	B_valid => mix_fm45ssg01_valid,
	A_mute => '0',
	B_mute => '0',
	mix_out => mix_fmssg01,
	mix_valid => mix_fmssg01_valid
);

-- TODO level-4 mixing and others

-- intermediate output is (21 downto 0);
-- PCM output is (17 downto 0)
pcm_out <= mix_fmssg01(21 downto 4); -- close enough
pcm_valid <= mix_fmssg01_valid;

end Behavioral;

