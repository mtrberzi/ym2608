----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:12:14 08/01/2014 
-- Design Name: 
-- Module Name:    fm_channel - Behavioral 
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

entity fm_channel is Port ( 
	 clk : in  STD_LOGIC;
	 rst : in  STD_LOGIC;
	 
	 addr: in std_logic_vector(8 downto 0);
	 we: in std_logic;
	 data: in std_logic_vector(7 downto 0);
	 
	 key: in std_logic_vector(3 downto 0);
	 nxt: in std_logic;
	 output: out signed(17 downto 0);
	 valid: out std_logic
);
end fm_channel;

architecture Behavioral of fm_channel is
	type buffer4_type is array(0 to 3) of signed(17 downto 0);
	constant buffer4_reset: buffer4_type := (
		0 => to_signed(0, 18),
		1 => to_signed(0, 18),
		2 => to_signed(0, 18),
		3 => to_signed(0, 18)
	);
	type algorithm_idx_type is array(0 to 5) of unsigned(1 downto 0);
	-- algorithm definitions and table
	
	-- in the original code, the indices correspond to table entries like this:
	-- idx 0 gets table entry 0
	-- idx 1 gets table entry 2
	-- idx 2 gets table entry 4
	-- idx 3 gets table entry 1
	-- idx 4 gets table entry 3
	-- idx 5 gets table entry 5
	constant algorithm0: algorithm_idx_type := (
		0 => to_unsigned(0, 2),
		3 => to_unsigned(1, 2),
		1 => to_unsigned(1, 2),
		4 => to_unsigned(2, 2),
		2 => to_unsigned(2, 2),
		5 => to_unsigned(3, 2)
	);
	constant algorithm1: algorithm_idx_type := (
		0 => to_unsigned(1, 2),
		3 => to_unsigned(0, 2),
		1 => to_unsigned(0, 2),
		4 => to_unsigned(1, 2),
		2 => to_unsigned(1, 2),
		5 => to_unsigned(2, 2)
	);
	constant algorithm2: algorithm_idx_type := (
		0 => to_unsigned(1, 2),
		3 => to_unsigned(1, 2),
		1 => to_unsigned(1, 2),
		4 => to_unsigned(0, 2),
		2 => to_unsigned(0, 2),
		5 => to_unsigned(2, 2)
	);
	constant algorithm3: algorithm_idx_type := (
		0 => to_unsigned(0, 2),
		3 => to_unsigned(1, 2),
		1 => to_unsigned(2, 2),
		4 => to_unsigned(1, 2),
		2 => to_unsigned(1, 2),
		5 => to_unsigned(2, 2)
	);
	constant algorithm4: algorithm_idx_type := (
		0 => to_unsigned(0, 2),
		3 => to_unsigned(1, 2),
		1 => to_unsigned(2, 2),
		4 => to_unsigned(2, 2),
		2 => to_unsigned(2, 2),
		5 => to_unsigned(1, 2)
	);
	constant algorithm5: algorithm_idx_type := (
		0 => to_unsigned(0, 2),
		3 => to_unsigned(1, 2),
		1 => to_unsigned(0, 2),
		4 => to_unsigned(1, 2),
		2 => to_unsigned(0, 2),
		5 => to_unsigned(1, 2)
	);
	constant algorithm6: algorithm_idx_type := (
		0 => to_unsigned(0, 2),
		3 => to_unsigned(1, 2),
		1 => to_unsigned(2, 2),
		4 => to_unsigned(1, 2),
		2 => to_unsigned(2, 2),
		5 => to_unsigned(1, 2)
	);
	constant algorithm7: algorithm_idx_type := (
		0 => to_unsigned(1, 2),
		3 => to_unsigned(0, 2),
		1 => to_unsigned(1, 2),
		4 => to_unsigned(0, 2),
		2 => to_unsigned(1, 2),
		5 => to_unsigned(0, 2)
	);
	-- notetab for bn
	type notetab_type is array(0 to 127) of unsigned(4 downto 0);
	constant notetab: notetab_type := (
		0 => to_unsigned(0, 5), 1 => to_unsigned(0, 5), 2 => to_unsigned(0, 5), 3 => to_unsigned(0, 5), 
		4 => to_unsigned(0, 5), 5 => to_unsigned(0, 5), 6 => to_unsigned(0, 5), 7 => to_unsigned(1, 5), 
		8 => to_unsigned(2, 5), 9 => to_unsigned(3, 5), 10 => to_unsigned(3, 5), 11 => to_unsigned(3, 5), 
		12 => to_unsigned(3, 5), 13 => to_unsigned(3, 5), 14 => to_unsigned(3, 5), 15 => to_unsigned(3, 5), 
		16 => to_unsigned(4, 5), 17 => to_unsigned(4, 5), 18 => to_unsigned(4, 5), 19 => to_unsigned(4, 5), 
		20 => to_unsigned(4, 5), 21 => to_unsigned(4, 5), 22 => to_unsigned(4, 5), 23 => to_unsigned(5, 5), 
		24 => to_unsigned(6, 5), 25 => to_unsigned(7, 5), 26 => to_unsigned(7, 5), 27 => to_unsigned(7, 5), 
		28 => to_unsigned(7, 5), 29 => to_unsigned(7, 5), 30 => to_unsigned(7, 5), 31 => to_unsigned(7, 5), 
		32 => to_unsigned(8, 5), 33 => to_unsigned(8, 5), 34 => to_unsigned(8, 5), 35 => to_unsigned(8, 5), 
		36 => to_unsigned(8, 5), 37 => to_unsigned(8, 5), 38 => to_unsigned(8, 5), 39 => to_unsigned(9, 5), 
		40 => to_unsigned(10, 5), 41 => to_unsigned(11, 5), 42 => to_unsigned(11, 5), 43 => to_unsigned(11, 5), 
		44 => to_unsigned(11, 5), 45 => to_unsigned(11, 5), 46 => to_unsigned(11, 5), 47 => to_unsigned(11, 5), 
		48 => to_unsigned(12, 5), 49 => to_unsigned(12, 5), 50 => to_unsigned(12, 5), 51 => to_unsigned(12, 5), 
		52 => to_unsigned(12, 5), 53 => to_unsigned(12, 5), 54 => to_unsigned(12, 5), 55 => to_unsigned(13, 5), 
		56 => to_unsigned(14, 5), 57 => to_unsigned(15, 5), 58 => to_unsigned(15, 5), 59 => to_unsigned(15, 5), 
		60 => to_unsigned(15, 5), 61 => to_unsigned(15, 5), 62 => to_unsigned(15, 5), 63 => to_unsigned(15, 5), 
		64 => to_unsigned(16, 5), 65 => to_unsigned(16, 5), 66 => to_unsigned(16, 5), 67 => to_unsigned(16, 5), 
		68 => to_unsigned(16, 5), 69 => to_unsigned(16, 5), 70 => to_unsigned(16, 5), 71 => to_unsigned(17, 5), 
		72 => to_unsigned(18, 5), 73 => to_unsigned(19, 5), 74 => to_unsigned(19, 5), 75 => to_unsigned(19, 5), 
		76 => to_unsigned(19, 5), 77 => to_unsigned(19, 5), 78 => to_unsigned(19, 5), 79 => to_unsigned(19, 5), 
		80 => to_unsigned(20, 5), 81 => to_unsigned(20, 5), 82 => to_unsigned(20, 5), 83 => to_unsigned(20, 5), 
		84 => to_unsigned(20, 5), 85 => to_unsigned(20, 5), 86 => to_unsigned(20, 5), 87 => to_unsigned(21, 5), 
		88 => to_unsigned(22, 5), 89 => to_unsigned(23, 5), 90 => to_unsigned(23, 5), 91 => to_unsigned(23, 5), 
		92 => to_unsigned(23, 5), 93 => to_unsigned(23, 5), 94 => to_unsigned(23, 5), 95 => to_unsigned(23, 5), 
		96 => to_unsigned(24, 5), 97 => to_unsigned(24, 5), 98 => to_unsigned(24, 5), 99 => to_unsigned(24, 5), 
		100 => to_unsigned(24, 5), 101 => to_unsigned(24, 5), 102 => to_unsigned(24, 5), 103 => to_unsigned(25, 5), 
		104 => to_unsigned(26, 5), 105 => to_unsigned(27, 5), 106 => to_unsigned(27, 5), 107 => to_unsigned(27, 5), 
		108 => to_unsigned(27, 5), 109 => to_unsigned(27, 5), 110 => to_unsigned(27, 5), 111 => to_unsigned(27, 5), 
		112 => to_unsigned(28, 5), 113 => to_unsigned(28, 5), 114 => to_unsigned(28, 5), 115 => to_unsigned(28, 5), 
		116 => to_unsigned(28, 5), 117 => to_unsigned(28, 5), 118 => to_unsigned(28, 5), 119 => to_unsigned(29, 5), 
		120 => to_unsigned(30, 5), 121 => to_unsigned(31, 5), 122 => to_unsigned(31, 5), 123 => to_unsigned(31, 5), 
		124 => to_unsigned(31, 5), 125 => to_unsigned(31, 5), 126 => to_unsigned(31, 5), 127 => to_unsigned(31, 5)
	);
	
	type cltab_type is array(0 to 1023) of unsigned(7 downto 0);
	constant cltab: cltab_type := (
	0 => to_unsigned(255, 8), 1 => to_unsigned(252, 8), 2 => to_unsigned(249, 8), 3 => to_unsigned(246, 8), 
	4 => to_unsigned(244, 8), 5 => to_unsigned(241, 8), 6 => to_unsigned(238, 8), 7 => to_unsigned(236, 8), 
	8 => to_unsigned(233, 8), 9 => to_unsigned(231, 8), 10 => to_unsigned(228, 8), 11 => to_unsigned(226, 8), 
	12 => to_unsigned(223, 8), 13 => to_unsigned(221, 8), 14 => to_unsigned(219, 8), 15 => to_unsigned(216, 8), 
	16 => to_unsigned(214, 8), 17 => to_unsigned(212, 8), 18 => to_unsigned(209, 8), 19 => to_unsigned(207, 8), 
	20 => to_unsigned(205, 8), 21 => to_unsigned(203, 8), 22 => to_unsigned(200, 8), 23 => to_unsigned(198, 8), 
	24 => to_unsigned(196, 8), 25 => to_unsigned(194, 8), 26 => to_unsigned(192, 8), 27 => to_unsigned(190, 8), 
	28 => to_unsigned(188, 8), 29 => to_unsigned(186, 8), 30 => to_unsigned(184, 8), 31 => to_unsigned(182, 8), 
	32 => to_unsigned(180, 8), 33 => to_unsigned(178, 8), 34 => to_unsigned(176, 8), 35 => to_unsigned(174, 8), 
	36 => to_unsigned(172, 8), 37 => to_unsigned(170, 8), 38 => to_unsigned(168, 8), 39 => to_unsigned(167, 8), 
	40 => to_unsigned(165, 8), 41 => to_unsigned(163, 8), 42 => to_unsigned(161, 8), 43 => to_unsigned(160, 8), 
	44 => to_unsigned(158, 8), 45 => to_unsigned(156, 8), 46 => to_unsigned(154, 8), 47 => to_unsigned(153, 8), 
	48 => to_unsigned(151, 8), 49 => to_unsigned(149, 8), 50 => to_unsigned(148, 8), 51 => to_unsigned(146, 8), 
	52 => to_unsigned(145, 8), 53 => to_unsigned(143, 8), 54 => to_unsigned(142, 8), 55 => to_unsigned(140, 8), 
	56 => to_unsigned(139, 8), 57 => to_unsigned(137, 8), 58 => to_unsigned(136, 8), 59 => to_unsigned(134, 8), 
	60 => to_unsigned(133, 8), 61 => to_unsigned(131, 8), 62 => to_unsigned(130, 8), 63 => to_unsigned(128, 8), 
	64 => to_unsigned(127, 8), 65 => to_unsigned(126, 8), 66 => to_unsigned(124, 8), 67 => to_unsigned(123, 8), 
	68 => to_unsigned(122, 8), 69 => to_unsigned(120, 8), 70 => to_unsigned(119, 8), 71 => to_unsigned(118, 8), 
	72 => to_unsigned(116, 8), 73 => to_unsigned(115, 8), 74 => to_unsigned(114, 8), 75 => to_unsigned(113, 8), 
	76 => to_unsigned(111, 8), 77 => to_unsigned(110, 8), 78 => to_unsigned(109, 8), 79 => to_unsigned(108, 8), 
	80 => to_unsigned(107, 8), 81 => to_unsigned(106, 8), 82 => to_unsigned(104, 8), 83 => to_unsigned(103, 8), 
	84 => to_unsigned(102, 8), 85 => to_unsigned(101, 8), 86 => to_unsigned(100, 8), 87 => to_unsigned(99, 8), 
	88 => to_unsigned(98, 8), 89 => to_unsigned(97, 8), 90 => to_unsigned(96, 8), 91 => to_unsigned(95, 8), 
	92 => to_unsigned(94, 8), 93 => to_unsigned(93, 8), 94 => to_unsigned(92, 8), 95 => to_unsigned(91, 8), 
	96 => to_unsigned(90, 8), 97 => to_unsigned(89, 8), 98 => to_unsigned(88, 8), 99 => to_unsigned(87, 8), 
	100 => to_unsigned(86, 8), 101 => to_unsigned(85, 8), 102 => to_unsigned(84, 8), 103 => to_unsigned(83, 8), 
	104 => to_unsigned(82, 8), 105 => to_unsigned(81, 8), 106 => to_unsigned(80, 8), 107 => to_unsigned(80, 8), 
	108 => to_unsigned(79, 8), 109 => to_unsigned(78, 8), 110 => to_unsigned(77, 8), 111 => to_unsigned(76, 8), 
	112 => to_unsigned(75, 8), 113 => to_unsigned(74, 8), 114 => to_unsigned(74, 8), 115 => to_unsigned(73, 8), 
	116 => to_unsigned(72, 8), 117 => to_unsigned(71, 8), 118 => to_unsigned(71, 8), 119 => to_unsigned(70, 8), 
	120 => to_unsigned(69, 8), 121 => to_unsigned(68, 8), 122 => to_unsigned(68, 8), 123 => to_unsigned(67, 8), 
	124 => to_unsigned(66, 8), 125 => to_unsigned(65, 8), 126 => to_unsigned(65, 8), 127 => to_unsigned(64, 8), 
	128 => to_unsigned(63, 8), 129 => to_unsigned(63, 8), 130 => to_unsigned(62, 8), 131 => to_unsigned(61, 8), 
	132 => to_unsigned(61, 8), 133 => to_unsigned(60, 8), 134 => to_unsigned(59, 8), 135 => to_unsigned(59, 8), 
	136 => to_unsigned(58, 8), 137 => to_unsigned(57, 8), 138 => to_unsigned(57, 8), 139 => to_unsigned(56, 8), 
	140 => to_unsigned(55, 8), 141 => to_unsigned(55, 8), 142 => to_unsigned(54, 8), 143 => to_unsigned(54, 8), 
	144 => to_unsigned(53, 8), 145 => to_unsigned(53, 8), 146 => to_unsigned(52, 8), 147 => to_unsigned(51, 8), 
	148 => to_unsigned(51, 8), 149 => to_unsigned(50, 8), 150 => to_unsigned(50, 8), 151 => to_unsigned(49, 8), 
	152 => to_unsigned(49, 8), 153 => to_unsigned(48, 8), 154 => to_unsigned(48, 8), 155 => to_unsigned(47, 8), 
	156 => to_unsigned(47, 8), 157 => to_unsigned(46, 8), 158 => to_unsigned(46, 8), 159 => to_unsigned(45, 8), 
	160 => to_unsigned(45, 8), 161 => to_unsigned(44, 8), 162 => to_unsigned(44, 8), 163 => to_unsigned(43, 8), 
	164 => to_unsigned(43, 8), 165 => to_unsigned(42, 8), 166 => to_unsigned(42, 8), 167 => to_unsigned(41, 8), 
	168 => to_unsigned(41, 8), 169 => to_unsigned(40, 8), 170 => to_unsigned(40, 8), 171 => to_unsigned(40, 8), 
	172 => to_unsigned(39, 8), 173 => to_unsigned(39, 8), 174 => to_unsigned(38, 8), 175 => to_unsigned(38, 8), 
	176 => to_unsigned(37, 8), 177 => to_unsigned(37, 8), 178 => to_unsigned(37, 8), 179 => to_unsigned(36, 8), 
	180 => to_unsigned(36, 8), 181 => to_unsigned(35, 8), 182 => to_unsigned(35, 8), 183 => to_unsigned(35, 8), 
	184 => to_unsigned(34, 8), 185 => to_unsigned(34, 8), 186 => to_unsigned(34, 8), 187 => to_unsigned(33, 8), 
	188 => to_unsigned(33, 8), 189 => to_unsigned(32, 8), 190 => to_unsigned(32, 8), 191 => to_unsigned(32, 8), 
	192 => to_unsigned(31, 8), 193 => to_unsigned(31, 8), 194 => to_unsigned(31, 8), 195 => to_unsigned(30, 8), 
	196 => to_unsigned(30, 8), 197 => to_unsigned(30, 8), 198 => to_unsigned(29, 8), 199 => to_unsigned(29, 8), 
	200 => to_unsigned(29, 8), 201 => to_unsigned(28, 8), 202 => to_unsigned(28, 8), 203 => to_unsigned(28, 8), 
	204 => to_unsigned(27, 8), 205 => to_unsigned(27, 8), 206 => to_unsigned(27, 8), 207 => to_unsigned(27, 8), 
	208 => to_unsigned(26, 8), 209 => to_unsigned(26, 8), 210 => to_unsigned(26, 8), 211 => to_unsigned(25, 8), 
	212 => to_unsigned(25, 8), 213 => to_unsigned(25, 8), 214 => to_unsigned(25, 8), 215 => to_unsigned(24, 8), 
	216 => to_unsigned(24, 8), 217 => to_unsigned(24, 8), 218 => to_unsigned(24, 8), 219 => to_unsigned(23, 8), 
	220 => to_unsigned(23, 8), 221 => to_unsigned(23, 8), 222 => to_unsigned(23, 8), 223 => to_unsigned(22, 8), 
	224 => to_unsigned(22, 8), 225 => to_unsigned(22, 8), 226 => to_unsigned(22, 8), 227 => to_unsigned(21, 8), 
	228 => to_unsigned(21, 8), 229 => to_unsigned(21, 8), 230 => to_unsigned(21, 8), 231 => to_unsigned(20, 8), 
	232 => to_unsigned(20, 8), 233 => to_unsigned(20, 8), 234 => to_unsigned(20, 8), 235 => to_unsigned(20, 8), 
	236 => to_unsigned(19, 8), 237 => to_unsigned(19, 8), 238 => to_unsigned(19, 8), 239 => to_unsigned(19, 8), 
	240 => to_unsigned(18, 8), 241 => to_unsigned(18, 8), 242 => to_unsigned(18, 8), 243 => to_unsigned(18, 8), 
	244 => to_unsigned(18, 8), 245 => to_unsigned(17, 8), 246 => to_unsigned(17, 8), 247 => to_unsigned(17, 8), 
	248 => to_unsigned(17, 8), 249 => to_unsigned(17, 8), 250 => to_unsigned(17, 8), 251 => to_unsigned(16, 8), 
	252 => to_unsigned(16, 8), 253 => to_unsigned(16, 8), 254 => to_unsigned(16, 8), 255 => to_unsigned(16, 8), 
	256 => to_unsigned(15, 8), 257 => to_unsigned(15, 8), 258 => to_unsigned(15, 8), 259 => to_unsigned(15, 8), 
	260 => to_unsigned(15, 8), 261 => to_unsigned(15, 8), 262 => to_unsigned(14, 8), 263 => to_unsigned(14, 8), 
	264 => to_unsigned(14, 8), 265 => to_unsigned(14, 8), 266 => to_unsigned(14, 8), 267 => to_unsigned(14, 8), 
	268 => to_unsigned(13, 8), 269 => to_unsigned(13, 8), 270 => to_unsigned(13, 8), 271 => to_unsigned(13, 8), 
	272 => to_unsigned(13, 8), 273 => to_unsigned(13, 8), 274 => to_unsigned(13, 8), 275 => to_unsigned(12, 8), 
	276 => to_unsigned(12, 8), 277 => to_unsigned(12, 8), 278 => to_unsigned(12, 8), 279 => to_unsigned(12, 8), 
	280 => to_unsigned(12, 8), 281 => to_unsigned(12, 8), 282 => to_unsigned(12, 8), 283 => to_unsigned(11, 8), 
	284 => to_unsigned(11, 8), 285 => to_unsigned(11, 8), 286 => to_unsigned(11, 8), 287 => to_unsigned(11, 8), 
	288 => to_unsigned(11, 8), 289 => to_unsigned(11, 8), 290 => to_unsigned(11, 8), 291 => to_unsigned(10, 8), 
	292 => to_unsigned(10, 8), 293 => to_unsigned(10, 8), 294 => to_unsigned(10, 8), 295 => to_unsigned(10, 8), 
	296 => to_unsigned(10, 8), 297 => to_unsigned(10, 8), 298 => to_unsigned(10, 8), 299 => to_unsigned(10, 8), 
	300 => to_unsigned(9, 8), 301 => to_unsigned(9, 8), 302 => to_unsigned(9, 8), 303 => to_unsigned(9, 8), 
	304 => to_unsigned(9, 8), 305 => to_unsigned(9, 8), 306 => to_unsigned(9, 8), 307 => to_unsigned(9, 8), 
	308 => to_unsigned(9, 8), 309 => to_unsigned(8, 8), 310 => to_unsigned(8, 8), 311 => to_unsigned(8, 8), 
	312 => to_unsigned(8, 8), 313 => to_unsigned(8, 8), 314 => to_unsigned(8, 8), 315 => to_unsigned(8, 8), 
	316 => to_unsigned(8, 8), 317 => to_unsigned(8, 8), 318 => to_unsigned(8, 8), 319 => to_unsigned(8, 8), 
	320 => to_unsigned(7, 8), 321 => to_unsigned(7, 8), 322 => to_unsigned(7, 8), 323 => to_unsigned(7, 8), 
	324 => to_unsigned(7, 8), 325 => to_unsigned(7, 8), 326 => to_unsigned(7, 8), 327 => to_unsigned(7, 8), 
	328 => to_unsigned(7, 8), 329 => to_unsigned(7, 8), 330 => to_unsigned(7, 8), 331 => to_unsigned(7, 8), 
	332 => to_unsigned(6, 8), 333 => to_unsigned(6, 8), 334 => to_unsigned(6, 8), 335 => to_unsigned(6, 8), 
	336 => to_unsigned(6, 8), 337 => to_unsigned(6, 8), 338 => to_unsigned(6, 8), 339 => to_unsigned(6, 8), 
	340 => to_unsigned(6, 8), 341 => to_unsigned(6, 8), 342 => to_unsigned(6, 8), 343 => to_unsigned(6, 8), 
	344 => to_unsigned(6, 8), 345 => to_unsigned(6, 8), 346 => to_unsigned(6, 8), 347 => to_unsigned(5, 8), 
	348 => to_unsigned(5, 8), 349 => to_unsigned(5, 8), 350 => to_unsigned(5, 8), 351 => to_unsigned(5, 8), 
	352 => to_unsigned(5, 8), 353 => to_unsigned(5, 8), 354 => to_unsigned(5, 8), 355 => to_unsigned(5, 8), 
	356 => to_unsigned(5, 8), 357 => to_unsigned(5, 8), 358 => to_unsigned(5, 8), 359 => to_unsigned(5, 8), 
	360 => to_unsigned(5, 8), 361 => to_unsigned(5, 8), 362 => to_unsigned(5, 8), 363 => to_unsigned(5, 8), 
	364 => to_unsigned(4, 8), 365 => to_unsigned(4, 8), 366 => to_unsigned(4, 8), 367 => to_unsigned(4, 8), 
	368 => to_unsigned(4, 8), 369 => to_unsigned(4, 8), 370 => to_unsigned(4, 8), 371 => to_unsigned(4, 8), 
	372 => to_unsigned(4, 8), 373 => to_unsigned(4, 8), 374 => to_unsigned(4, 8), 375 => to_unsigned(4, 8), 
	376 => to_unsigned(4, 8), 377 => to_unsigned(4, 8), 378 => to_unsigned(4, 8), 379 => to_unsigned(4, 8), 
	380 => to_unsigned(4, 8), 381 => to_unsigned(4, 8), 382 => to_unsigned(4, 8), 383 => to_unsigned(4, 8), 
	384 => to_unsigned(3, 8), 385 => to_unsigned(3, 8), 386 => to_unsigned(3, 8), 387 => to_unsigned(3, 8), 
	388 => to_unsigned(3, 8), 389 => to_unsigned(3, 8), 390 => to_unsigned(3, 8), 391 => to_unsigned(3, 8), 
	392 => to_unsigned(3, 8), 393 => to_unsigned(3, 8), 394 => to_unsigned(3, 8), 395 => to_unsigned(3, 8), 
	396 => to_unsigned(3, 8), 397 => to_unsigned(3, 8), 398 => to_unsigned(3, 8), 399 => to_unsigned(3, 8), 
	400 => to_unsigned(3, 8), 401 => to_unsigned(3, 8), 402 => to_unsigned(3, 8), 403 => to_unsigned(3, 8), 
	404 => to_unsigned(3, 8), 405 => to_unsigned(3, 8), 406 => to_unsigned(3, 8), 407 => to_unsigned(3, 8), 
	408 => to_unsigned(3, 8), 409 => to_unsigned(3, 8), 410 => to_unsigned(3, 8), 411 => to_unsigned(2, 8), 
	412 => to_unsigned(2, 8), 413 => to_unsigned(2, 8), 414 => to_unsigned(2, 8), 415 => to_unsigned(2, 8), 
	416 => to_unsigned(2, 8), 417 => to_unsigned(2, 8), 418 => to_unsigned(2, 8), 419 => to_unsigned(2, 8), 
	420 => to_unsigned(2, 8), 421 => to_unsigned(2, 8), 422 => to_unsigned(2, 8), 423 => to_unsigned(2, 8), 
	424 => to_unsigned(2, 8), 425 => to_unsigned(2, 8), 426 => to_unsigned(2, 8), 427 => to_unsigned(2, 8), 
	428 => to_unsigned(2, 8), 429 => to_unsigned(2, 8), 430 => to_unsigned(2, 8), 431 => to_unsigned(2, 8), 
	432 => to_unsigned(2, 8), 433 => to_unsigned(2, 8), 434 => to_unsigned(2, 8), 435 => to_unsigned(2, 8), 
	436 => to_unsigned(2, 8), 437 => to_unsigned(2, 8), 438 => to_unsigned(2, 8), 439 => to_unsigned(2, 8), 
	440 => to_unsigned(2, 8), 441 => to_unsigned(2, 8), 442 => to_unsigned(2, 8), 443 => to_unsigned(2, 8), 
	444 => to_unsigned(2, 8), 445 => to_unsigned(2, 8), 446 => to_unsigned(2, 8), 447 => to_unsigned(2, 8), 
	448 => to_unsigned(1, 8), 449 => to_unsigned(1, 8), 450 => to_unsigned(1, 8), 451 => to_unsigned(1, 8), 
	452 => to_unsigned(1, 8), 453 => to_unsigned(1, 8), 454 => to_unsigned(1, 8), 455 => to_unsigned(1, 8), 
	456 => to_unsigned(1, 8), 457 => to_unsigned(1, 8), 458 => to_unsigned(1, 8), 459 => to_unsigned(1, 8), 
	460 => to_unsigned(1, 8), 461 => to_unsigned(1, 8), 462 => to_unsigned(1, 8), 463 => to_unsigned(1, 8), 
	464 => to_unsigned(1, 8), 465 => to_unsigned(1, 8), 466 => to_unsigned(1, 8), 467 => to_unsigned(1, 8), 
	468 => to_unsigned(1, 8), 469 => to_unsigned(1, 8), 470 => to_unsigned(1, 8), 471 => to_unsigned(1, 8), 
	472 => to_unsigned(1, 8), 473 => to_unsigned(1, 8), 474 => to_unsigned(1, 8), 475 => to_unsigned(1, 8), 
	476 => to_unsigned(1, 8), 477 => to_unsigned(1, 8), 478 => to_unsigned(1, 8), 479 => to_unsigned(1, 8), 
	480 => to_unsigned(1, 8), 481 => to_unsigned(1, 8), 482 => to_unsigned(1, 8), 483 => to_unsigned(1, 8), 
	484 => to_unsigned(1, 8), 485 => to_unsigned(1, 8), 486 => to_unsigned(1, 8), 487 => to_unsigned(1, 8), 
	488 => to_unsigned(1, 8), 489 => to_unsigned(1, 8), 490 => to_unsigned(1, 8), 491 => to_unsigned(1, 8), 
	492 => to_unsigned(1, 8), 493 => to_unsigned(1, 8), 494 => to_unsigned(1, 8), 495 => to_unsigned(1, 8), 
	496 => to_unsigned(1, 8), 497 => to_unsigned(1, 8), 498 => to_unsigned(1, 8), 499 => to_unsigned(1, 8), 
	500 => to_unsigned(1, 8), 501 => to_unsigned(1, 8), 502 => to_unsigned(1, 8), 503 => to_unsigned(1, 8), 
	504 => to_unsigned(1, 8), 505 => to_unsigned(1, 8), 506 => to_unsigned(1, 8), 507 => to_unsigned(1, 8), 
	508 => to_unsigned(1, 8), 509 => to_unsigned(1, 8), 510 => to_unsigned(1, 8), 511 => to_unsigned(1, 8), 
	512 => to_unsigned(1, 8), 513 => to_unsigned(0, 8), 514 => to_unsigned(0, 8), 515 => to_unsigned(0, 8), 
	516 => to_unsigned(0, 8), 517 => to_unsigned(0, 8), 518 => to_unsigned(0, 8), 519 => to_unsigned(0, 8), 
	520 => to_unsigned(0, 8), 521 => to_unsigned(0, 8), 522 => to_unsigned(0, 8), 523 => to_unsigned(0, 8), 
	524 => to_unsigned(0, 8), 525 => to_unsigned(0, 8), 526 => to_unsigned(0, 8), 527 => to_unsigned(0, 8), 
	528 => to_unsigned(0, 8), 529 => to_unsigned(0, 8), 530 => to_unsigned(0, 8), 531 => to_unsigned(0, 8), 
	532 => to_unsigned(0, 8), 533 => to_unsigned(0, 8), 534 => to_unsigned(0, 8), 535 => to_unsigned(0, 8), 
	536 => to_unsigned(0, 8), 537 => to_unsigned(0, 8), 538 => to_unsigned(0, 8), 539 => to_unsigned(0, 8), 
	540 => to_unsigned(0, 8), 541 => to_unsigned(0, 8), 542 => to_unsigned(0, 8), 543 => to_unsigned(0, 8), 
	544 => to_unsigned(0, 8), 545 => to_unsigned(0, 8), 546 => to_unsigned(0, 8), 547 => to_unsigned(0, 8), 
	548 => to_unsigned(0, 8), 549 => to_unsigned(0, 8), 550 => to_unsigned(0, 8), 551 => to_unsigned(0, 8), 
	552 => to_unsigned(0, 8), 553 => to_unsigned(0, 8), 554 => to_unsigned(0, 8), 555 => to_unsigned(0, 8), 
	556 => to_unsigned(0, 8), 557 => to_unsigned(0, 8), 558 => to_unsigned(0, 8), 559 => to_unsigned(0, 8), 
	560 => to_unsigned(0, 8), 561 => to_unsigned(0, 8), 562 => to_unsigned(0, 8), 563 => to_unsigned(0, 8), 
	564 => to_unsigned(0, 8), 565 => to_unsigned(0, 8), 566 => to_unsigned(0, 8), 567 => to_unsigned(0, 8), 
	568 => to_unsigned(0, 8), 569 => to_unsigned(0, 8), 570 => to_unsigned(0, 8), 571 => to_unsigned(0, 8), 
	572 => to_unsigned(0, 8), 573 => to_unsigned(0, 8), 574 => to_unsigned(0, 8), 575 => to_unsigned(0, 8), 
	576 => to_unsigned(0, 8), 577 => to_unsigned(0, 8), 578 => to_unsigned(0, 8), 579 => to_unsigned(0, 8), 
	580 => to_unsigned(0, 8), 581 => to_unsigned(0, 8), 582 => to_unsigned(0, 8), 583 => to_unsigned(0, 8), 
	584 => to_unsigned(0, 8), 585 => to_unsigned(0, 8), 586 => to_unsigned(0, 8), 587 => to_unsigned(0, 8), 
	588 => to_unsigned(0, 8), 589 => to_unsigned(0, 8), 590 => to_unsigned(0, 8), 591 => to_unsigned(0, 8), 
	592 => to_unsigned(0, 8), 593 => to_unsigned(0, 8), 594 => to_unsigned(0, 8), 595 => to_unsigned(0, 8), 
	596 => to_unsigned(0, 8), 597 => to_unsigned(0, 8), 598 => to_unsigned(0, 8), 599 => to_unsigned(0, 8), 
	600 => to_unsigned(0, 8), 601 => to_unsigned(0, 8), 602 => to_unsigned(0, 8), 603 => to_unsigned(0, 8), 
	604 => to_unsigned(0, 8), 605 => to_unsigned(0, 8), 606 => to_unsigned(0, 8), 607 => to_unsigned(0, 8), 
	608 => to_unsigned(0, 8), 609 => to_unsigned(0, 8), 610 => to_unsigned(0, 8), 611 => to_unsigned(0, 8), 
	612 => to_unsigned(0, 8), 613 => to_unsigned(0, 8), 614 => to_unsigned(0, 8), 615 => to_unsigned(0, 8), 
	616 => to_unsigned(0, 8), 617 => to_unsigned(0, 8), 618 => to_unsigned(0, 8), 619 => to_unsigned(0, 8), 
	620 => to_unsigned(0, 8), 621 => to_unsigned(0, 8), 622 => to_unsigned(0, 8), 623 => to_unsigned(0, 8), 
	624 => to_unsigned(0, 8), 625 => to_unsigned(0, 8), 626 => to_unsigned(0, 8), 627 => to_unsigned(0, 8), 
	628 => to_unsigned(0, 8), 629 => to_unsigned(0, 8), 630 => to_unsigned(0, 8), 631 => to_unsigned(0, 8), 
	632 => to_unsigned(0, 8), 633 => to_unsigned(0, 8), 634 => to_unsigned(0, 8), 635 => to_unsigned(0, 8), 
	636 => to_unsigned(0, 8), 637 => to_unsigned(0, 8), 638 => to_unsigned(0, 8), 639 => to_unsigned(0, 8), 
	640 => to_unsigned(0, 8), 641 => to_unsigned(0, 8), 642 => to_unsigned(0, 8), 643 => to_unsigned(0, 8), 
	644 => to_unsigned(0, 8), 645 => to_unsigned(0, 8), 646 => to_unsigned(0, 8), 647 => to_unsigned(0, 8), 
	648 => to_unsigned(0, 8), 649 => to_unsigned(0, 8), 650 => to_unsigned(0, 8), 651 => to_unsigned(0, 8), 
	652 => to_unsigned(0, 8), 653 => to_unsigned(0, 8), 654 => to_unsigned(0, 8), 655 => to_unsigned(0, 8), 
	656 => to_unsigned(0, 8), 657 => to_unsigned(0, 8), 658 => to_unsigned(0, 8), 659 => to_unsigned(0, 8), 
	660 => to_unsigned(0, 8), 661 => to_unsigned(0, 8), 662 => to_unsigned(0, 8), 663 => to_unsigned(0, 8), 
	664 => to_unsigned(0, 8), 665 => to_unsigned(0, 8), 666 => to_unsigned(0, 8), 667 => to_unsigned(0, 8), 
	668 => to_unsigned(0, 8), 669 => to_unsigned(0, 8), 670 => to_unsigned(0, 8), 671 => to_unsigned(0, 8), 
	672 => to_unsigned(0, 8), 673 => to_unsigned(0, 8), 674 => to_unsigned(0, 8), 675 => to_unsigned(0, 8), 
	676 => to_unsigned(0, 8), 677 => to_unsigned(0, 8), 678 => to_unsigned(0, 8), 679 => to_unsigned(0, 8), 
	680 => to_unsigned(0, 8), 681 => to_unsigned(0, 8), 682 => to_unsigned(0, 8), 683 => to_unsigned(0, 8), 
	684 => to_unsigned(0, 8), 685 => to_unsigned(0, 8), 686 => to_unsigned(0, 8), 687 => to_unsigned(0, 8), 
	688 => to_unsigned(0, 8), 689 => to_unsigned(0, 8), 690 => to_unsigned(0, 8), 691 => to_unsigned(0, 8), 
	692 => to_unsigned(0, 8), 693 => to_unsigned(0, 8), 694 => to_unsigned(0, 8), 695 => to_unsigned(0, 8), 
	696 => to_unsigned(0, 8), 697 => to_unsigned(0, 8), 698 => to_unsigned(0, 8), 699 => to_unsigned(0, 8), 
	700 => to_unsigned(0, 8), 701 => to_unsigned(0, 8), 702 => to_unsigned(0, 8), 703 => to_unsigned(0, 8), 
	704 => to_unsigned(0, 8), 705 => to_unsigned(0, 8), 706 => to_unsigned(0, 8), 707 => to_unsigned(0, 8), 
	708 => to_unsigned(0, 8), 709 => to_unsigned(0, 8), 710 => to_unsigned(0, 8), 711 => to_unsigned(0, 8), 
	712 => to_unsigned(0, 8), 713 => to_unsigned(0, 8), 714 => to_unsigned(0, 8), 715 => to_unsigned(0, 8), 
	716 => to_unsigned(0, 8), 717 => to_unsigned(0, 8), 718 => to_unsigned(0, 8), 719 => to_unsigned(0, 8), 
	720 => to_unsigned(0, 8), 721 => to_unsigned(0, 8), 722 => to_unsigned(0, 8), 723 => to_unsigned(0, 8), 
	724 => to_unsigned(0, 8), 725 => to_unsigned(0, 8), 726 => to_unsigned(0, 8), 727 => to_unsigned(0, 8), 
	728 => to_unsigned(0, 8), 729 => to_unsigned(0, 8), 730 => to_unsigned(0, 8), 731 => to_unsigned(0, 8), 
	732 => to_unsigned(0, 8), 733 => to_unsigned(0, 8), 734 => to_unsigned(0, 8), 735 => to_unsigned(0, 8), 
	736 => to_unsigned(0, 8), 737 => to_unsigned(0, 8), 738 => to_unsigned(0, 8), 739 => to_unsigned(0, 8), 
	740 => to_unsigned(0, 8), 741 => to_unsigned(0, 8), 742 => to_unsigned(0, 8), 743 => to_unsigned(0, 8), 
	744 => to_unsigned(0, 8), 745 => to_unsigned(0, 8), 746 => to_unsigned(0, 8), 747 => to_unsigned(0, 8), 
	748 => to_unsigned(0, 8), 749 => to_unsigned(0, 8), 750 => to_unsigned(0, 8), 751 => to_unsigned(0, 8), 
	752 => to_unsigned(0, 8), 753 => to_unsigned(0, 8), 754 => to_unsigned(0, 8), 755 => to_unsigned(0, 8), 
	756 => to_unsigned(0, 8), 757 => to_unsigned(0, 8), 758 => to_unsigned(0, 8), 759 => to_unsigned(0, 8), 
	760 => to_unsigned(0, 8), 761 => to_unsigned(0, 8), 762 => to_unsigned(0, 8), 763 => to_unsigned(0, 8), 
	764 => to_unsigned(0, 8), 765 => to_unsigned(0, 8), 766 => to_unsigned(0, 8), 767 => to_unsigned(0, 8), 
	768 => to_unsigned(0, 8), 769 => to_unsigned(0, 8), 770 => to_unsigned(0, 8), 771 => to_unsigned(0, 8), 
	772 => to_unsigned(0, 8), 773 => to_unsigned(0, 8), 774 => to_unsigned(0, 8), 775 => to_unsigned(0, 8), 
	776 => to_unsigned(0, 8), 777 => to_unsigned(0, 8), 778 => to_unsigned(0, 8), 779 => to_unsigned(0, 8), 
	780 => to_unsigned(0, 8), 781 => to_unsigned(0, 8), 782 => to_unsigned(0, 8), 783 => to_unsigned(0, 8), 
	784 => to_unsigned(0, 8), 785 => to_unsigned(0, 8), 786 => to_unsigned(0, 8), 787 => to_unsigned(0, 8), 
	788 => to_unsigned(0, 8), 789 => to_unsigned(0, 8), 790 => to_unsigned(0, 8), 791 => to_unsigned(0, 8), 
	792 => to_unsigned(0, 8), 793 => to_unsigned(0, 8), 794 => to_unsigned(0, 8), 795 => to_unsigned(0, 8), 
	796 => to_unsigned(0, 8), 797 => to_unsigned(0, 8), 798 => to_unsigned(0, 8), 799 => to_unsigned(0, 8), 
	800 => to_unsigned(0, 8), 801 => to_unsigned(0, 8), 802 => to_unsigned(0, 8), 803 => to_unsigned(0, 8), 
	804 => to_unsigned(0, 8), 805 => to_unsigned(0, 8), 806 => to_unsigned(0, 8), 807 => to_unsigned(0, 8), 
	808 => to_unsigned(0, 8), 809 => to_unsigned(0, 8), 810 => to_unsigned(0, 8), 811 => to_unsigned(0, 8), 
	812 => to_unsigned(0, 8), 813 => to_unsigned(0, 8), 814 => to_unsigned(0, 8), 815 => to_unsigned(0, 8), 
	816 => to_unsigned(0, 8), 817 => to_unsigned(0, 8), 818 => to_unsigned(0, 8), 819 => to_unsigned(0, 8), 
	820 => to_unsigned(0, 8), 821 => to_unsigned(0, 8), 822 => to_unsigned(0, 8), 823 => to_unsigned(0, 8), 
	824 => to_unsigned(0, 8), 825 => to_unsigned(0, 8), 826 => to_unsigned(0, 8), 827 => to_unsigned(0, 8), 
	828 => to_unsigned(0, 8), 829 => to_unsigned(0, 8), 830 => to_unsigned(0, 8), 831 => to_unsigned(0, 8), 
	832 => to_unsigned(0, 8), 833 => to_unsigned(0, 8), 834 => to_unsigned(0, 8), 835 => to_unsigned(0, 8), 
	836 => to_unsigned(0, 8), 837 => to_unsigned(0, 8), 838 => to_unsigned(0, 8), 839 => to_unsigned(0, 8), 
	840 => to_unsigned(0, 8), 841 => to_unsigned(0, 8), 842 => to_unsigned(0, 8), 843 => to_unsigned(0, 8), 
	844 => to_unsigned(0, 8), 845 => to_unsigned(0, 8), 846 => to_unsigned(0, 8), 847 => to_unsigned(0, 8), 
	848 => to_unsigned(0, 8), 849 => to_unsigned(0, 8), 850 => to_unsigned(0, 8), 851 => to_unsigned(0, 8), 
	852 => to_unsigned(0, 8), 853 => to_unsigned(0, 8), 854 => to_unsigned(0, 8), 855 => to_unsigned(0, 8), 
	856 => to_unsigned(0, 8), 857 => to_unsigned(0, 8), 858 => to_unsigned(0, 8), 859 => to_unsigned(0, 8), 
	860 => to_unsigned(0, 8), 861 => to_unsigned(0, 8), 862 => to_unsigned(0, 8), 863 => to_unsigned(0, 8), 
	864 => to_unsigned(0, 8), 865 => to_unsigned(0, 8), 866 => to_unsigned(0, 8), 867 => to_unsigned(0, 8), 
	868 => to_unsigned(0, 8), 869 => to_unsigned(0, 8), 870 => to_unsigned(0, 8), 871 => to_unsigned(0, 8), 
	872 => to_unsigned(0, 8), 873 => to_unsigned(0, 8), 874 => to_unsigned(0, 8), 875 => to_unsigned(0, 8), 
	876 => to_unsigned(0, 8), 877 => to_unsigned(0, 8), 878 => to_unsigned(0, 8), 879 => to_unsigned(0, 8), 
	880 => to_unsigned(0, 8), 881 => to_unsigned(0, 8), 882 => to_unsigned(0, 8), 883 => to_unsigned(0, 8), 
	884 => to_unsigned(0, 8), 885 => to_unsigned(0, 8), 886 => to_unsigned(0, 8), 887 => to_unsigned(0, 8), 
	888 => to_unsigned(0, 8), 889 => to_unsigned(0, 8), 890 => to_unsigned(0, 8), 891 => to_unsigned(0, 8), 
	892 => to_unsigned(0, 8), 893 => to_unsigned(0, 8), 894 => to_unsigned(0, 8), 895 => to_unsigned(0, 8), 
	896 => to_unsigned(0, 8), 897 => to_unsigned(0, 8), 898 => to_unsigned(0, 8), 899 => to_unsigned(0, 8), 
	900 => to_unsigned(0, 8), 901 => to_unsigned(0, 8), 902 => to_unsigned(0, 8), 903 => to_unsigned(0, 8), 
	904 => to_unsigned(0, 8), 905 => to_unsigned(0, 8), 906 => to_unsigned(0, 8), 907 => to_unsigned(0, 8), 
	908 => to_unsigned(0, 8), 909 => to_unsigned(0, 8), 910 => to_unsigned(0, 8), 911 => to_unsigned(0, 8), 
	912 => to_unsigned(0, 8), 913 => to_unsigned(0, 8), 914 => to_unsigned(0, 8), 915 => to_unsigned(0, 8), 
	916 => to_unsigned(0, 8), 917 => to_unsigned(0, 8), 918 => to_unsigned(0, 8), 919 => to_unsigned(0, 8), 
	920 => to_unsigned(0, 8), 921 => to_unsigned(0, 8), 922 => to_unsigned(0, 8), 923 => to_unsigned(0, 8), 
	924 => to_unsigned(0, 8), 925 => to_unsigned(0, 8), 926 => to_unsigned(0, 8), 927 => to_unsigned(0, 8), 
	928 => to_unsigned(0, 8), 929 => to_unsigned(0, 8), 930 => to_unsigned(0, 8), 931 => to_unsigned(0, 8), 
	932 => to_unsigned(0, 8), 933 => to_unsigned(0, 8), 934 => to_unsigned(0, 8), 935 => to_unsigned(0, 8), 
	936 => to_unsigned(0, 8), 937 => to_unsigned(0, 8), 938 => to_unsigned(0, 8), 939 => to_unsigned(0, 8), 
	940 => to_unsigned(0, 8), 941 => to_unsigned(0, 8), 942 => to_unsigned(0, 8), 943 => to_unsigned(0, 8), 
	944 => to_unsigned(0, 8), 945 => to_unsigned(0, 8), 946 => to_unsigned(0, 8), 947 => to_unsigned(0, 8), 
	948 => to_unsigned(0, 8), 949 => to_unsigned(0, 8), 950 => to_unsigned(0, 8), 951 => to_unsigned(0, 8), 
	952 => to_unsigned(0, 8), 953 => to_unsigned(0, 8), 954 => to_unsigned(0, 8), 955 => to_unsigned(0, 8), 
	956 => to_unsigned(0, 8), 957 => to_unsigned(0, 8), 958 => to_unsigned(0, 8), 959 => to_unsigned(0, 8), 
	960 => to_unsigned(0, 8), 961 => to_unsigned(0, 8), 962 => to_unsigned(0, 8), 963 => to_unsigned(0, 8), 
	964 => to_unsigned(0, 8), 965 => to_unsigned(0, 8), 966 => to_unsigned(0, 8), 967 => to_unsigned(0, 8), 
	968 => to_unsigned(0, 8), 969 => to_unsigned(0, 8), 970 => to_unsigned(0, 8), 971 => to_unsigned(0, 8), 
	972 => to_unsigned(0, 8), 973 => to_unsigned(0, 8), 974 => to_unsigned(0, 8), 975 => to_unsigned(0, 8), 
	976 => to_unsigned(0, 8), 977 => to_unsigned(0, 8), 978 => to_unsigned(0, 8), 979 => to_unsigned(0, 8), 
	980 => to_unsigned(0, 8), 981 => to_unsigned(0, 8), 982 => to_unsigned(0, 8), 983 => to_unsigned(0, 8), 
	984 => to_unsigned(0, 8), 985 => to_unsigned(0, 8), 986 => to_unsigned(0, 8), 987 => to_unsigned(0, 8), 
	988 => to_unsigned(0, 8), 989 => to_unsigned(0, 8), 990 => to_unsigned(0, 8), 991 => to_unsigned(0, 8), 
	992 => to_unsigned(0, 8), 993 => to_unsigned(0, 8), 994 => to_unsigned(0, 8), 995 => to_unsigned(0, 8), 
	996 => to_unsigned(0, 8), 997 => to_unsigned(0, 8), 998 => to_unsigned(0, 8), 999 => to_unsigned(0, 8), 
	1000 => to_unsigned(0, 8), 1001 => to_unsigned(0, 8), 1002 => to_unsigned(0, 8), 1003 => to_unsigned(0, 8), 
	1004 => to_unsigned(0, 8), 1005 => to_unsigned(0, 8), 1006 => to_unsigned(0, 8), 1007 => to_unsigned(0, 8), 
	1008 => to_unsigned(0, 8), 1009 => to_unsigned(0, 8), 1010 => to_unsigned(0, 8), 1011 => to_unsigned(0, 8), 
	1012 => to_unsigned(0, 8), 1013 => to_unsigned(0, 8), 1014 => to_unsigned(0, 8), 1015 => to_unsigned(0, 8), 
	1016 => to_unsigned(0, 8), 1017 => to_unsigned(0, 8), 1018 => to_unsigned(0, 8), 1019 => to_unsigned(0, 8), 
	1020 => to_unsigned(0, 8), 1021 => to_unsigned(0, 8), 1022 => to_unsigned(0, 8), 1023 => to_unsigned(0, 8)
	);
	
	type gaintab_type is array(0 to 127) of unsigned(7 downto 0);
	constant gaintab: gaintab_type := (
		0 => to_unsigned(255, 8),1 => to_unsigned(234, 8),2 => to_unsigned(215, 8),3 => to_unsigned(197, 8),
		4 => to_unsigned(181, 8),5 => to_unsigned(166, 8),6 => to_unsigned(152, 8),7 => to_unsigned(139, 8),
		8 => to_unsigned(128, 8),9 => to_unsigned(117, 8),10 => to_unsigned(108, 8),11 => to_unsigned(99, 8),
		12 => to_unsigned(90, 8),13 => to_unsigned(83, 8),14 => to_unsigned(76, 8),15 => to_unsigned(70, 8),
		16 => to_unsigned(64, 8),17 => to_unsigned(59, 8),18 => to_unsigned(54, 8),19 => to_unsigned(49, 8),
		20 => to_unsigned(45, 8),21 => to_unsigned(42, 8),22 => to_unsigned(38, 8),23 => to_unsigned(35, 8),
		24 => to_unsigned(32, 8),25 => to_unsigned(29, 8),26 => to_unsigned(27, 8),27 => to_unsigned(25, 8),
		28 => to_unsigned(23, 8),29 => to_unsigned(21, 8),30 => to_unsigned(19, 8),31 => to_unsigned(18, 8),
		32 => to_unsigned(16, 8),33 => to_unsigned(15, 8),34 => to_unsigned(14, 8),35 => to_unsigned(12, 8),
		36 => to_unsigned(11, 8),37 => to_unsigned(10, 8),38 => to_unsigned(10, 8),39 => to_unsigned(9, 8),
		40 => to_unsigned(8, 8),41 => to_unsigned(7, 8),42 => to_unsigned(7, 8),43 => to_unsigned(6, 8),
		44 => to_unsigned(6, 8),45 => to_unsigned(5, 8),46 => to_unsigned(5, 8),47 => to_unsigned(4, 8),
		48 => to_unsigned(4, 8),49 => to_unsigned(4, 8),50 => to_unsigned(3, 8),51 => to_unsigned(3, 8),
		52 => to_unsigned(3, 8),53 => to_unsigned(3, 8),54 => to_unsigned(2, 8),55 => to_unsigned(2, 8),
		56 => to_unsigned(2, 8),57 => to_unsigned(2, 8),58 => to_unsigned(2, 8),59 => to_unsigned(2, 8),
		60 => to_unsigned(1, 8),61 => to_unsigned(1, 8),62 => to_unsigned(1, 8),63 => to_unsigned(1, 8),
		64 => to_unsigned(0, 8),65 => to_unsigned(0, 8),66 => to_unsigned(0, 8),67 => to_unsigned(0, 8),
		68 => to_unsigned(0, 8),69 => to_unsigned(0, 8),70 => to_unsigned(0, 8),71 => to_unsigned(0, 8),
		72 => to_unsigned(0, 8),73 => to_unsigned(0, 8),74 => to_unsigned(0, 8),75 => to_unsigned(0, 8),
		76 => to_unsigned(0, 8),77 => to_unsigned(0, 8),78 => to_unsigned(0, 8),79 => to_unsigned(0, 8),
		80 => to_unsigned(0, 8),81 => to_unsigned(0, 8),82 => to_unsigned(0, 8),83 => to_unsigned(0, 8),
		84 => to_unsigned(0, 8),85 => to_unsigned(0, 8),86 => to_unsigned(0, 8),87 => to_unsigned(0, 8),
		88 => to_unsigned(0, 8),89 => to_unsigned(0, 8),90 => to_unsigned(0, 8),91 => to_unsigned(0, 8),
		92 => to_unsigned(0, 8),93 => to_unsigned(0, 8),94 => to_unsigned(0, 8),95 => to_unsigned(0, 8),
		96 => to_unsigned(0, 8),97 => to_unsigned(0, 8),98 => to_unsigned(0, 8),99 => to_unsigned(0, 8),
		100 => to_unsigned(0, 8),101 => to_unsigned(0, 8),102 => to_unsigned(0, 8),103 => to_unsigned(0, 8),
		104 => to_unsigned(0, 8),105 => to_unsigned(0, 8),106 => to_unsigned(0, 8),107 => to_unsigned(0, 8),
		108 => to_unsigned(0, 8),109 => to_unsigned(0, 8),110 => to_unsigned(0, 8),111 => to_unsigned(0, 8),
		112 => to_unsigned(0, 8),113 => to_unsigned(0, 8),114 => to_unsigned(0, 8),115 => to_unsigned(0, 8),
		116 => to_unsigned(0, 8),117 => to_unsigned(0, 8),118 => to_unsigned(0, 8),119 => to_unsigned(0, 8),
		120 => to_unsigned(0, 8),121 => to_unsigned(0, 8),122 => to_unsigned(0, 8),123 => to_unsigned(0, 8),
		124 => to_unsigned(0, 8),125 => to_unsigned(0, 8),126 => to_unsigned(0, 8),127 => to_unsigned(0, 8)
	);
	
	type fbtab_type is array(0 to 7) of unsigned(4 downto 0);
	constant fbtab: fbtab_type := (
		0 => to_unsigned(31, 5),
		1 => to_unsigned(7, 5),
		2 => to_unsigned(6, 5),
		3 => to_unsigned(5, 5),
		4 => to_unsigned(4, 5),
		5 => to_unsigned(3, 5),
		6 => to_unsigned(2, 5),
		7 => to_unsigned(1, 5)
	);
	
	type algorithm_table_type is array(0 to 7) of algorithm_idx_type;
	constant algorithm_table: algorithm_table_type := (
		0 => algorithm0,
		1 => algorithm1,
		2 => algorithm2,
		3 => algorithm3,
		4 => algorithm4,
		5 => algorithm5,
		6 => algorithm6,
		7 => algorithm7
	);
	
	type operator_reg_type is record
		dp: unsigned(17 downto 0); -- as a function of block/fnum
		bn: unsigned(4 downto 0); -- as a function of block/fnum
		detune: unsigned(7 downto 0);
		multiple: unsigned(3 downto 0);
		totalLevel: unsigned(6 downto 0);
		attackRate: unsigned(5 downto 0);
		decayRate: unsigned(5 downto 0);
		sustainRate: unsigned(5 downto 0);
		sustainLevel: unsigned(6 downto 0);
		releaseRate: unsigned(5 downto 0);
		keyscale: unsigned(1 downto 0);
		envelope: unsigned(15 downto 0); -- calculated from eglevel and totalLevel
		-- FIXME SSG-EG
		-- FIXME AMON, AMS, PMS
		-- FIXME L/R channel
	end record;
	
	constant operator_reg_reset: operator_reg_type := (
		dp => to_unsigned(0, 18),
		bn => to_unsigned(0, 5),
		detune => to_unsigned(0, 8),
		multiple => to_unsigned(0, 4),
		totalLevel => to_unsigned(127, 7),
		attackRate => to_unsigned(0, 6),
		decayRate => to_unsigned(0, 6),
		sustainRate => to_unsigned(0, 6),
		sustainLevel => to_unsigned(0, 7),
		releaseRate => to_unsigned(0, 6),
		keyscale => to_unsigned(0, 2),
		envelope => to_unsigned(0, 16)
	);
	
	type operator4_reg_type is array(0 to 3) of operator_reg_type;
	
	type channel_state_type is (state_idle, state_prepare, state_envelope, state_envelope_calculate,
		state_op0, state_phase0, state_op1, state_phase1, state_op2, state_phase2, state_op3, state_phase3,
		state_accumulate, state_output);
	type channel_reg_type is record
		state: channel_state_type;
		-- (15 downto 8) is the fnum2 register, with block number;
		-- (7 downto 0) is the fnum1 register
		fnum: std_logic_vector(15 downto 0);
		opReg: operator4_reg_type; -- active operator parameters
		feedback: unsigned(4 downto 0);
		sampleBuffer: buffer4_type;
		algorithmIdx: algorithm_idx_type;
		key: std_logic_vector(3 downto 0);
		opParam: operator4_reg_type; -- exposed register space for operator parameters
		paramChanged: std_logic_vector(3 downto 0); -- flags for each operator
		opUpdate: std_logic_vector(3 downto 0); -- strobed high when preparing channel to request EG/PG reload
		envelopeUpdateAck: std_logic_vector(3 downto 0); -- accumulated acknowledgements from envelope generators
		nxtEnvelope: std_logic; -- strobed high to clock all envelope generators
		envelopeValid: std_logic_vector(3 downto 0); -- accumulated ready from envelope generators
		nxtOp: std_logic_vector(3 downto 0); -- strobed high to clock each operator
		nxtPhase: std_logic_vector(3 downto 0); --strobed high to clock each phase generator
		op1_input: signed(17 downto 0);
		op2_input: signed(17 downto 0);
		op3_input: signed(17 downto 0);
		output_tmp: signed(17 downto 0);
		output: signed(17 downto 0);
		valid: std_logic;
	end record;
	
	constant channel_reg_reset: channel_reg_type := (
		state => state_idle,
		fnum => X"0000",
		opReg => (others => operator_reg_reset),
		feedback => to_unsigned(1, 5), -- FIXME check this
		sampleBuffer => buffer4_reset,
		algorithmIdx => algorithm0,
		key => "0000",
		opParam => (others => operator_reg_reset),
		paramChanged => "0000",
		opUpdate => "0000",
		envelopeUpdateAck => "0000",
		nxtEnvelope => '0',
		envelopeValid => "0000",
		nxtOp => "0000",
		nxtPhase => "0000",
		op1_input => to_signed(0, 18),
		op2_input => to_signed(0, 18),
		op3_input => to_signed(0, 18),
		output_tmp => to_signed(0, 18),
		output => to_signed(0, 18),
		valid => '0'
	);
	
	signal reg: channel_reg_type := channel_reg_reset;
	signal ci_next: channel_reg_type;
	
	component operator_fb port (
		clk: in std_logic;
		rst: in std_logic;
		
		nxt: in std_logic;
		fb: in unsigned(4 downto 0);
		phase: in unsigned(31 downto 0);
		envelope: in unsigned(15 downto 0);
		
		output: out signed(17 downto 0);
		valid: out std_logic
	); end component;
	
	component operator port (
		clk: in std_logic;
		rst: in std_logic;
		
		nxt: in std_logic;
		input: in signed(31 downto 0);
		phase: in unsigned(31 downto 0);
		envelope: in unsigned(15 downto 0);
		
		output: out signed(17 downto 0);
		valid: out std_logic
	); end component;
	
	component phase_generator Port ( 
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		
		dp: in unsigned(17 downto 0);
		detune: in unsigned(7 downto 0);
		bn: in unsigned(4 downto 0);
		multiple: in unsigned(3 downto 0);
		
		update: in std_logic;
		nxt: in std_logic;
		phase: out unsigned(31 downto 0)
	); end component;
	signal op0_phase: unsigned(31 downto 0);
	signal op1_phase: unsigned(31 downto 0);
	signal op2_phase: unsigned(31 downto 0);
	signal op3_phase: unsigned(31 downto 0);
	
	component envelope_generator port ( 
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
	); end component;
	
	signal envelopeUpdateAck: std_logic_vector(3 downto 0);
	signal envelopeValid: std_logic_vector(3 downto 0);
	type eglevel_type is array(0 to 3) of unsigned(9 downto 0);
	signal eglevel: eglevel_type;
	
	-- output/valid from operators
	signal opValid: std_logic_vector(3 downto 0);
	signal op1_input: signed(31 downto 0);
	signal op2_input: signed(31 downto 0);
	signal op3_input: signed(31 downto 0);
	signal op0_output: signed(17 downto 0);
	signal op1_output: signed(17 downto 0);
	signal op2_output: signed(17 downto 0);
	signal op3_output: signed(17 downto 0);
