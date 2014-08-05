--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:39:11 08/02/2014
-- Design Name:   
-- Module Name:   /home/mtrberzi/ym2608/audio_out_top_tb.vhd
-- Project Name:  ym2608
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: audio_output_top
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY audio_out_top_tb IS
END audio_out_top_tb;
 
ARCHITECTURE behavior OF audio_out_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT audio_output_top
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         audio_bit_clk : IN  std_logic;
         audio_sdata_in : in  std_logic;
         audio_sdata_out : out  std_logic;
         audio_sync : OUT  std_logic;
         audio_reset : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal audio_bit_clk : std_logic := '0';
   signal audio_sdata_in : std_logic := '0';

 	--Outputs
	signal audio_sdata_out : std_logic;
   signal audio_sync : std_logic;
   signal audio_reset : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	--constant clk_period: time := 125 ns;
   constant audio_bit_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: audio_output_top PORT MAP (
          clk => clk,
          rst => rst,
          audio_bit_clk => audio_bit_clk,
          audio_sdata_in => audio_sdata_in,
          audio_sdata_out => audio_sdata_out,
          audio_sync => audio_sync,
          audio_reset => audio_reset
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   audio_bit_clk_process :process
   begin
		audio_bit_clk <= '0';
		wait for audio_bit_clk_period/2;
		audio_bit_clk <= '1';
		wait for audio_bit_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		rst <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;
		rst <= '0';

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
