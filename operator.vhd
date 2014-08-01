----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:08:34 07/31/2014 
-- Design Name: 
-- Module Name:    operator - Behavioral 
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

entity operator is port (
	clk: in std_logic;
	rst: in std_logic;
	
	nxt: in std_logic;
	input: in signed(31 downto 0);
	phase: in unsigned(31 downto 0);
	envelope: in unsigned(15 downto 0);
	
	output: out signed(17 downto 0);
	valid: out std_logic
);
end operator;

architecture Behavioral of operator is

	-- sine ROM
	component sinetab is port (
		clka: in std_logic;
		addra: in std_logic_vector(9 downto 0);
		douta: out std_logic_vector(9 downto 0)
	); end component;
	signal theta_sine: std_logic_vector(9 downto 0);
	signal sine: std_logic_vector(9 downto 0);

	type operator_reg_type is record
		-- stage 1
		theta: signed(32 downto 0);
		nxt1: std_logic;
		envelope1: unsigned(15 downto 0);
		-- stage 2
		nxt2: std_logic;
		envelope2: unsigned(15 downto 0);
		-- stage 3
		sample: signed(26 downto 0);
		nxt3: std_logic;
	end record;
	
	constant reg_reset: operator_reg_type := (
		theta => to_signed(0, 33),
		nxt1 => '0',
		envelope1 => to_unsigned(0, 16),
		nxt2 => '0',
		envelope2 => to_unsigned(0, 16),
		sample => to_signed(0, 27),
		nxt3 => '0'
	);
	
	signal reg: operator_reg_type := reg_reset;
	signal ci_next: operator_reg_type;
begin

COMB: process(reg, rst, nxt, input, phase, envelope, sine)
	variable ci: operator_reg_type;
	
	variable in1: signed(31 downto 0);
	variable in2: signed(32 downto 0);
	
	variable sine_s: signed(9 downto 0);
	variable env_s: signed(16 downto 0);
begin
	ci := reg;
	
	if(rst = '1') then
		ci := reg_reset;
	else
		-- stage 1
		in1 := signed( input(16 downto 0) & "000000000000000");
		in2 := signed('0' & phase);
		ci.theta := in1 + in2;
		ci.nxt1 := nxt;
		ci.envelope1 := envelope;
		-- stage 2
		ci.nxt2 := reg.nxt1;
		ci.envelope2 := reg.envelope1;
		-- stage 3
		sine_s := signed(sine);
		env_s := signed('0' & reg.envelope2);
		ci.sample := sine_s * env_s;
		ci.nxt3 := reg.nxt2;
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

-- outputs

output <= reg.sample(25 downto 8);
valid <= reg.nxt3;

end Behavioral;