begin

COMB: process(reg, rst, addr, we, data, key,
	envelopeUpdateAck, envelopeValid, eglevel,
	nxt, opValid, op0_output, op1_output, op2_output, op3_output)
	variable ci: channel_reg_type;
	
	variable dp: unsigned(17 downto 0); -- as a function of block/fnum
	variable bn: unsigned(4 downto 0); -- as a function of block/fnum
	
	variable target_addr: std_logic_vector(7 downto 0);
	
	variable dp_shift_amt: integer;
begin
	ci := reg;
	-- self-clearing
	ci.opUpdate := "0000";
	ci.nxtEnvelope := '0';
	ci.nxtOp := "0000";
	ci.nxtPhase := "0000";
	ci.valid := '0';
	
	target_addr := addr(7 downto 2) & "00";
	if(rst = '1') then
		ci := channel_reg_reset;
	else
		-- deal with writes to opParam
		if(we = '1') then
			case target_addr is
				-- DT/MULTI
				-- detune = (((data >> 4) & 0x07) * 0x20)
				--        = data(6 downto 4) <<5
				--        = data(6 downto 4) & "00000"
				-- multiple = data(3 downto 0)
				-- this forces a parameter update
				when X"30" => -- Detune/Multi, S1
					ci.opParam(0).detune := unsigned(data(6 downto 4) & "00000");
					ci.opParam(0).multiple := unsigned(data(3 downto 0));
					ci.paramChanged(0) := '1';
				when X"34" => -- Detune/Multi, S3
					ci.opParam(2).detune := unsigned(data(6 downto 4) & "00000");
					ci.opParam(2).multiple := unsigned(data(3 downto 0));
					ci.paramChanged(2) := '1';
				when X"38" => -- Detune/Multi, S2
					ci.opParam(1).detune := unsigned(data(6 downto 4) & "00000");
					ci.opParam(1).multiple := unsigned(data(3 downto 0));
					ci.paramChanged(1) := '1';
				when X"3C" => -- Detune/Multi, S4
					ci.opParam(3).detune := unsigned(data(6 downto 4) & "00000");
					ci.opParam(3).multiple := unsigned(data(3 downto 0));
					ci.paramChanged(3) := '1';
				-- TL (forces a parameter update)
				when X"40" =>
					ci.opParam(0).totalLevel := unsigned(data(6 downto 0));
					ci.paramChanged(0) := '1';
				when X"44" =>
					ci.opParam(2).totalLevel := unsigned(data(6 downto 0));
					ci.paramChanged(2) := '1';
				when X"48" =>
					ci.opParam(1).totalLevel := unsigned(data(6 downto 0));
					ci.paramChanged(1) := '1';
				when X"4C" =>
					ci.opParam(3).totalLevel := unsigned(data(6 downto 0));
					ci.paramChanged(3) := '1';
				-- KS/AR (forces a parameter update)
				when X"50" =>
					ci.opParam(0).keyScale := unsigned(data(7 downto 6));
					ci.opParam(0).attackRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(0) := '1';
				when X"54" =>
					ci.opParam(2).keyScale := unsigned(data(7 downto 6));
					ci.opParam(2).attackRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(2) := '1';
				when X"58" =>
					ci.opParam(1).keyScale := unsigned(data(7 downto 6));
					ci.opParam(1).attackRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(1) := '1';
				when X"5C" =>
					ci.opParam(3).keyScale := unsigned(data(7 downto 6));
					ci.opParam(3).attackRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(3) := '1';
				-- AM/DR (forces a parameter update)
				when X"60" =>
					-- TODO (AMON)
					--ci.opParam(0).amon := data(7);
					ci.opParam(0).decayRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(0) := '1';
				when X"64" =>
					-- TODO (AMON)
					--ci.opParam(2).amon := data(7);
					ci.opParam(2).decayRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(2) := '1';
				when X"68" =>
					-- TODO (AMON)
					--ci.opParam(1).amon := data(7);
					ci.opParam(1).decayRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(1) := '1';
				when X"6C" =>
					-- TODO (AMON)
					--ci.opParam(3).amon := data(7);
					ci.opParam(3).decayRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(3) := '1';
				-- SR (forces a parameter update)
				when X"70" =>
					ci.opParam(0).sustainRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(0) := '1';
				when X"74" =>
					ci.opParam(2).sustainRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(2) := '1';
				when X"78" =>
					ci.opParam(1).sustainRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(1) := '1';
				when X"7C" =>
					ci.opParam(3).sustainRate := unsigned(data(4 downto 0) & "0");
					ci.paramChanged(3) := '1';
				-- SL/RR (forces a parameter update)
				-- FIXME check the bit-accuracy of SL here
				when X"80" =>
					ci.opParam(0).sustainLevel := unsigned("0" & data(7 downto 4) & "00"); -- sl * 4
					ci.opParam(0).releaseRate := unsigned(data(3 downto 0) & "10"); -- rr * 4 + 2
					ci.paramChanged(0) := '1';
				when X"84" =>
					ci.opParam(2).sustainLevel := unsigned("0" & data(7 downto 4) & "00"); -- sl * 4
					ci.opParam(2).releaseRate := unsigned(data(3 downto 0) & "10"); -- rr * 4 + 2
					ci.paramChanged(2) := '1';
				when X"88" =>
					ci.opParam(1).sustainLevel := unsigned("0" & data(7 downto 4) & "00"); -- sl * 4
					ci.opParam(1).releaseRate := unsigned(data(3 downto 0) & "10"); -- rr * 4 + 2
					ci.paramChanged(1) := '1';
				when X"8C" =>
					ci.opParam(3).sustainLevel := unsigned("0" & data(7 downto 4) & "00"); -- sl * 4
					ci.opParam(3).releaseRate := unsigned(data(3 downto 0) & "10"); -- rr * 4 + 2
					ci.paramChanged(3) := '1';
				-- TODO (SSG-EG)
				when X"A0" => -- F-Number 1
					ci.fnum(7 downto 0) := data;
					-- recalculate dp/bn
					-- dp = (fnum & 2047) << ((fnum >> 11) & 7)
					dp_shift_amt := to_integer(unsigned(ci.fnum(13 downto 11)));
					dp := shift_left(unsigned("0000000" & ci.fnum(10 downto 0)), dp_shift_amt);
					-- bn = notetab[(fnum >> 7) & 127]
					bn := notetab(to_integer(unsigned(ci.fnum(13 downto 7))));
					-- assign this to every operator and update parameters
					for I in 0 to 3 loop
						ci.opParam(I).dp := dp;
						ci.opParam(I).bn := bn;
						ci.paramChanged(I) := '1';
					end loop;
				when X"A4" => -- Block/F-Number 2
					ci.fnum(15 downto 8) := data;
				when X"B0" => -- feedback / algorithm
					ci.feedback := fbtab(to_integer(unsigned(data(5 downto 3))));
					ci.algorithmIdx := algorithm_table(to_integer(unsigned(data(2 downto 0))));
				when others => null;
			end case;
		end if;
		-- handle channel clocking
		case reg.state is
			when state_idle =>
				if(nxt = '1') then -- TODO check interactions between nxt and we
					-- check paramChanged for each operator
					for I in 0 to 3 loop
						if(reg.paramChanged(I) = '1') then
							ci.opReg(I) := reg.opParam(I);
							if(we = '0') then
								ci.paramChanged(I) := '0';
							end if;
							ci.opUpdate(I) := '1';
							ci.envelopeUpdateAck(I) := '0';
						else
							ci.envelopeUpdateAck(I) := '1';
						end if;
					end loop;
					ci.key := key;
					for I in 0 to 3 loop
						-- a change in key level counts as a parameter change
						if(reg.key(I) /= key(I)) then
							ci.opUpdate(I) := '1';
							ci.envelopeUpdateAck(I) := '0';
						end if;
					end loop;
					ci.sampleBuffer := buffer4_reset;
					ci.state := state_prepare;
				end if;
			when state_prepare =>
				-- wait for all envelope generators to complete update
				if(reg.envelopeUpdateAck = "1111") then
					-- clock envelope generators in parallel
					ci.nxtEnvelope := '1';
					ci.envelopeValid := "0000";
					ci.state := state_envelope;
				else
					for I in 0 to 3 loop
						ci.envelopeUpdateAck(I) := reg.envelopeUpdateAck(I) or envelopeUpdateAck(I);
					end loop;
				end if;
			when state_envelope =>
				-- wait for all envelope generators to recalculate
				if(reg.envelopeValid = "1111") then
					ci.state := state_envelope_calculate;
				else
					for I in 0 to 3 loop
						ci.envelopeValid(I) := reg.envelopeValid(I) or envelopeValid(I);
					end loop;
				end if;
			when state_envelope_calculate =>
				-- egout = cltab[eglevel] * gaintab[totalLevel]
				for I in 0 to 3 loop
					ci.opReg(I).envelope := cltab(to_integer(eglevel(I))) * gaintab(to_integer(reg.opReg(I).totalLevel));
				end loop;
				ci.state := state_op0;
			when state_op0 =>
				ci.nxtOp(0) := '1';
				ci.state := state_phase0;
			when state_phase0 =>
				-- wait for operator 0 to be valid
				if(opValid(0) = '1') then
					-- store output 0 in buffer 0
					ci.sampleBuffer(0) := op0_output;
					ci.nxtPhase(0) := '1';
					ci.state := state_op1;
				end if;
			when state_op1 =>
				-- set input 1 to buffer[algorithm[0]]
				ci.op1_input := reg.sampleBuffer(to_integer(reg.algorithmIdx(0)));
				ci.nxtOp(1) := '1';
				ci.state := state_phase1;
			when state_phase1 =>
				-- wait for operator 1 to be valid
				if(opValid(1) = '1') then
					-- ACCUMULATE output from operator 1 into buffer[algorithm[3]]
					ci.sampleBuffer(to_integer(reg.algorithmIdx(3))) := reg.sampleBuffer(to_integer(reg.algorithmIdx(3))) + op1_output;
					ci.nxtPhase(1) := '1';
					ci.state := state_op2;
				end if;
			when state_op2 =>
				-- set input 2 to buffer[algorithm[1]]
				ci.op2_input := reg.sampleBuffer(to_integer(reg.algorithmIdx(1)));
				ci.nxtOp(2) := '1';
				ci.state := state_phase2;
			when state_phase2 =>
				-- wait for operator 2 to be valid
				if(opValid(2) = '1') then
					-- accumulate output from operator 2 into buffer[algorithm[4]]
					ci.sampleBuffer(to_integer(reg.algorithmIdx(4))) := reg.sampleBuffer(to_integer(reg.algorithmIdx(4))) + op2_output;
					ci.nxtPhase(2) := '1';
					ci.state := state_op3;
				end if;
			when state_op3 =>
				-- set input 3 to buffer[algorithm[2]]
				ci.op3_input := reg.sampleBuffer(to_integer(reg.algorithmIdx(2)));
				ci.nxtOp(3) := '1';
				ci.state := state_phase3;
			when state_phase3 =>
				-- wait for operator 3 to be valid
				if(opValid(3) = '1') then
					-- store output to temporary register
					ci.output_tmp := op3_output;
					ci.nxtPhase(3) := '1';
					ci.state := state_accumulate;
				end if;
			when state_accumulate =>
				-- accumulate buffer[algorithm[5]] into temporary register
				ci.output_tmp := reg.output_tmp + reg.sampleBuffer(to_integer(reg.algorithmIdx(5)));
				ci.state := state_output;
			when state_output =>
				ci.output := reg.output_tmp;
				ci.valid := '1';
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

