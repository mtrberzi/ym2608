----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:13:23 08/01/2014 
-- Design Name: 
-- Module Name:    phase_generator - Behavioral 
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

entity phase_generator is Port ( 
	clk : in  STD_LOGIC;
   rst : in  STD_LOGIC;
	
	dp: in unsigned(17 downto 0);
	detune: in unsigned(7 downto 0);
	bn: in unsigned(4 downto 0);
	multiple: in unsigned(3 downto 0);
	
	update: in std_logic;
	nxt: in std_logic;
	phase: out unsigned(31 downto 0)
); end phase_generator;

architecture Behavioral of phase_generator is
	type dttab_type is array(0 to 255) of signed(6 downto 0);
	constant dttab: dttab_type := (
	0 => to_signed(0, 7), 1 => to_signed(0, 7), 2 => to_signed(0, 7), 3 => to_signed(0, 7), 4 => to_signed(0, 7), 5 => to_signed(0, 7), 6 => to_signed(0, 7), 7 => to_signed(0, 7), 
8 => to_signed(0, 7), 9 => to_signed(0, 7), 10 => to_signed(0, 7), 11 => to_signed(0, 7), 12 => to_signed(0, 7), 13 => to_signed(0, 7), 14 => to_signed(0, 7), 15 => to_signed(0, 7), 
16 => to_signed(0, 7), 17 => to_signed(0, 7), 18 => to_signed(0, 7), 19 => to_signed(0, 7), 20 => to_signed(0, 7), 21 => to_signed(0, 7), 22 => to_signed(0, 7), 23 => to_signed(0, 7), 
24 => to_signed(0, 7), 25 => to_signed(0, 7), 26 => to_signed(0, 7), 27 => to_signed(0, 7), 28 => to_signed(0, 7), 29 => to_signed(0, 7), 30 => to_signed(0, 7), 31 => to_signed(0, 7), 
32 => to_signed(0, 7), 33 => to_signed(0, 7), 34 => to_signed(0, 7), 35 => to_signed(0, 7), 36 => to_signed(2, 7), 37 => to_signed(2, 7), 38 => to_signed(2, 7), 39 => to_signed(2, 7), 
40 => to_signed(2, 7), 41 => to_signed(2, 7), 42 => to_signed(2, 7), 43 => to_signed(2, 7), 44 => to_signed(4, 7), 45 => to_signed(4, 7), 46 => to_signed(4, 7), 47 => to_signed(4, 7), 
48 => to_signed(4, 7), 49 => to_signed(6, 7), 50 => to_signed(6, 7), 51 => to_signed(6, 7), 52 => to_signed(8, 7), 53 => to_signed(8, 7), 54 => to_signed(8, 7), 55 => to_signed(10, 7), 
56 => to_signed(10, 7), 57 => to_signed(12, 7), 58 => to_signed(12, 7), 59 => to_signed(14, 7), 60 => to_signed(16, 7), 61 => to_signed(16, 7), 62 => to_signed(16, 7), 63 => to_signed(16, 7), 
64 => to_signed(2, 7), 65 => to_signed(2, 7), 66 => to_signed(2, 7), 67 => to_signed(2, 7), 68 => to_signed(4, 7), 69 => to_signed(4, 7), 70 => to_signed(4, 7), 71 => to_signed(4, 7), 
72 => to_signed(4, 7), 73 => to_signed(6, 7), 74 => to_signed(6, 7), 75 => to_signed(6, 7), 76 => to_signed(8, 7), 77 => to_signed(8, 7), 78 => to_signed(8, 7), 79 => to_signed(10, 7), 
80 => to_signed(10, 7), 81 => to_signed(12, 7), 82 => to_signed(12, 7), 83 => to_signed(14, 7), 84 => to_signed(16, 7), 85 => to_signed(16, 7), 86 => to_signed(18, 7), 87 => to_signed(20, 7), 
88 => to_signed(22, 7), 89 => to_signed(24, 7), 90 => to_signed(26, 7), 91 => to_signed(28, 7), 92 => to_signed(32, 7), 93 => to_signed(32, 7), 94 => to_signed(32, 7), 95 => to_signed(32, 7), 
96 => to_signed(4, 7), 97 => to_signed(4, 7), 98 => to_signed(4, 7), 99 => to_signed(4, 7), 100 => to_signed(4, 7), 101 => to_signed(6, 7), 102 => to_signed(6, 7), 103 => to_signed(6, 7), 
104 => to_signed(8, 7), 105 => to_signed(8, 7), 106 => to_signed(8, 7), 107 => to_signed(10, 7), 108 => to_signed(10, 7), 109 => to_signed(12, 7), 110 => to_signed(12, 7), 111 => to_signed(14, 7), 
112 => to_signed(16, 7), 113 => to_signed(16, 7), 114 => to_signed(18, 7), 115 => to_signed(20, 7), 116 => to_signed(22, 7), 117 => to_signed(24, 7), 118 => to_signed(26, 7), 119 => to_signed(28, 7), 
120 => to_signed(32, 7), 121 => to_signed(34, 7), 122 => to_signed(38, 7), 123 => to_signed(40, 7), 124 => to_signed(44, 7), 125 => to_signed(44, 7), 126 => to_signed(44, 7), 127 => to_signed(44, 7), 
128 => to_signed(0, 7), 129 => to_signed(0, 7), 130 => to_signed(0, 7), 131 => to_signed(0, 7), 132 => to_signed(0, 7), 133 => to_signed(0, 7), 134 => to_signed(0, 7), 135 => to_signed(0, 7), 
136 => to_signed(0, 7), 137 => to_signed(0, 7), 138 => to_signed(0, 7), 139 => to_signed(0, 7), 140 => to_signed(0, 7), 141 => to_signed(0, 7), 142 => to_signed(0, 7), 143 => to_signed(0, 7), 
144 => to_signed(0, 7), 145 => to_signed(0, 7), 146 => to_signed(0, 7), 147 => to_signed(0, 7), 148 => to_signed(0, 7), 149 => to_signed(0, 7), 150 => to_signed(0, 7), 151 => to_signed(0, 7), 
152 => to_signed(0, 7), 153 => to_signed(0, 7), 154 => to_signed(0, 7), 155 => to_signed(0, 7), 156 => to_signed(0, 7), 157 => to_signed(0, 7), 158 => to_signed(0, 7), 159 => to_signed(0, 7), 
160 => to_signed(0, 7), 161 => to_signed(0, 7), 162 => to_signed(0, 7), 163 => to_signed(0, 7), 164 => to_signed(-2, 7), 165 => to_signed(-2, 7), 166 => to_signed(-2, 7), 167 => to_signed(-2, 7), 
168 => to_signed(-2, 7), 169 => to_signed(-2, 7), 170 => to_signed(-2, 7), 171 => to_signed(-2, 7), 172 => to_signed(-4, 7), 173 => to_signed(-4, 7), 174 => to_signed(-4, 7), 175 => to_signed(-4, 7), 
176 => to_signed(-4, 7), 177 => to_signed(-6, 7), 178 => to_signed(-6, 7), 179 => to_signed(-6, 7), 180 => to_signed(-8, 7), 181 => to_signed(-8, 7), 182 => to_signed(-8, 7), 183 => to_signed(-10, 7), 
184 => to_signed(-10, 7), 185 => to_signed(-12, 7), 186 => to_signed(-12, 7), 187 => to_signed(-14, 7), 188 => to_signed(-16, 7), 189 => to_signed(-16, 7), 190 => to_signed(-16, 7), 191 => to_signed(-16, 7), 
192 => to_signed(-2, 7), 193 => to_signed(-2, 7), 194 => to_signed(-2, 7), 195 => to_signed(-2, 7), 196 => to_signed(-4, 7), 197 => to_signed(-4, 7), 198 => to_signed(-4, 7), 199 => to_signed(-4, 7), 
200 => to_signed(-4, 7), 201 => to_signed(-6, 7), 202 => to_signed(-6, 7), 203 => to_signed(-6, 7), 204 => to_signed(-8, 7), 205 => to_signed(-8, 7), 206 => to_signed(-8, 7), 207 => to_signed(-10, 7), 
208 => to_signed(-10, 7), 209 => to_signed(-12, 7), 210 => to_signed(-12, 7), 211 => to_signed(-14, 7), 212 => to_signed(-16, 7), 213 => to_signed(-16, 7), 214 => to_signed(-18, 7), 215 => to_signed(-20, 7), 
216 => to_signed(-22, 7), 217 => to_signed(-24, 7), 218 => to_signed(-26, 7), 219 => to_signed(-28, 7), 220 => to_signed(-32, 7), 221 => to_signed(-32, 7), 222 => to_signed(-32, 7), 223 => to_signed(-32, 7), 
224 => to_signed(-4, 7), 225 => to_signed(-4, 7), 226 => to_signed(-4, 7), 227 => to_signed(-4, 7), 228 => to_signed(-4, 7), 229 => to_signed(-6, 7), 230 => to_signed(-6, 7), 231 => to_signed(-6, 7), 
232 => to_signed(-8, 7), 233 => to_signed(-8, 7), 234 => to_signed(-8, 7), 235 => to_signed(-10, 7), 236 => to_signed(-10, 7), 237 => to_signed(-12, 7), 238 => to_signed(-12, 7), 239 => to_signed(-14, 7), 
240 => to_signed(-16, 7), 241 => to_signed(-16, 7), 242 => to_signed(-18, 7), 243 => to_signed(-20, 7), 244 => to_signed(-22, 7), 245 => to_signed(-24, 7), 246 => to_signed(-26, 7), 247 => to_signed(-28, 7), 
248 => to_signed(-32, 7), 249 => to_signed(-34, 7), 250 => to_signed(-38, 7), 251 => to_signed(-40, 7), 252 => to_signed(-44, 7), 253 => to_signed(-44, 7), 254 => to_signed(-44, 7), 255 => to_signed(-44, 7)
	);

	signal pgdcount: unsigned(31 downto 0) := to_unsigned(0, 32); -- delta-Phase
	signal pgdcount_next: unsigned(31 downto 0);
	signal pgcount: unsigned(31 downto 0) := to_unsigned(0, 32); -- Phase
	
	signal dttab_idx: unsigned(7 downto 0);
	signal dttab_entry: signed(6 downto 0);
	signal phase_dt: signed(18 downto 0);
	signal multiple_scale: unsigned(4 downto 0);
	signal rr_scale: unsigned(12 downto 0);
	signal pgdcount_s: signed(32 downto 0);
	
	constant rr: unsigned(7 downto 0) := to_unsigned(148, 8); -- assuming f = 7.968MHz, r = 48kHz
