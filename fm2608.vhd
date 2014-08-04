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

		nxt: in std_logic;
		output: out signed(17 downto 0);
		valid: out std_logic
	); end component;
	-- shared write-enable signal for all fm channels (decodes addr(7 downto 2))
	signal fm_we: std_logic; 
	-- individual write-enable signals decode addr(8) & addr(1 downto 0)
	signal fm0_we: std_logic;
	signal fm0_output: signed(17 downto 0);
	signal fm0_valid: std_logic;
	
	type reg_type is record
		timer_control: std_logic_vector(7 downto 0); -- $27
	end record;
	
	constant reg_reset: reg_type := (
		timer_control => "00000000"
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
	N => 72
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
	-- weird address decoding manipulation
	addr(8) => '0',
	addr(7 downto 2) => addr(7 downto 2),
	addr(1 downto 0) => "00",
	we => fm0_we,
	data => data,
	nxt => sample_tick,
	output => fm0_output,
	valid => fm0_valid
);
-- decode addresses $30 - $B6 (and $130 - $1B6)
fm_we <= '1' when (unsigned(addr(7 downto 0)) >= to_unsigned(48, 8) and unsigned(addr(7 downto 0)) <= to_unsigned(182, 8)) and (we = '1') else '0';
-- individual decodes
fm0_we <= '1' when (addr(8) = '0' and addr(1 downto 0) = "00") and (fm_we = '1') else '0';
-- TODO mixing
pcm_out <= fm0_output;
pcm_valid <= fm0_valid;

end Behavioral;