OP0: operator_fb port map (
	clk => clk,
	rst => rst,
	
	nxt => reg.nxtOp(0),
	fb => reg.feedback,
	phase => op0_phase,
	envelope => reg.opReg(0).envelope,
	output => op0_output,
	valid => opValid(0)
);
op1_input <= resize(reg.op1_input, 32);
OP1: operator port map (
	clk => clk,
	rst => rst,
	nxt => reg.nxtOp(1),
	input => op1_input,
	phase => op1_phase,
	envelope => reg.opReg(1).envelope,
	output => op1_output,
	valid => opValid(1)
);
op2_input <= resize(reg.op2_input, 32);
OP2: operator port map (
	clk => clk,
	rst => rst,
	nxt => reg.nxtOp(2),
	input => op2_input,
	phase => op2_phase,
	envelope => reg.opReg(2).envelope,
	output => op2_output,
	valid => opValid(2)
);
op3_input <= resize(reg.op3_input, 32);
OP3: operator port map (
	clk => clk,
	rst => rst,
	nxt => reg.nxtOp(3),
	input => op3_input,
	phase => op3_phase,
	envelope => reg.opReg(3).envelope,
	output => op3_output,
	valid => opValid(3)
);

PHASE0: phase_generator port map (
	clk => clk,
	rst => rst,
	dp => reg.opReg(0).dp,
	detune => reg.opReg(0).detune,
	bn => reg.opReg(0).bn,
	multiple => reg.opReg(0).multiple,
	update => reg.opUpdate(0),
	nxt => reg.nxtPhase(0),
	phase => op0_phase
);
PHASE1: phase_generator port map (
	clk => clk,
	rst => rst,
	dp => reg.opReg(1).dp,
	detune => reg.opReg(1).detune,
	bn => reg.opReg(1).bn,
	multiple => reg.opReg(1).multiple,
	update => reg.opUpdate(1),
	nxt => reg.nxtPhase(1),
	phase => op1_phase
);
PHASE2: phase_generator port map (
	clk => clk,
	rst => rst,
	dp => reg.opReg(2).dp,
	detune => reg.opReg(2).detune,
	bn => reg.opReg(2).bn,
	multiple => reg.opReg(2).multiple,
	update => reg.opUpdate(2),
	nxt => reg.nxtPhase(2),
	phase => op2_phase
);
PHASE3: phase_generator port map (
	clk => clk,
	rst => rst,
	dp => reg.opReg(3).dp,
	detune => reg.opReg(3).detune,
	bn => reg.opReg(3).bn,
	multiple => reg.opReg(3).multiple,
	update => reg.opUpdate(3),
	nxt => reg.nxtPhase(3),
	phase => op3_phase
);

ENVELOPE_GENERATORS: for I in 0 to 3 generate
	EG: envelope_generator port map (
		clk => clk,
		rst => rst,
		
		update => reg.opUpdate(I),
		update_ack => envelopeUpdateAck(I),
		keyOn => reg.key(I),
		attackRate => reg.opReg(I).attackRate,
		decayRate => reg.opReg(I).decayRate,
		sustainRate => reg.opReg(I).sustainRate,
		sustainLevel => reg.opReg(I).sustainLevel,
		releaseRate => reg.opReg(I).releaseRate,
		keyscale => reg.opReg(I).keyscale,
		blockNumber => reg.opReg(I).bn,
		
		nxt => reg.nxtEnvelope,
		eglevel => eglevel(I),
		valid => envelopeValid(I)
	);
end generate ENVELOPE_GENERATORS;

-- outputs
output <= reg.output;
valid <= reg.valid;

end Behavioral;

