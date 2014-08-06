----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:03:11 08/06/2014 
-- Design Name: 
-- Module Name:    mixer2 - Behavioral 
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

entity mixer2 is Port (
	clk : in  STD_LOGIC;
   rst : in  STD_LOGIC;
	
	A_in: in signed(21 downto 0);
	A_valid: in std_logic;
	B_in: in signed(21 downto 0);
	B_valid: in std_logic;
	
	mix_out: out signed(21 downto 0);
	mix_valid: out std_logic
); end mixer2;

architecture Behavioral of mixer2 is
	type state_type is (state_idle, state_a, state_b, state_limit);
	
	type reg_type is record
		state: state_type;
		accumulator: signed(22 downto 0);
		mix: signed(21 downto 0);
		valid: std_logic;
	end record;
	
	constant reg_reset: reg_type := (
		state => state_idle,
		accumulator => to_signed(0, 23),
		mix => to_signed(0, 22),
		valid => '0'
	);
	constant accumulator_high: signed(22 downto 0) := to_signed(2097151, 23); -- +2^21-1
	constant mix_high: signed(21 downto 0) := to_signed(2097151, 22);
	constant accumulator_low: signed(22 downto 0) := to_signed(-2097152, 23); -- -2^21
	constant mix_low: signed(21 downto 0) := to_signed(-2097152, 22);
	signal reg: reg_type := reg_reset;
	signal ci_next: reg_type;
begin

COMB: process(reg, rst, A_in, A_valid, B_in, B_valid)
	variable ci: reg_type;
begin
	ci := reg;
	-- self-clearing
	ci.valid := '0';
	if(rst = '1') then
		ci := reg_reset;
	else
		case reg.state is
			when state_idle =>
				if(A_valid = '1' and B_valid = '1') then
					ci.accumulator := signed(A_in(21) & A_in) + B_in;
					ci.state := state_limit;
				elsif(A_valid = '1' and B_valid = '0') then
					ci.accumulator := signed(A_in(21) & A_in);
					ci.state := state_b;
				elsif(A_valid = '0' and B_valid = '1') then
					ci.accumulator := signed(B_in(21) & B_in);
					ci.state := state_a;
				end if;
			when state_a =>
				if(A_valid = '1') then
					ci.accumulator := reg.accumulator + A_in;
					ci.state := state_limit;
				end if;
			when state_b =>
				if(B_valid = '1') then
					ci.accumulator := reg.accumulator + B_in;
					ci.state := state_limit;
				end if;
			when state_limit =>
				-- check accumulator and clamp to a 22-bit value in mix
				if(reg.accumulator > accumulator_high) then
					ci.mix := mix_high;
				elsif(reg.accumulator < accumulator_low) then
					ci.mix := mix_low;
				else
					ci.mix := signed(reg.accumulator(22) & reg.accumulator(20 downto 0));
				end if;
				ci.valid := '1';
				ci.state := state_idle;
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

-- output
mix_out <= reg.mix;
mix_valid <= reg.valid;

end Behavioral;

