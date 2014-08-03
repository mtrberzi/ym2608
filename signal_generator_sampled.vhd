----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:09:21 08/02/2014 
-- Design Name: 
-- Module Name:    signal_generator_sampled - Behavioral 
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

entity signal_generator_sampled is
    Port ( clk : in  STD_LOGIC;
           nxt : in  STD_LOGIC;
			  sample: out signed(19 downto 0));
end signal_generator_sampled;

architecture Behavioral of signal_generator_sampled is
	component sample_rom port (
		clka: in std_logic;
		addra: in std_logic_vector(17 downto 0);
		douta: out std_logic_vector(15 downto 0)
	); end component;
	
	signal addr: std_logic_vector(17 downto 0) := (others=>'0');
	constant addr_hi: unsigned(17 downto 0) := to_unsigned(233138-1, 18);
	
	constant resample_scale: unsigned(1 downto 0) := "10"; -- resample by 3 (16000Hz samples)
	signal resample: unsigned(1 downto 0) := resample_scale;
	
	signal data: std_logic_vector(15 downto 0);
begin

process(clk, nxt, addr, resample)
	variable addr_u: unsigned(17 downto 0);
	variable next_addr: unsigned(17 downto 0);
	
	variable resample_next: unsigned(1 downto 0);
begin
	addr_u := unsigned(addr);
	next_addr := addr_u;
	resample_next := resample;
	if(nxt = '1') then
		if(resample = "00") then
			resample_next := resample_scale;
			if(addr_u = addr_hi) then
				next_addr := to_unsigned(0, 18);
			else
				next_addr := addr_u + 1;
			end if;
		else
			resample_next := resample - 1;
		end if;
	end if;
	if(rising_edge(clk)) then
		addr <= std_logic_vector(next_addr);
		resample <= resample_next;
	end if;
end process;

sample <= signed(data & "0000");

ROM: sample_rom port map (
	clka => clk,
	addra => addr,
	douta => data
);

end Behavioral;

