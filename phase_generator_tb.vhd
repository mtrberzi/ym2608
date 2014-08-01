--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:09:25 08/01/2014
-- Design Name:   
-- Module Name:   /home/mtrberzi/ym2608/phase_generator_tb.vhd
-- Project Name:  ym2608
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: phase_generator
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
 
ENTITY phase_generator_tb IS
END phase_generator_tb;
 
ARCHITECTURE behavior OF phase_generator_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT phase_generator
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         dp : IN  unsigned(17 downto 0);
         detune : IN  unsigned(7 downto 0);
         bn : IN  unsigned(4 downto 0);
         multiple : IN  unsigned(3 downto 0);
         update : IN  std_logic;
         nxt : IN  std_logic;
         phase : OUT  unsigned(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal dp : unsigned(17 downto 0) := (others => '0');
   signal detune : unsigned(7 downto 0) := (others => '0');
   signal bn : unsigned(4 downto 0) := (others => '0');
   signal multiple : unsigned(3 downto 0) := (others => '0');
   signal update : std_logic := '0';
   signal nxt : std_logic := '0';

 	--Outputs
   signal phase : unsigned(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: phase_generator PORT MAP (
          clk => clk,
          rst => rst,
          dp => dp,
          detune => detune,
          bn => bn,
          multiple => multiple,
          update => update,
          nxt => nxt,
          phase => phase
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
		rst <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		rst <= '0';

      wait for clk_period*10;
		wait until falling_edge(clk);

      -- set multiple=12, dp=1650, detune=96, bn=4
		-- should see pgdcount = 5875008
		multiple <= to_unsigned(12, 4);
		dp <= to_unsigned(1650, 18);
		detune <= to_unsigned(96, 8);
		bn <= to_unsigned(4, 5);
		
		wait for clk_period*3; -- make sure there are no changes yet
		
		update <= '1';
		wait for clk_period;
		update <= '0'; -- now we should see the correct pgdcount loaded

      wait;
   end process;

END;
