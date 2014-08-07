----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:06:08 08/04/2014 
-- Design Name: 
-- Module Name:    envelope_generator - Behavioral 
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

entity envelope_generator is port ( 
	clk : in  STD_LOGIC;
   rst : in  STD_LOGIC;
	
	update: in std_logic;
	update_ack: out std_logic;
	keyOn: in std_logic;
	attackRate: in unsigned(5 downto 0);
	decayRate: in unsigned(5 downto 0);
	sustainRate: in unsigned(5 downto 0);
	sustainLevel: in unsigned(6 downto 0);
	releaseRate: in unsigned(5 downto 0);
	keyscale: in unsigned(1 downto 0);
	blockNumber: unsigned(4 downto 0);

	nxt: in std_logic;
	eglevel: out unsigned(9 downto 0);
	valid: out std_logic
); end envelope_generator;

architecture Behavioral of envelope_generator is
	type ratetable_type is array(0 to 63) of signed(31 downto 0);
	constant ratetable: ratetable_type := (
		0 => to_signed(0,32), 1 => to_signed(0,32), 2 => to_signed(0,32), 3 => to_signed(0,32),
		4 => to_signed(75552,32), 5 => to_signed(75552,32), 6 => to_signed(113328,32), 7 => to_signed(113328,32),
		8 => to_signed(151104,32), 9 => to_signed(188880,32), 10 => to_signed(226656,32), 11 => to_signed(264432,32),
		12 => to_signed(302208,32), 13 => to_signed(377760,32), 14 => to_signed(453312,32), 15 => to_signed(528864,32),
		16 => to_signed(604416,32), 17 => to_signed(755520,32), 18 => to_signed(906624,32), 19 => to_signed(1057728,32),
		20 => to_signed(1208832,32), 21 => to_signed(1511040,32), 22 => to_signed(1813248,32), 23 => to_signed(2115456,32),
		24 => to_signed(2417664,32), 25 => to_signed(3022080,32), 26 => to_signed(3626496,32), 27 => to_signed(4230912,32),
		28 => to_signed(4835328,32), 29 => to_signed(6044160,32), 30 => to_signed(7252992,32), 31 => to_signed(8461824,32),
		32 => to_signed(9670656,32), 33 => to_signed(12088320,32), 34 => to_signed(14505984,32), 35 => to_signed(16923648,32),
		36 => to_signed(19341312,32), 37 => to_signed(24176640,32), 38 => to_signed(29011968,32), 39 => to_signed(33847296,32),
		40 => to_signed(38682624,32), 41 => to_signed(48353280,32), 42 => to_signed(58023936,32), 43 => to_signed(67694592,32),
		44 => to_signed(77365248,32), 45 => to_signed(96706560,32), 46 => to_signed(116047872,32), 47 => to_signed(135389184,32),
		48 => to_signed(77365248,32), 49 => to_signed(96706560,32), 50 => to_signed(116047872,32), 51 => to_signed(135389184,32),
		52 => to_signed(77365248,32), 53 => to_signed(96706560,32), 54 => to_signed(116047872,32), 55 => to_signed(135389184,32),
		56 => to_signed(77365248,32), 57 => to_signed(96706560,32), 58 => to_signed(116047872,32), 59 => to_signed(135389184,32),
		60 => to_signed(154730496,32), 61 => to_signed(154730496,32), 62 => to_signed(154730496,32), 63 => to_signed(154730496,32)
	);
	-- increment by 3<<27
	constant egstep_increment: signed(31 downto 0) := to_signed(402653184, 32);
	
	type eg_state_type is (state_idle, state_prepare_rate, state_setegrate, state_shiftphase, state_prepare_ack,
		state_envelope_check, state_envelope_checklevel_attack, state_envelope_checklevel_other,
		state_envelope_done);
	type adsr_state_type is (adsr_attack, adsr_decay, adsr_sustain, adsr_release, adsr_off);
	
	type reg_type is record
		state: eg_state_type;
		adsr_state: adsr_state_type;
		keyOff_req: std_logic;
		keyOn_req: std_logic;
		egstep: signed(31 downto 0);
		update_req: std_logic;
		update_ack: std_logic;
		key: std_logic;
		ksr: unsigned(4 downto 0);
		egstepd: signed(31 downto 0);
		egtransa: unsigned(3 downto 0);
		egtransd: unsigned(3 downto 0);
		egrate: unsigned(5 downto 0); -- intermediate for SetEGRate
		setegrate_callback: eg_state_type; -- where to go after SetEGRate
		shiftphase: adsr_state_type; -- desired "next phase" for ShiftPhase
		shiftphase_callback: eg_state_type; -- where to go after ShiftPhase
		eglevel: unsigned(9 downto 0);
		eglvnext: unsigned(9 downto 0);
		nxt_req: std_logic; -- latched high when nxt is strobed
		valid: std_logic;
	end record;
	
	constant reg_reset: reg_type := (
		state => state_idle,
		adsr_state => adsr_off,
		keyOff_req => '0',
		keyOn_req => '0',
		egstep => to_signed(0, 32),
		update_req => '0',
		update_ack => '0',
		key => '0',
		ksr => "00000",
		egstepd => to_signed(0, 32),
		egtransa => "0000",
		egtransd => "0000",
		egrate => "000000",
		setegrate_callback => state_idle,
		shiftphase => adsr_off,
		shiftphase_callback => state_idle,
		eglevel => "0011111111",
		eglvnext => to_unsigned(0, 10),
		nxt_req => '0',
		valid => '0'
	);
	
	signal reg: reg_type := reg_reset;
	signal ci_next: reg_type;
