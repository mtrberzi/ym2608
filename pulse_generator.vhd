----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:06:15 08/03/2014 
-- Design Name: 
-- Module Name:    pulse_generator - Behavioral 
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

entity pulse_generator is generic (
	N: integer
); port (
	clk: in std_logic;
	rst: in std_logic;
	pulse: out std_logic
); end pulse_generator;

architecture Behavioral of pulse_generator is
	signal pulse_counter: unsigned(11 downto 0) := (others => '0');
	signal pulse_stb: std_logic := '0';
begin

process(clk, rst, pulse_counter)
	variable next_count: unsigned(11 downto 0);
	variable stb: std_logic;
begin
	stb := '0';
	if(pulse_counter = to_unsigned(0, 12)) then
		next_count := to_unsigned(N-1, 12);
		stb := '1';
	else
		next_count := pulse_counter - 1;
	end if;
	if(rising_edge(clk)) then
		pulse_counter <= next_count;
		pulse_stb <= stb;
	end if;
end process;

pulse <= pulse_stb;

end Behavioral;

