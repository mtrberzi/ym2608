----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:23:55 08/02/2014 
-- Design Name: 
-- Module Name:    xupv5_audio_out_top - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity xupv5_audio_out_top is port (
	CLK_33MHZ: in std_logic;
	CPU_RESET_B: in std_logic;
	LED_GPIO: out std_logic_vector(7 downto 0);
	AUDIO_BIT_CLK: in std_logic;
	AUDIO_SDATA_IN: in std_logic;
	AUDIO_SDATA_OUT: out std_logic;
	AUDIO_SYNC: out std_logic;
	AUDIO_RESET: out std_logic
); end xupv5_audio_out_top;

architecture Behavioral of xupv5_audio_out_top is

	component clksynth port ( 
		CLKIN1_IN   : in    std_logic;  -- 33 MHz
      RST_IN      : in    std_logic; 
      CLKOUT0_OUT : out   std_logic;  -- ~ 7.968 MHz
      LOCKED_OUT  : out   std_logic
	); end component;

	component audio_output_top Port ( 
		clk : in  STD_LOGIC; -- about 8 MHz (7.968MHz should be okay)
		rst : in  STD_LOGIC;
		
		-- AC97
		audio_bit_clk: in std_logic;
		audio_sdata_in: in std_logic; 
		audio_sdata_out: out std_logic; 
		audio_sync: out std_logic;
		audio_reset: out std_logic
	); end component;
	
	signal clk: std_logic;
	signal rst: std_logic;
	signal rst_async: std_logic;
	signal locked: std_logic;
	
	component chipscope_icon is port (
		control0: inout std_logic_vector(35 downto 0)
	); end component;
	signal control0: std_logic_vector(35 downto 0);
	component chipscope_ila is port (
		control: inout std_logic_vector(35 downto 0);
		clk: in std_logic;
		trig0: in std_logic_vector(4 downto 0)
	); end component;
	
	signal ac97_reset: std_logic;
	signal ac97_bit_clk: std_logic;
	signal ac97_sdata_in: std_logic;
	signal ac97_sdata_out: std_logic;
	signal ac97_sync: std_logic;
	
begin

rst_async <= not CPU_RESET_B;
LED_GPIO(0) <= '0';
LED_GPIO(1) <= '0';
LED_GPIO(2) <= '0';
LED_GPIO(3) <= '0';
LED_GPIO(4) <= '0';
LED_GPIO(5) <= '0';
LED_GPIO(6) <= '0';
LED_GPIO(7) <= locked;

PLL: clksynth port map (
	CLKIN1_IN => CLK_33MHZ,
	RST_IN => rst_async,
	CLKOUT0_OUT => clk,
	LOCKED_OUT => locked
);

SYNC_RST: process(clk, CPU_RESET_B)
begin
	if(rising_edge(clk)) then
		rst <= not CPU_RESET_B;
	end if;
end process SYNC_RST;

AUDIO_OUT: audio_output_top port map (
	clk => clk,
	rst => rst,
	audio_bit_clk => ac97_bit_clk,
	audio_sdata_in => ac97_sdata_in,
	audio_sdata_out => ac97_sdata_out,
	audio_sync => ac97_sync,
	audio_reset => ac97_reset
);

AUDIO_RESET <= ac97_reset;
ac97_bit_clk <= AUDIO_BIT_CLK;
AUDIO_SYNC <= ac97_sync;
ac97_sdata_in <= AUDIO_SDATA_IN ;
AUDIO_SDATA_OUT <= ac97_sdata_out;

--ICON: chipscope_icon port map ( control0 => control0 );
--ILA: chipscope_ila port map (control => control0,
--	clk => ac97_bit_clk,
--	trig0(0) => ac97_reset,
--	trig0(1) => ac97_sync,
--	trig0(2) => ac97_sdata_in,
--	trig0(3) => ac97_sdata_out,
--	trig0(4) => '0'
--);


end Behavioral;