begin

COMB: process(reg, rst, update, nxt, keyOn,
	attackRate, decayRate, sustainRate, sustainLevel, releaseRate, keyscale, blockNumber)
	variable ci: reg_type;
	
	variable egtransa: unsigned(5 downto 0);
	variable egtransa_sized: unsigned(3 downto 0);
	variable egtransd: unsigned(3 downto 0);
	
	variable eglevel_attack_decrement: unsigned(9 downto 0);
begin
	ci := reg;
	-- self-clearing
	ci.update_ack := '0';
	ci.valid := '0';
	
	-- always check these "asynchronously", i.e. while other processing is happening
	if(reg.key = '1' and keyOn = '0') then
		ci.key := '0';
		ci.keyOff_req := '1';
	end if;
	if(reg.key = '0' and keyOn = '1') then
		ci.key := '1';
		ci.keyOn_req := '1';
	end if;
	if(reg.update_req = '0' and update = '1') then
		ci.update_req := '1';
	end if;
	if(reg.nxt_req = '0' and nxt = '1') then
		ci.nxt_req := '1';
	end if;
	
	-- egtransa = Limit(15 - r>>2, 4, 1)
	egtransa := 15 - shift_right(reg.egrate, 2);
	if(egtransa > 4) then
		egtransa_sized := to_unsigned(4, 4);
	elsif(egtransa < 1) then
		egtransa_sized := to_unsigned(1, 4);
	else
		egtransa_sized := unsigned("0" & egtransa(2 downto 0));
	end if;
	-- egtransd = 16 >> egtransa
	case egtransa_sized is
		when "0001" =>
			egtransd := "1000";
		when "0010" =>
			egtransd := "0100";
		when "0011" =>
			egtransd := "0010";
		when "0100" =>
			egtransd := "0001";
		when others => -- shouldn't happen
			egtransd := "0000";
	end case;
	eglevel_attack_decrement := (1 + shift_right(reg.eglevel, to_integer(reg.egtransa)));
	
	if(rst = '1') then
		ci := reg_reset;
	else
		case reg.state is
			when state_idle =>
				-- check for key-on/key-off first; key-off has priority
				if(reg.keyOff_req = '1') then
					ci.keyOff_req := '0';
					-- Key Off
					ci.shiftphase := adsr_release;
					ci.state := state_shiftphase;
					ci.shiftphase_callback := state_idle;
				elsif(reg.keyOn_req = '1') then
					ci.keyOn_req := '0';
					-- Key On
					if(reg.adsr_state = adsr_off or reg.adsr_state = adsr_release) then
						ci.shiftphase := adsr_attack;
						ci.state := state_shiftphase;
						ci.shiftphase_callback := state_idle;
					else
						ci.state := state_envelope_check;
					end if;
				elsif(reg.update_req = '1') then
					ci.update_req := '0';
					-- calculate ksr (key-scale rate)
					-- ksr = bn >> (3 - ks)
					ci.ksr := shift_right(blockNumber, to_integer(keyscale));
					ci.state := state_prepare_rate;
				elsif(reg.nxt_req = '1') then
					ci.nxt_req := '0';
					-- decrement egstep
					ci.egstep := reg.egstep - reg.egstepd;
					ci.state := state_envelope_check;
				end if;
			when state_setegrate => -- "function call"
				ci.egstepd := ratetable(to_integer(reg.egrate));
				ci.egtransa := egtransa_sized;
				ci.egtransd := egtransd;
				ci.state := reg.setegrate_callback;
			when state_shiftphase => -- "function call"
				case reg.shiftphase is
					when adsr_attack =>
						if(attackRate + reg.ksr < to_unsigned(62, 7)) then
							if(attackRate = "000000") then
								ci.egrate := to_unsigned(0, 6);
							else
								ci.egrate := attackRate + reg.ksr;
							end if;
							ci.setegrate_callback := reg.shiftphase_callback;
							ci.state := state_setegrate;
							ci.adsr_state := adsr_attack;
						else
							ci.shiftphase := adsr_decay;
						end if;
					when adsr_decay =>
						if(sustainLevel = "0000000") then
							ci.shiftphase := adsr_sustain;
						else
							ci.eglevel := to_unsigned(0, 10);
							ci.eglvnext := unsigned(sustainLevel & "000"); -- sl * 8
							if(decayRate = "000000") then
								ci.egrate := to_unsigned(0, 6);
							elsif(decayRate + reg.ksr < to_unsigned(63, 7)) then
								ci.egrate := decayRate + reg.ksr;
							else
								ci.egrate := to_unsigned(63, 6);
							end if;
							ci.setegrate_callback := reg.shiftphase_callback;
							ci.state := state_setegrate;
							ci.adsr_state := adsr_decay;
						end if;
					when adsr_sustain =>
						ci.eglevel := unsigned(sustainLevel & "000"); -- sl * 8
						ci.eglvnext := "0100000000";
						if(sustainRate = "000000") then
							ci.egrate := to_unsigned(0, 6);
						elsif(sustainRate + reg.ksr < to_unsigned(63, 7)) then
							ci.egrate := sustainRate + reg.ksr;
						else
							ci.egrate := to_unsigned(63, 6);
						end if;
						ci.setegrate_callback := reg.shiftphase_callback;
						ci.state := state_setegrate;
						ci.adsr_state := adsr_sustain;
					when adsr_release =>
						if(reg.adsr_state = adsr_attack or reg.eglevel < 256) then
							ci.eglvnext := "0100000000";
							if(releaseRate + reg.ksr < to_unsigned(63, 7)) then
								ci.egrate := releaseRate + reg.ksr;
							else
								ci.egrate := to_unsigned(63, 6);
							end if;
							ci.setegrate_callback := reg.shiftphase_callback;
							ci.state := state_setegrate;
							ci.adsr_state := adsr_release;
						else
							ci.shiftphase := adsr_off;
						end if;
					when others =>
						-- off
						ci.eglevel := "0011111111";
						ci.eglvnext := "0100000000";
						-- SetEGRate(0)
						ci.egrate := to_unsigned(0, 6);
						ci.setegrate_callback := reg.shiftphase_callback;
						ci.state := state_setegrate;
						ci.adsr_state := adsr_off;
				end case;
			when state_envelope_check =>
				if(reg.egstep > 0) then
					-- stop here, do not change envelope
					ci.valid := '1';
					ci.state := state_idle;
				else
					ci.egstep := reg.egstep + egstep_increment;
					if(reg.adsr_state = adsr_attack) then
						-- decrement eglevel by (1 + eglevel >> egtransa) but do not let it become negative
						if(eglevel_attack_decrement > reg.eglevel) then
							ci.eglevel := to_unsigned(0, 10);
						else
							ci.eglevel := reg.eglevel - eglevel_attack_decrement;
						end if;
						ci.state := state_envelope_checklevel_attack;
					else
						-- increment eglevel by egtransd
						ci.eglevel := reg.eglevel + reg.egtransd;
						ci.state := state_envelope_checklevel_other;
					end if;
				end if;
			when state_envelope_checklevel_attack =>
				if(reg.eglevel <= 0) then
					-- ShiftPhase to decay
					ci.state := state_shiftphase;
					ci.shiftphase := adsr_decay;
					ci.shiftphase_callback := state_envelope_done;
				else
					-- done
					ci.valid := '1';
					ci.state := state_idle;
				end if;
			when state_envelope_checklevel_other =>
				if(reg.eglevel >= reg.eglvnext) then
					-- ShiftPhase to next phase
					case reg.adsr_state is
						when adsr_attack => ci.shiftphase := adsr_decay;
						when adsr_decay => ci.shiftphase := adsr_sustain;
						when adsr_sustain => ci.shiftphase := adsr_release;
						when adsr_release => ci.shiftphase := adsr_off;
						when others => -- should never happen...
							ci.shiftphase := adsr_off;
					end case;
					ci.state := state_shiftphase;
					ci.shiftphase_callback := state_envelope_done;
				else
					-- done
					ci.valid := '1';
					ci.state := state_idle;
				end if;
			when state_envelope_done =>
				ci.valid := '1';
				ci.state := state_idle;
			when state_prepare_rate =>
				case reg.adsr_state is
					-- load egrate and "call" SetEGRate()
					when adsr_attack =>
						if(attackRate = "000000") then
							ci.egrate := "000000";
						elsif(attackRate + reg.ksr > to_unsigned(63, 7)) then
							ci.egrate := "111111";
						else
							ci.egrate := attackRate + reg.ksr;
						end if;
						ci.setegrate_callback := state_prepare_ack;
						ci.state := state_setegrate;
					when adsr_decay =>
						if(decayRate = "000000") then
							ci.egrate := "000000";
						elsif(decayRate + reg.ksr > to_unsigned(63, 7)) then
							ci.egrate := "111111";
						else
							ci.egrate := decayRate + reg.ksr;
						end if;
						ci.setegrate_callback := state_prepare_ack;
						ci.state := state_setegrate;
					when adsr_sustain =>
						if(sustainRate = "000000") then
							ci.egrate := "000000";
						elsif(sustainRate + reg.ksr > to_unsigned(63, 7)) then
							ci.egrate := "111111";
						else
							ci.egrate := sustainRate + reg.ksr;
						end if;
						ci.setegrate_callback := state_prepare_ack;
						ci.state := state_setegrate;
					when adsr_release =>
						if(releaseRate + reg.ksr > to_unsigned(63, 7)) then
							ci.egrate := "111111";
						else
							ci.egrate := releaseRate + reg.ksr;
						end if;
						ci.setegrate_callback := state_prepare_ack;
						ci.state := state_setegrate;
					when others =>
						ci.state := state_prepare_ack;
				end case;
			when state_prepare_ack =>
				ci.update_ack := '1';
				ci.state := state_idle;
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

-- outputs
update_ack <= reg.update_ack;
eglevel <= reg.eglevel;
valid <= reg.valid;

end Behavioral;

