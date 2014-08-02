--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:37:00 08/01/2014
-- Design Name:   
-- Module Name:   /home/mtrberzi/ym2608/fm_channel_tb.vhd
-- Project Name:  ym2608
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fm_channel
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
 
ENTITY fm_channel_tb IS
END fm_channel_tb;
 
ARCHITECTURE behavior OF fm_channel_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fm_channel
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         addr : IN  std_logic_vector(8 downto 0);
         we : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         nxt : IN  std_logic;
         output : OUT  signed(17 downto 0);
         valid : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal addr : std_logic_vector(8 downto 0) := (others => '0');
   signal we : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal nxt : std_logic := '0';

 	--Outputs
   signal output : signed(17 downto 0);
   signal valid : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fm_channel PORT MAP (
          clk => clk,
          rst => rst,
          addr => addr,
          we => we,
          data => data,
          nxt => nxt,
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
		addr <= (others=>'0');
		we <= '0';
		data <= (others=>'0');
		nxt <= '0';
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;	
		rst <= '0';

      wait for clk_period*10;
		wait until falling_edge(clk);

		-- let's set up this operator exactly like Operator 1 in Th02_01.M
		we <= '1';
		-- the register dump is this:
		--write addr=0x040 data=0x7f
		--write addr=0x080 data=0x7f
		--write addr=0x044 data=0x7f
		--write addr=0x084 data=0x7f
		--write addr=0x048 data=0x7f
		--write addr=0x088 data=0x7f
		--write addr=0x04c data=0x7f
		--write addr=0x08c data=0x7f
		--write addr=0x028 data=0x00
		--write addr=0x0b0 data=0x3c (OK)
		--write addr=0x030 data=0x32 (OK)
		--write addr=0x034 data=0x72 (OK)
		--write addr=0x038 data=0x34 (OK)
		--write addr=0x03c data=0x74 (OK)
		--write addr=0x040 data=0x1e
		--write addr=0x044 data=0x1f
		--write addr=0x050 data=0xcf
		--write addr=0x054 data=0xcf
		--write addr=0x058 data=0x0d
		--write addr=0x05c data=0x0c
		--write addr=0x060 data=0x00
		--write addr=0x064 data=0x00
		--write addr=0x068 data=0x02
		--write addr=0x06c data=0x02
		--write addr=0x070 data=0x00
		--write addr=0x074 data=0x00
		--write addr=0x078 data=0x00
		--write addr=0x07c data=0x00
		--write addr=0x080 data=0x02
		--write addr=0x084 data=0x02
		--write addr=0x088 data=0x37
		--write addr=0x08c data=0x37
		--write addr=0x04c data=0x0f
		--write addr=0x048 data=0x0f
		--write addr=0x0a4 data=0x1a (OK)
		--write addr=0x0a0 data=0x6a (OK)
		--write addr=0x028 data=0xf0

		-- fb/alg = $B0
		-- write fb/alg = 0x3C
		addr <= "0" & X"B0";
		data <= X"3C";
		wait for CLK_PERIOD;

		-- DT/MULTI = $30, $34, $38, $3C
		-- write $30 = 0x32, $34 = 0x72,
		-- 		$38 = 0x34,	$3c = 0x74
		addr <= "0" & X"30";
		data <= X"32";
		wait for CLK_PERIOD;
		addr <= "0" & X"34";
		data <= X"72";
		wait for CLK_PERIOD;
		addr <= "0" & X"38";
		data <= X"34";
		wait for CLK_PERIOD;
		addr <= "0" & X"3C";
		data <= X"74";
		wait for CLK_PERIOD;
		

		-- fnum2 = $A4, fnum1 = $A0
      -- write fnum2 = 26, then fnum1 = 106
		-- expect to see fnum = 6762, dp = 4944, bn = 12
		addr <= "0" & X"A4";
		data <= std_logic_vector(to_unsigned(26, 8));
		wait for CLK_PERIOD;
		addr <= "0" & X"A0";
		data <= std_logic_vector(to_unsigned(106, 8));
		wait for CLK_PERIOD;
		
		we <= '0';
		
		wait for CLK_PERIOD * 5;
		
		-- collect a number of samples...
		for I in 1 to 10 loop
			nxt <= '1';
			wait for CLK_PERIOD;
			nxt <= '0';
			wait until valid = '1';
			wait until valid = '0';
			wait until falling_edge(clk);
		end loop;

      wait;
   end process;

END;
