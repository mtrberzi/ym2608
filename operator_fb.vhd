----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:17:10 08/01/2014 
-- Design Name: 
-- Module Name:    operator_fb - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
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

entity operator_fb is port (
	clk: in std_logic;
	rst: in std_logic;
	
	nxt: in std_logic;
	fb: in unsigned(4 downto 0);
	phase: in unsigned(31 downto 0);
	envelope: in unsigned(15 downto 0);
	
	output: out signed(17 downto 0);
	valid: out std_logic
);
end operator_fb;

architecture Behavioral of operator_fb is
	-- sine ROM
	component sinetab is port (
		clka: in std_logic;
		addra: in std_logic_vector(9 downto 0);
		douta: out std_logic_vector(9 downto 0)
	); end component;
	signal theta_sine: std_logic_vector(9 downto 0);
	signal sine: std_logic_vector(9 downto 0);
	
	type operator_fb_reg_type is record
		-- feedback state
		fb_out: signed(17 downto 0);
		fb_out2: signed(17 downto 0);
		-- stage 1
		input: signed(18 downto 0);
		fb: unsigned(4 downto 0); -- actually storing (fb-1) for an optimization later
		phase: unsigned(31 downto 0);
		envelope: unsigned(15 downto 0);
		nxt1: std_logic;
		-- stage 2
		in_shifted: signed(31 downto 0);
		nxt2: std_logic;
		-- stage 3
		theta: signed(32 downto 0);
		nxt3: std_logic;
		-- stage 4
		nxt4: std_logic;
		-- stage 5
		sample: signed(26 downto 0);
		nxt5: std_logic;
	end record;
	
	constant reg_reset: operator_fb_reg_type := (
		fb_out => to_signed(0, 18),
		fb_out2 => to_signed(0, 18),
		input => to_signed(0, 19),
		fb => to_unsigned(0, 5),
		phase => to_unsigned(0, 32),
		envelope => to_unsigned(0, 16),
		nxt1 => '0',
		in_shifted => to_signed(0, 32),
		nxt2 => '0',
		theta => to_signed(0, 33),
		nxt3 => '0',
		nxt4 => '0',
		sample => to_signed(0, 27),
		nxt5 => '0'
	);
	
	signal reg: operator_fb_reg_type := reg_reset;
	signal ci_next: operator_fb_reg_type;
	
begin

COMB: process(reg, rst, nxt, fb, phase, envelope, sine)
	variable ci: operator_fb_reg_type;
	variable input_tmp: signed(18 downto 0);
	variable phase_s: signed(32 downto 0);
	
	variable input_s: signed(31 downto 0);
	variable sine_s: signed(9 downto 0);
	variable env_s: signed(16 downto 0);
begin
	ci := reg;
	if(rst = '1') then
		ci := reg_reset;
	else
		-- stage 1
		-- weird bug fix, in simulation this otherwise shows up as double the correct answer (1 + 0 = 1, etc.)
		--input_tmp := reg.fb_out + reg.fb_out2;
		--ci.input := signed(input_tmp(18) & input_tmp(18 downto 1));
		ci.input := reg.fb_out + reg.fb_out2;
		if(fb = "00000") then
			ci.fb := "00000";
		else
			ci.fb := fb - 1;
		end if;
		ci.phase := phase;
		ci.envelope := envelope;
		ci.nxt1 := nxt;
		-- stage 2
		input_s := signed(reg.input & "0000000000000"); -- <<13
		ci.in_shifted := shift_right(input_s, to_integer(reg.fb));
		
		-- CHEATING WITH *BOTH* HANDS THIS TIME:
--		case reg.fb is
--			when "00000" => -- no shift
--				ci.in_shifted := signed(reg.input & "0000000000000"); -- <<13
--			when others => -- invalid shift amount, or maximum value
--				ci.in_shifted := to_signed(0, 32);
--		end case;

		ci.nxt2 := reg.nxt1;
		-- stage 3
		phase_s := signed('0' & reg.phase);
		if(reg.fb = to_unsigned(30, 5)) then
			ci.theta := phase_s;
		else
			ci.theta := reg.in_shifted + phase_s;
		end if;
		ci.nxt3 := reg.nxt2;
		-- stage 4
		ci.nxt4 := reg.nxt3;
		-- stage 5
		sine_s := signed(sine);
		env_s := signed('0' & reg.envelope);
		ci.sample := sine_s * env_s;
		ci.nxt5 := reg.nxt4;
		-- update feedback if valid
		if(reg.nxt4 = '1') then
			ci.fb_out2 := reg.fb_out;
			ci.fb_out := reg.sample(25 downto 8);
		end if;
	end if;
	ci_next <= ci;
end process COMB;

SEQ: process(clk, ci_next)
begin
	if(rising_edge(clk)) then
		reg <= ci_next;
	end if;
end process SEQ;

theta_sine <= std_logic_vector(reg.theta(28 downto 19));
SINETABLE: sinetab port map (
	clka => clk,
	addra => theta_sine,
	douta => sine
);

-- output
output <= reg.sample(25 downto 8);
valid <= reg.nxt5;

end Behavioral;

