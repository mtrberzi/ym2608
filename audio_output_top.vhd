----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:22:34 08/02/2014 
-- Design Name: 
-- Module Name:    audio_output_top - Behavioral 
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

entity audio_output_top is Port ( 
	clk : in  STD_LOGIC; -- about 8 MHz (7.968MHz should be okay)
   rst : in  STD_LOGIC;
	
	-- AC97
	audio_bit_clk: in std_logic;
	audio_sdata_in: in std_logic; -- from codec
	audio_sdata_out: out std_logic; -- to codec
	audio_sync: out std_logic;
	audio_reset: out std_logic
); end audio_output_top;

architecture Behavioral of audio_output_top is
	signal rst_b: std_logic;
	component ac97_top port (
		clk_i: in std_logic;
		rst_i: in std_logic;
		wb_data_i: in std_logic_vector(31 downto 0);
		wb_data_o: out std_logic_vector(31 downto 0);
		wb_addr_i: in std_logic_vector(31 downto 0);
		wb_sel_i: in std_logic_vector(3 downto 0);
		wb_we_i: in std_logic;
		wb_cyc_i: in std_logic;
		wb_stb_i: in std_logic;
		wb_ack_o: out std_logic;
		wb_err_o: out std_logic;
		int_o: out std_logic;
		dma_req_o: out std_logic_vector(8 downto 0);
		dma_ack_i: in std_logic_vector(8 downto 0);
		suspended_o: out std_logic;
		bit_clk_pad_i: in std_logic;
		sync_pad_o: out std_logic;
		sdata_pad_o: out std_logic;
		sdata_pad_i: in std_logic;
		ac97_reset_pad_o: out std_logic
	); end component;
	
	signal din: std_logic_vector(31 downto 0);
	signal ack: std_logic;
	signal err: std_logic;

	type state_type is (state_reset, state_cold_reset_1, state_cold_reset_2, state_enable_och_1, state_enable_och_2, 
		state_unmute_master_1, state_unmute_master_2, state_unmute_out_1, state_unmute_out_2,
		state_idle,
		state_output_left_1, state_output_left_2, state_output_right_1, state_output_right_2);

	type reg_type is record
		state: state_type;
		stall_timer: unsigned(15 downto 0);
		sample_timer: unsigned(7 downto 0);
		sample_timer_run: std_logic;
		nxt: std_logic;
		addr: std_logic_vector(31 downto 0);
		data: std_logic_vector(31 downto 0);
		sel: std_logic_vector(3 downto 0);
		we: std_logic;
		cyc: std_logic;
		stb: std_logic;
	end record;

	constant reg_reset: reg_type := (
		state => state_reset,
		stall_timer => X"0000",
		sample_timer => X"00",
		sample_timer_run => '0',
		nxt => '0',
		addr => X"00000000",
		data => X"00000000",
		sel => X"0",
		we => '0',
		cyc => '0',
		stb => '0'
	);
	
	component signal_generator_square port ( 
		clk : in  STD_LOGIC;
		nxt : in  STD_LOGIC;
		sample: out signed(19 downto 0)
	); end component;

	-- 166 * 48kHz = 7.968MHz
	constant sample_period: unsigned(7 downto 0) := to_unsigned(166-1, 8);
	signal sample: signed(19 downto 0) := to_signed(0, 20);
	
	signal reg: reg_type := reg_reset;
	signal ci_next: reg_type;

begin

COMB: process(reg, rst, din, ack, err, sample)
	variable ci: reg_type;
