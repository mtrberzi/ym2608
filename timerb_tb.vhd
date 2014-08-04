--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:56:34 08/03/2014
-- Design Name:   
-- Module Name:   /home/mtrberzi/ym2608/timerb_tb.vhd
-- Project Name:  ym2608
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: timerb
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY timerb_tb IS
END timerb_tb;
 
ARCHITECTURE behavior OF timerb_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT timerb
    PORT(
         clk : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         we : IN  std_logic;
         run : IN  std_logic;
         irqen : IN  std_logic;
         tick : IN  std_logic;
         irq : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal we : std_logic := '0';
   signal run : std_logic := '0';
   signal irqen : std_logic := '0';
   signal tick : std_logic := '0';

 	--Outputs
   signal irq : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: timerb PORT MAP (
          clk => clk,
          data => data,
          we => we,
          run => run,
          irqen => irqen,
          tick => tick,
          irq => irq
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      wait for clk_period*10;
		wait until falling_edge(clk);

      -- set timer to expire after 3 ticks, enable interrupts, start running
		data <= std_logic_vector(to_unsigned(256 - 3, 8));
		we <= '1';
		wait for clk_period;
		we <= '0';
		
		run <= '1';
		irqen <= '1';
		
		wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;		
		wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;
wait for clk_period;
		tick <= not tick;

      wait;
   end process;

END;
