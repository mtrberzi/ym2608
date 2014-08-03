----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:52:27 08/03/2014 
-- Design Name: 
-- Module Name:    timerb - Behavioral 
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

entity timerb is
    Port ( clk : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           we : in  STD_LOGIC;
           run : in  STD_LOGIC;
           irqen : in  STD_LOGIC;
           tick : in  STD_LOGIC;
           irq : out  STD_LOGIC);
end timerb;

architecture Behavioral of timerb is
	type reg_type is record
		timer_reload: unsigned(7 downto 0);
		timer: unsigned(7 downto 0);
		irq: std_logic;
	end record;
	
	signal reg: reg_type := (
		timer_reload => to_unsigned(0, 8),
		timer => to_unsigned(0, 8),
		irq => '0'
	);
	signal ci_next: reg_type;
begin

COMB: process(reg, data, we, run, irqen, tick)
	variable ci: reg_type;
begin
	ci := reg;
	-- self-clearing flags
	ci.irq := '0';
	
	if(we = '1') then
		ci.timer_reload := unsigned(data);
		ci.timer := unsigned(data);
	end if;
	
	if(run = '1' and tick = '1') then
		-- increment timer
		if(reg.timer = "11111111") then
			-- reload
			ci.timer := reg.timer_reload;
			if(irqen = '1') then
				ci.irq := '1';
			end if;
		else
			ci.timer := reg.timer + 1;
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

irq <= reg.irq;

end Behavioral;