begin
	ci := reg;
	-- self-clearing
	ci.nxt := '0';
	
	if(reg.sample_timer_run = '1') then
		if(reg.sample_timer = X"00") then
			ci.sample_timer := sample_period;
		else
			ci.sample_timer := reg.sample_timer - 1;
		end if;
	end if;
	
	if(reg.stall_timer = X"0000") then
		ci.stall_timer := reg.stall_timer;
	else
		ci.stall_timer := reg.stall_timer - 1;
	end if;
	
	if(rst = '1') then
		ci := reg_reset;
	else
		case reg.state is
			when state_reset =>
				ci.state := state_cold_reset_1;
			when state_cold_reset_1 =>
				ci.addr(7 downto 0) := X"00";
				ci.data := X"00000001";
				ci.cyc := '1';
				ci.stb := '1';
				ci.we := '1';
				ci.sel := "0011";
				ci.state := state_cold_reset_2;
			when state_cold_reset_2 =>
				-- wait for ACK or ERR
				if(ack = '1' or err = '1') then
					-- terminate cycle
					ci.cyc := '0';
					ci.stb := '0';
					ci.we := '0';
					ci.state := state_enable_och_1;
					ci.stall_timer := X"FFFF";
				end if;
			when state_enable_och_1 =>
				if(reg.stall_timer = X"0000") then
					ci.addr(7 downto 0) := X"04";
					ci.data := X"00" & X"00" & "00001001" & "00001001"; -- 20-bit samples on L/R, and enable
					ci.cyc := '1';
					ci.stb := '1';
					ci.we := '1';
					ci.sel := "0011";
					ci.state := state_enable_och_2;
				end if;
			when state_enable_och_2 =>
				-- wait for ACK or ERR
				if(ack = '1' or err = '1') then
					-- terminate cycle
					ci.cyc := '0';
					ci.stb := '0';
					ci.we := '0';
					ci.state := state_unmute_master_1;
					ci.stall_timer := X"FFFF";
				end if;
			when state_unmute_master_1 => 
				if(reg.stall_timer = X"0000") then
					ci.addr(7 downto 0) := X"10"; -- codec reg
					ci.data := "0" & X"00" & "0000010" & X"0000"; -- write 0x00 to $02
					ci.cyc := '1';
					ci.stb := '1';
					ci.we := '1';
					ci.sel := "1111";
					ci.state := state_unmute_master_2;
				end if;
			when state_unmute_master_2 => 
				if(ack = '1' or err = '1') then
					ci.cyc := '0';
					ci.stb := '0';
					ci.we := '0';
					ci.state := state_unmute_out_1;
					ci.stall_timer := X"FFFF";
				end if;
			when state_unmute_out_1 =>
				if(reg.stall_timer = X"0000") then
					ci.addr(7 downto 0) := X"10"; -- codec reg
					ci.data := "0" & X"00" & "0011000" & X"0000"; -- write 0x00 to $18
					ci.cyc := '1';
					ci.stb := '1';
					ci.we := '1';
					ci.sel := "1111";
					ci.state := state_unmute_out_2;
				end if;
			when state_unmute_out_2 => 
				if(ack = '1' or err = '1') then
					ci.cyc := '0';
					ci.stb := '0';
					ci.we := '0';
					ci.sample_timer_run := '1';
					ci.state := state_idle;
				end if;
			when state_idle =>
				if(reg.sample_timer = X"00") then
					ci.nxt := '1';
					-- buffer sample on data-out
					ci.data(31 downto 20) := (others=>'0');
					ci.data(19 downto 0) := std_logic_vector(sample);
					ci.sel := "1111";
					ci.cyc := '1';
					ci.state := state_output_left_1;
				end if;
			when state_output_left_1 =>
				ci.addr(7 downto 0) := X"20";
				ci.stb := '1';
				ci.we := '1';
				ci.state := state_output_left_2;
			when state_output_left_2 =>
				if(ack = '1' or err = '1') then
					ci.stb := '0';
					ci.we := '0';
					ci.state := state_output_right_1;
				end if;
			when state_output_right_1 =>
				ci.addr(7 downto 0) := X"24";
				ci.stb := '1';
				ci.we := '1';
				ci.state := state_output_right_2;
			when state_output_right_2 =>
				if(ack = '1' or err = '1') then
					ci.stb := '0';
					ci.we := '0';
					ci.cyc := '0';
					ci.state := state_idle;
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

rst_b <= not rst;
AC97: ac97_top port map (
	clk_i => clk,
	rst_i => rst_b,
	wb_data_i => reg.data,
	wb_data_o => din,
	wb_addr_i => reg.addr,
	wb_sel_i => reg.sel,
	wb_we_i => reg.we,
	wb_cyc_i => reg.cyc,
	wb_stb_i => reg.stb,
	wb_ack_o => ack,
	wb_err_o => err,
	int_o => open,
	dma_req_o => open,
	dma_ack_i => "000000000",
	suspended_o => open,
	bit_clk_pad_i => audio_bit_clk,
	sync_pad_o => audio_sync,
	sdata_pad_o => audio_sdata_out,
	sdata_pad_i => audio_sdata_in,
	ac97_reset_pad_o => audio_reset
);

SIGGEN: signal_generator_square port map (
	clk => clk,
	nxt => reg.nxt,
	sample => sample
);


end Behavioral;