begin

-- compute next delta-phase

dttab_idx <= detune + bn;
dttab_entry <= dttab(to_integer(dttab_idx));
phase_dt <= signed("0" & dp) + dttab_entry;
multiple_scale <= unsigned(multiple & "0");
rr_scale <= (to_unsigned(1, 5) * rr) when (multiple = "0000") else (multiple_scale * rr);
pgdcount_s <= phase_dt * signed("0" & rr_scale);
pgdcount_next <= unsigned(pgdcount_s(31 downto 0));

-- update delta-phase
UPDATE_PGDCOUNT: process(clk, rst, update, pgdcount, pgdcount_next)
	variable v: unsigned(31 downto 0);
begin
	v := pgdcount;
	if(rst = '1') then
		v := to_unsigned(0, 32);
	elsif(update = '1') then
		v := pgdcount_next;
	end if;
	
	if(rising_edge(clk)) then
		pgdcount <= v;
	end if;
end process UPDATE_PGDCOUNT;

-- calculate next phase
PHASEGEN: process(clk, rst, nxt, pgcount, pgdcount)
	variable v: unsigned(31 downto 0);
begin
	v := pgcount;
	if(rst = '1') then
		v := to_unsigned(0, 32);
	elsif(nxt = '1') then
		v := pgcount + pgdcount;
	end if;
	
	if(rising_edge(clk)) then
		pgcount <= v;
	end if;
end process PHASEGEN;

-- output
phase <= pgcount;

end Behavioral;

