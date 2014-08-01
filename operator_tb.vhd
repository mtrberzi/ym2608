--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:23:59 07/31/2014
-- Design Name:   
-- Module Name:   /home/mtrberzi/ym2608/operator_tb.vhd
-- Project Name:  ym2608
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: operator
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
 
ENTITY operator_tb IS
END operator_tb;
 
ARCHITECTURE behavior OF operator_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT operator
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         nxt : IN  std_logic;
         input : IN  signed(31 downto 0);
         phase : IN  unsigned(31 downto 0);
         envelope : IN  unsigned(15 downto 0);
         output : OUT  signed(17 downto 0);
         valid : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal nxt : std_logic := '0';
   signal input : signed(31 downto 0) := (others => '0');
   signal phase : unsigned(31 downto 0) := (others => '0');
   signal envelope : unsigned(15 downto 0) := (others => '0');

 	--Outputs
   signal output : signed(17 downto 0);
   signal valid : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: operator PORT MAP (
          clk => clk,
          rst => rst,
          nxt => nxt,
          input => input,
          phase => phase,
          envelope => envelope,
          output => output,
          valid => valid
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
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;	
		rst <= '0';

      wait for clk_period*10;

      -- insert stimulus here
		wait until falling_edge(clk);
		-- in=1, phase = 5865536, envelope = 1330
		-- should give out = 93
		nxt <= '1';
		input <= to_signed(1, 32);
		phase <= to_unsigned(5865536, 32);
		envelope <= to_unsigned(1330, 16);
		
		wait for clk_period;
		nxt <= '0';

      wait;
   end process;

END;
