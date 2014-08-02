----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:55:49 08/02/2014 
-- Design Name: 
-- Module Name:    signal_generator_square - Behavioral 
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

entity signal_generator_square is port ( 
	clk : in  STD_LOGIC;
   nxt : in  STD_LOGIC;
	sample: out signed(19 downto 0)
); end signal_generator_square;

architecture Behavioral of signal_generator_square is
	constant sample_reset: unsigned(7 downto 0) := to_unsigned(54-1, 8);
	signal sample_count: unsigned(7 downto 0) := sample_reset;
	signal sample_phase: std_logic := '1';
	
	
	constant square_high: signed(19 downto 0) := to_signed(20000, 20);
	constant square_low: signed(19 downto 0) := to_signed(-20000, 20);
begin

process(clk, nxt, sample_count, sample_phase)
	variable count_v: unsigned(7 downto 0);
	variable sample_v: signed(19 downto 0);
	variable phase_v: std_logic;
begin
	count_v := sample_count;
	phase_v := sample_phase;
	if(nxt = '1') then
		if(sample_count = X"00") then
			count_v := sample_reset;
			phase_v := not sample_phase;
		else
			count_v := sample_count - 1;
		end if;
	end if;
	
	if(sample_phase = '1') then
		sample_v := square_high;
	else
		sample_v := square_low;
	end if;
	if(rising_edge(clk)) then
		sample_count <= count_v;
		sample <= sample_v;
		sample_phase <= phase_v;
	end if;
	
end process;

end Behavioral;

