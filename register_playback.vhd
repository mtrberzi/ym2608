----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:52:07 08/03/2014 
-- Design Name: 
-- Module Name:    register_playback - Behavioral 
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

use std.textio.ALL;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_playback is Port ( 
	clk : in  STD_LOGIC;
   rst : in  STD_LOGIC;
	start: in std_logic;
	irq_timerb: in std_logic;
	
	addr: out std_logic_vector(8 downto 0);
	we: out std_logic;
	data: out std_logic_vector(7 downto 0)
); end register_playback;

architecture Behavioral of register_playback is
	type state_type is (state_reset, state_preload_1, state_preload_2,
		state_wait_for_start, state_playback, state_wait_for_irq);

	type reg_type is record
		state: state_type;
		addr: std_logic_vector(8 downto 0);
		we: std_logic;
		data: std_logic_vector(7 downto 0);
		rom_addr: std_logic_vector(15 downto 0);
		rom_data: std_logic_vector(17 downto 0);
		first: std_logic;
	end record;
	
	component playback_rom port (
		clka: in std_logic;
		addra: in std_logic_vector(15 downto 0);
		douta: out std_logic_vector(17 downto 0)
	); end component; 
	
	signal rom_addr: std_logic_vector(15 downto 0);
	-- ROM data format:
	-- (17) = wait-for-IRQ flag
	-- (16 downto 8) = addr
	-- (7 downto 0) = data
	signal rom_data: std_logic_vector(17 downto 0);
	
	constant reg_reset: reg_type := (
		state => state_reset,
		addr => (others=>'0'),
		we => '0',
		data => X"00",
		rom_addr => (others=>'0'),
		rom_data => (others=>'0'),
		first => '1'
	);
	
	signal reg: reg_type := reg_reset;
	signal ci_next: reg_type;
begin

COMB: process(reg, rst, start, irq_timerb, rom_data)
	variable ci: reg_type;
	variable next_rom_addr_u: unsigned(15 downto 0);
	variable next_rom_addr: std_logic_vector(15 downto 0);
	variable prev_rom_addr_u: unsigned(15 downto 0);
	variable prev_rom_addr: std_logic_vector(15 downto 0);
begin
	ci := reg;
	-- self-clearing
	ci.we := '0';
	-- easy increment/decrement
	next_rom_addr_u := unsigned(reg.rom_addr) + 1;
	next_rom_addr := std_logic_vector(next_rom_addr_u);
	prev_rom_addr_u := unsigned(reg.rom_addr) - 1;
	prev_rom_addr := std_logic_vector(prev_rom_addr_u);
	
	if(rst = '1') then
		ci := reg_reset;
	else
		case reg.state is
			when state_reset =>
				ci.state := state_preload_1;
			when state_preload_1 => 
				-- now rom_addr = 0; data valid next cycle
				ci.rom_addr := next_rom_addr;
				ci.state := state_preload_2;
			when state_preload_2 => 
				-- load rom data
				ci.rom_data := rom_data;
				ci.state := state_wait_for_start;
			when state_wait_for_start =>
				if(start = '1') then
					ci.state := state_playback;
				end if;
			when state_playback =>
				-- playback buffered data
					ci.addr := reg.rom_data(16 downto 8);
					ci.we := '1';
					ci.data := reg.rom_data(7 downto 0);
					
					if(reg.first = '1') then
						ci.first := '0';
					end if;
				-- check for IRQ flag
					if(reg.rom_data(17) = '1') then
						-- modified increment logic to avoid missed instructions due to pipelining
						if(reg.first = '1') then
							ci.rom_addr := next_rom_addr;
							ci.rom_data := rom_data;
						else
							ci.rom_addr := prev_rom_addr;
							-- don't buffer data here, the current address is wrong
						end if;
						ci.state := state_wait_for_irq;
					else
						ci.rom_addr := next_rom_addr;
						ci.rom_data := rom_data;
					end if;
				when state_wait_for_irq =>
					if(irq_timerb = '1') then
						ci.first := '1';
						ci.state := state_playback;
						ci.rom_data := rom_data;
					end if;
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

rom_addr <= reg.rom_addr;

ROM: playback_rom port map (
	clka => clk,
	addra => rom_addr,
	douta => rom_data
);

addr <= reg.addr;
we <= reg.we;
data <= reg.data;

end Behavioral;

