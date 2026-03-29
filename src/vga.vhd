LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

LIBRARY work;

ENTITY VGA IS 
	PORT
	(
		CLK	:  IN STD_LOGIC;
		CLKM	:  IN STD_LOGIC;
		RESET_n	:  IN STD_LOGIC;

		CONTROL	:  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		HSCROLLM:  IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		VSCROLLM:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		HSCROLLS:  IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		VSCROLLS:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		HSCROLLB:  IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		VSCROLLB:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		HCURSOR	:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);
		VCURSOR	:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);

		M_SPLIT0:  IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		M_SPLIT1:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);

		S_SPLIT0:  IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		S_SPLIT1:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);

		B_SPLIT0:  IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		B_SPLIT1:  IN STD_LOGIC_VECTOR(6 DOWNTO 0);

		BLANK	:  IN STD_LOGIC;

		H       :  IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		V       :  IN STD_LOGIC_VECTOR(11 DOWNTO 0);

		ANIMAT	:  IN STD_LOGIC_VECTOR(3 DOWNTO 0);

		M_COLOR	: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		S_COLOR	: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		B_COLOR	: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);

		MSEL	: OUT STD_LOGIC;
		MA	: OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		MDi	:  IN STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END;

ARCHITECTURE rtl OF VGA IS 

TYPE dot_state_type IS  (STEP0, STEP1, STEP2, STEP3, STEP4, STEP5, STEP6, STEP7);

ALIAS   CURSOR_ENA      : STD_LOGIC IS CONTROL(24);
ALIAS   MMULTY_ENA      : STD_LOGIC IS CONTROL( 3);
ALIAS   SMULTY_ENA      : STD_LOGIC IS CONTROL(11);
ALIAS   BMULTY_ENA      : STD_LOGIC IS CONTROL(19);
ALIAS   MSPLIT_ENA      : STD_LOGIC IS CONTROL(28);
ALIAS   SSPLIT_ENA      : STD_LOGIC IS CONTROL(29);
ALIAS   BSPLIT_ENA      : STD_LOGIC IS CONTROL(30);

SIGNAL	DOTBLANK	: STD_LOGIC;

-------------------------------------------------------------------------------
SIGNAL	M_DOTCLK	: STD_LOGIC;
SIGNAL	M_DOTStep	: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	M_F08x08	: STD_LOGIC;
SIGNAL	M_F08x16	: STD_LOGIC;
SIGNAL	M_F16x08	: STD_LOGIC;
SIGNAL	M_F16x16	: STD_LOGIC;
SIGNAL	M_F16x32	: STD_LOGIC;
SIGNAL	M_F32x16	: STD_LOGIC;
SIGNAL	M_F32x32	: STD_LOGIC;
SIGNAL	M_GRAF		: STD_LOGIC;

SIGNAL	M_FMULTY	: STD_LOGIC;
SIGNAL	M_EXTATR	: STD_LOGIC;
SIGNAL	M_FEXTEND	: STD_LOGIC;

SIGNAL	M_F08Pix	: STD_LOGIC;
SIGNAL	M_F16Pix	: STD_LOGIC;
SIGNAL	M_F32Pix	: STD_LOGIC;
SIGNAL	M_F08Line	: STD_LOGIC;
SIGNAL	M_F16Line	: STD_LOGIC;
SIGNAL	M_F32Line	: STD_LOGIC;

SIGNAL	M_FONT_1bpp	: STD_LOGIC;
SIGNAL	M_FONT_2bpp	: STD_LOGIC;
SIGNAL	M_FONT_4bpp	: STD_LOGIC;
SIGNAL	M_FONT_1bppE	: STD_LOGIC;

SIGNAL	M_SCALE_x1	: STD_LOGIC;
SIGNAL	M_SCALE_x2	: STD_LOGIC;
SIGNAL	M_SCALE_x4	: STD_LOGIC;

-------------------------------------------------------------------------------
SIGNAL	S_DOTCLK	: STD_LOGIC;
SIGNAL	S_DOTStep	: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	S_F08x08	: STD_LOGIC;
SIGNAL	S_F08x16	: STD_LOGIC;
SIGNAL	S_F16x08	: STD_LOGIC;
SIGNAL	S_F16x16	: STD_LOGIC;
SIGNAL	S_F16x32	: STD_LOGIC;
SIGNAL	S_F32x16	: STD_LOGIC;
SIGNAL	S_F32x32	: STD_LOGIC;
SIGNAL	S_F64X64	: STD_LOGIC;

SIGNAL	S_FMULTY	: STD_LOGIC;
SIGNAL	S_EXTATR	: STD_LOGIC;
SIGNAL	S_FEXTEND	: STD_LOGIC;

SIGNAL	S_F08Pix	: STD_LOGIC;
SIGNAL	S_F16Pix	: STD_LOGIC;
SIGNAL	S_F32Pix	: STD_LOGIC;
SIGNAL	S_F08Line	: STD_LOGIC;
SIGNAL	S_F16Line	: STD_LOGIC;
SIGNAL	S_F32Line	: STD_LOGIC;

SIGNAL	S_FONT_1bpp	: STD_LOGIC;
SIGNAL	S_FONT_2bpp	: STD_LOGIC;
SIGNAL	S_FONT_4bpp	: STD_LOGIC;
SIGNAL	S_FONT_1bppE	: STD_LOGIC;

SIGNAL	S_DISABLE	: STD_LOGIC;
SIGNAL	S_SCALE_x1	: STD_LOGIC;
SIGNAL	S_SCALE_x2	: STD_LOGIC;
SIGNAL	S_SCALE_x4	: STD_LOGIC;

-------------------------------------------------------------------------------
SIGNAL	B_DOTCLK	: STD_LOGIC;
SIGNAL	B_DOTStep	: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	B_F08x08	: STD_LOGIC;
SIGNAL	B_F08x16	: STD_LOGIC;
SIGNAL	B_F16x08	: STD_LOGIC;
SIGNAL	B_F16x16	: STD_LOGIC;

SIGNAL	B_FONT_1bpp	: STD_LOGIC;
SIGNAL	B_FONT_2bpp	: STD_LOGIC;

SIGNAL	B_DISABLE	: STD_LOGIC;
SIGNAL	B_SCALE_x1	: STD_LOGIC;
SIGNAL	B_SCALE_x2	: STD_LOGIC;
SIGNAL	B_SCALE_x4	: STD_LOGIC;

SIGNAL	B_FMULTY	: STD_LOGIC;
SIGNAL	B_EXTATR	: STD_LOGIC;
SIGNAL	B_FEXTEND	: STD_LOGIC;

SIGNAL	B_F08Pix	: STD_LOGIC;
SIGNAL	B_F16Pix	: STD_LOGIC;
SIGNAL	B_F08Line	: STD_LOGIC;
SIGNAL	B_F16Line	: STD_LOGIC;

SIGNAL	M_FBIG     : STD_LOGIC;
SIGNAL	S_FBIG     : STD_LOGIC;

SIGNAL	MvFONT     : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	MvFONT_C   : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	M_FONT0	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	M_FONT1	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	M_FONT2	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	S_FONT0	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	S_FONT1	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	S_FONT2	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	B_FONT0	: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	B_FONT1	: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL	G_ADDR	: STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	CURSOR	: STD_LOGIC;

SIGNAL  M_X	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  M_Y	: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL  M_Xs	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  M_Ys	: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL  M_V	: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL  M_COLs	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL  M_ROWs	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	M_ADDR	: STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL  M_PALETE: STD_LOGIC_VECTOR(8 DOWNTO 2);
SIGNAL	M_HByte	: STD_LOGIC;
SIGNAL	M_HFlip	: STD_LOGIC;
SIGNAL	MC	: STD_LOGIC;

SIGNAL	M_VF	: STD_LOGIC;
SIGNAL	M_HF	: STD_LOGIC;
SIGNAL	M_Animat: STD_LOGIC;
SIGNAL	M_TileIdx0	: STD_LOGIC;
SIGNAL	M_TileIdx1	: STD_LOGIC;
SIGNAL  M_COL	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL  M_LINE	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL  M_FONT	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  M_FADDR	: STD_LOGIC_VECTOR(15 DOWNTO 1);
SIGNAL	M_FA00	: STD_LOGIC;
SIGNAL	M_FA01	: STD_LOGIC;

SIGNAL	S_VF	: STD_LOGIC;
SIGNAL	S_HF	: STD_LOGIC;
SIGNAL	S_Animat: STD_LOGIC;
SIGNAL	S_TileIdx0	: STD_LOGIC;
SIGNAL	S_TileIdx1	: STD_LOGIC;
SIGNAL  S_COL	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL  S_LINE	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL  S_FONT	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  S_FADDR	: STD_LOGIC_VECTOR(15 DOWNTO 1);
SIGNAL	S_FA00	: STD_LOGIC;
SIGNAL	S_FA01	: STD_LOGIC;

SIGNAL  S_X	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  S_Y	: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL  S_Xs	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  S_Ys	: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL  S_V	: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL  S_COLs	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL  S_ROWs	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	S_ADDR	: STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL  S_PALETE: STD_LOGIC_VECTOR(8 DOWNTO 2);
SIGNAL	S_HByte	: STD_LOGIC;
SIGNAL	S_HFlip	: STD_LOGIC;
SIGNAL	SC	: STD_LOGIC;

SIGNAL  B_X	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  B_Y	: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL  B_Xs	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL  B_Ys	: STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL  B_V	: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL  B_COLs	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL  B_ROWs	: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	B_ADDR	: STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL  B_PALETE: STD_LOGIC_VECTOR(5 DOWNTO 2);

SIGNAL	STAGE0	: STD_LOGIC;
SIGNAL	STAGE1	: STD_LOGIC;
SIGNAL	STAGE2	: STD_LOGIC;
SIGNAL	STAGE3	: STD_LOGIC;
SIGNAL	STAGE4	: STD_LOGIC;
SIGNAL	STAGE5	: STD_LOGIC;
SIGNAL	STAGE6	: STD_LOGIC;
SIGNAL	STAGE7	: STD_LOGIC;

TYPE load_state_type IS (IDLE, LOAD0, LOAD1, LOAD2, LOAD3, LOAD4, LOAD5, LOAD6, LOAD7, CPU0, CPU1, SPR, DONE);
SIGNAL	STATE	: load_state_type;

BEGIN 
-------------------------------------------------------------------------------
-- 0x00000 - 0x07FFF = 32768 WORDS screen buffer master
-- 0x08000 - 0x0FFFF = 32768 WORDS screen buffer slave
-- 0x10000 - 0x1FFFF = 65536 WORDS fonts
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Resolution        1024 x 768
--
-- Virtual screen     256 x 128 = 32768 words
--
--MEM_SCR_08x08x1 --  128 x  96 = 12288
--MEM_SCR_08x08x2 --   64 x  48 =  3072
--MEM_SCR_08x08x4 --   32 x  24 =   768

--MEM_SCR_08x16x1 --  128 x  48 =  6144
--MEM_SCR_16x08x1 --   64 x  96 =  6144

--MEM_SCR_16x16x1 --   64 x  48 =  3072
--MEM_SCR_16x16x2 --   32 x  24 =   768
--MEM_SCR_16x16x4 --   16 x  12 =   192

--MEM_SCR_16x32x1 --   64 x  24 =  1536
--MEM_SCR_32x16x1 --   32 x  48 =  1536
--MEM_SCR_32x32x1 --   32 x  24 =   768
-------------------------------------------------------------------------------
--MEM_SCR_GRAFx1  -- 1024 x 768 = 98304 bytes
--MEM_SCR_GRAFx2  --  512 x 384 = 49152
--MEM_SCR_GRAFx4  --  256 x 192 = 24576
-------------------------------------------------------------------------------
-- Tile map format - 16 bit
-- 15-12 - background color
-- 11-8  - fg color
-- 7-0   - tile index
--
-- for next modes tile map format - 16 bit
-- 15    - VFlip
-- 14    - HFlip
-- 13    - Animation block (tile index mod 4/8, tile index 0 set animation size 4 or 8 tiles)
-- 12    - tile index 8 (8/16 pixel modes)
-- 11    - tile index 9 (8 pixel mode only)
-- 10-8  - Palette
-- 7-0   - tile index
--
--
-- ExFn - Extended font
-- AnBlk - Animation block
-- AnSiz - Animation size (0 bit in tile index if set AnBlk)
-- Pal - Palette
--                                  |  7  |  6  |  5  |  4  |  3  |  2  |  1  |  0  |CTRL7|TILE0|
--                                  |VFlip|HFlip|AnBlk|ExFn0|ExFn1|Pal2 |Pal1 |Pal0 |MFont|AnSiz|
-- Mode 08x08 1bppE (  8 bit font ) | yes   yes   yes   yes   yes   ext   ext   ext   yes   yes
-- Mode 08x16 1bppE (  8 bit font ) | yes   yes   yes   yes   yes   ext   ext   ext   yes   yes
--                                                                                             
-- Mode 08x08 2bpp (  16 bit font ) | yes   yes   yes   yes   yes   yes   yes   yes   yes   yes
-- Mode 08x16 2bpp (  16 bit font ) | yes   yes   yes   yes   yes   yes   yes   yes   yes   yes
-- Mode 16x08 2bpp (  32 bit font ) | yes   yes   yes   no    yes   yes   yes   yes   yes   yes
-- Mode 16x16 2bpp (  32 bit font ) | yes   yes   yes   no    yes   yes   yes   yes   yes   yes
--                                                                                             
-- Mode 08x08 4bpp (  32 bit font ) | yes   yes   yes   no    yes   ext   ext   ext   yes   yes
-- Mode 08x16 4bpp (  32 bit font ) | yes   yes   yes   no    yes   ext   ext   ext   yes   yes
-- Mode 16x08 4bpp (  64 bit font ) | yes   yes   yes   no    no    ext   ext   ext   yes   yes
-- Mode 16x16 4bpp (  64 bit font ) | yes   yes   yes   no    no    ext   ext   ext   yes   yes
--                                                                                             
-- Mode 16x32 2bpp (  32 bit font ) | yes   yes   yes   no    no    yes   yes   yes   no    yes
-- Mode 32x16 2bpp (  64 bit font ) | yes   yes   yes   no    no    yes   yes   yes   no    yes
-- Mode 32x32 2bpp (  64 bit font ) | yes   yes   yes   no    no    yes   yes   yes   no    yes
--                                                                                             
-- Mode 16x32 4bpp (  64 bit font ) | yes   yes   yes   no    no    ext   ext   ext   no    yes
-- Mode 32x16 4bpp ( 128 bit font ) | yes   yes   yes   no    no    ext   ext   ext   no    yes
-- Mode 32x32 4bpp ( 128 bit font ) | yes   yes   yes   no    no    ext   ext   ext   no    yes
--
-------------------------------------------------------------------------------
-- Address bits:
-- 
-- |15.14|13.........6|5....2|1.....0|
-- +-----+------------+------+-------+
-- |Block| FONT       | LINE |COL/ExF|
-- +-----+------------+------+-------+
--
-- Addr  | Char | Lo              | Hi              | ExtFn1 | ExtFn0
--       |      |                 |                 |        | 
--       |      | 8x8 1bpp        |                 |        | 
-- 00000 |  0   | Bitmap L0/C7-0  | None/color      |   0    |   0
-- 00001 |  0   | Bitmap L0/C7-0  | None/color      |   0    |   1
-- 00002 |  0   | Bitmap L0/C7-0  | None/color      |   1    |   0
-- 00003 |  0   | Bitmap L0/C7-0  | None/color      |   1    |   1
-- ..... |      |                 |                 |        |      
-- 00004 |  0   | Bitmap L1/C7-0  | None/color      |   0    |   0
-- 00005 |  0   | Bitmap L1/C7-0  | None/color      |   0    |   1
-- 00006 |  0   | Bitmap L1/C7-0  | None/color      |   1    |   0
-- 00007 |  0   | Bitmap L1/C7-0  | None/color      |   1    |   1
-- ..... |      |                 |                 |        |
-- ..... |      |                 |                 |        |      
-- 00040 |  1   | Bitmap L0/C7-0  | None/color      |   0    |   0
--  ...  |      |                 |                 |        |
--       |      |                 |                 |        |
--       |      | 8x8 2bpp        |                 |        | 
-- 00000 |  0   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   0    |   0
-- 00001 |  0   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   0    |   1
-- 00002 |  0   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   1    |   0
-- 00003 |  0   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   1    |   1
-- ..... |      |                 |                 |        |      
-- 00004 |  0   | Bitmap L1/C7-4  | Bitmap L1/C3-0  |   0    |   0
-- 00005 |  0   | Bitmap L1/C7-4  | Bitmap L1/C3-0  |   0    |   1
-- 00006 |  0   | Bitmap L1/C7-4  | Bitmap L1/C3-0  |   1    |   0
-- 00007 |  0   | Bitmap L1/C7-4  | Bitmap L1/C3-0  |   1    |   1
-- ..... |      |                 |                 |        |      
-- ..... |      |                 |                 |        |
-- 00040 |  1   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   0    |   0
--  ...  |      |                 |                 |        |
--       |      |                 |                 |        | 
--       |      | 8x8 4bpp        |                 |        | 
-- 00000 |  0   | Bitmap L0/C7-6  | Bitmap L0/C5-4  |   0    |  none
-- 00001 |  0   | Bitmap L0/C3-2  | Bitmap L0/C1-0  |   0    |  none
-- 00002 |  0   | Bitmap L0/C7-6  | Bitmap L0/C5-4  |   1    |  none
-- 00003 |  0   | Bitmap L0/C3-2  | Bitmap L0/C1-0  |   1    |  none
-- ..... |      |                 |                 |        |      
-- 00004 |  0   | Bitmap L1/C7-6  | Bitmap L1/C5-4  |   0    |  none
-- 00005 |  0   | Bitmap L1/C3-2  | Bitmap L1/C1-0  |   0    |  none
-- 00006 |  0   | Bitmap L1/C7-6  | Bitmap L1/C5-4  |   1    |  none
-- 00007 |  0   | Bitmap L1/C3-2  | Bitmap L1/C1-0  |   1    |  none
-- ..... |      |                 |                 |        |      
-- ..... |      |                 |                 |        |      
-- 00040 |  1   | Bitmap L0/C7-6  | Bitmap L0/C5-4  |   0    |  none
--  ...  |      |                 |                 |        |
--------------------------------------------------------------------------------
--       |      | 16x16 1bpp      |                 |        | 
-- 00000 |  0   | Bitmap L0/C7-0  | Bitmap L0/C15-8 |  none  |  none
-- 00001 |  0   | Bitmap L0/C7-0  | Bitmap L0/C15-8 |  none  |  none
-- 00002 |  0   | Bitmap L0/C7-0  | Bitmap L0/C15-8 |  none  |  none
-- 00003 |  0   | Bitmap L0/C7-0  | Bitmap L0/C15-8 |  none  |  none
-- ..... |      |                 |                 |        |      
-- 00004 |  0   | Bitmap L1/C7-0  | Bitmap L1/C15-8 |  none  |  none
-- 00005 |  0   | Bitmap L1/C7-0  | Bitmap L1/C15-8 |  none  |  none
-- 00006 |  0   | Bitmap L1/C7-0  | Bitmap L1/C15-8 |  none  |  none
-- 00007 |  0   | Bitmap L1/C7-0  | Bitmap L1/C15-8 |  none  |  none
-- ..... |      |                 |                 |        |      
-- ..... |      |                 |                 |        |      
-- 00040 |  1   | Bitmap L0/C7-0  | Bitmap L0/C15-8 |  none  |  none
--  ...  |      |                 |                 |        |
--       |      |                 |                 |        |
--       |      | 16x16 2bpp      |                 |        | 
-- 00000 |  0   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   0    |  none
-- 00001 |  0   | Bitmap L0/C15-12| Bitmap L0/C11-8 |   0    |  none
-- 00002 |  0   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   1    |  none
-- 00003 |  0   | Bitmap L0/C15-12| Bitmap L0/C11-8 |   1    |  none
-- ..... |      |                 |                 |        |      
-- 00004 |  0   | Bitmap L1/C7-4  | Bitmap L1/C3-0  |   0    |  none
-- 00005 |  0   | Bitmap L1/C15-12| Bitmap L1/C11-8 |   0    |  none
-- 00006 |  0   | Bitmap L1/C7-4  | Bitmap L1/C3-0  |   1    |  none
-- 00007 |  0   | Bitmap L1/C15-12| Bitmap L1/C11-8 |   1    |  none
-- ..... |      |                 |                 |        |      
-- ..... |      |                 |                 |        |      
-- 00040 |  1   | Bitmap L0/C7-4  | Bitmap L0/C3-0  |   0    |  none
--  ...  |      |                 |                 |        |
--       |      |                 |                 |        | 
--       |      | 16x16 4bpp      |                 |        | 
-- 00000 |  0   | Bitmap L0/C7-6  | Bitmap L0/C5-4  |  none  |  none
-- 00001 |  0   | Bitmap L0/C3-2  | Bitmap L0/C1-0  |  none  |  none
-- 00002 |  0   | Bitmap L0/C15-14| Bitmap L0/C13-12|  none  |  none
-- 00003 |  0   | Bitmap L0/C11-10| Bitmap L0/C9-8  |  none  |  none
-- ..... |      |                 |                 |        |      
-- 00004 |  0   | Bitmap L1/C7-6  | Bitmap L1/C5-4  |  none  |  none
-- 00005 |  0   | Bitmap L1/C3-2  | Bitmap L1/C1-0  |  none  |  none
-- 00006 |  0   | Bitmap L1/C15-14| Bitmap L1/C13-12|  none  |  none
-- 00007 |  0   | Bitmap L1/C11-10| Bitmap L1/C9-8  |  none  |  none
-- ..... |      |                 |                 |        |      
-- ..... |      |                 |                 |        |      
-- 00040 |  1   | Bitmap L0/C7-6  | Bitmap L0/C5-4  |  none  |  none
--  ...  |      |                 |                 |        |
-------------------------------------------------------------------------------
-- 
-- |15.........8|7....3|2.....0|
-- +------------+------+-------+
-- | FONT       | LINE |COL/ExF|
-- +------------+------+-------+
--
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- STATIC CONFIGURATION -------------------------------------------------------
-------------------------------------------------------------------------------
-- Master plane
-------------------------------------------------------------------------------
M_F08x08     <= NOT(CONTROL(2)) AND NOT(CONTROL(1)) AND NOT(CONTROL(0));
M_F08x16     <= NOT(CONTROL(2)) AND NOT(CONTROL(1)) AND     CONTROL(0);
M_F16x08     <= NOT(CONTROL(2)) AND     CONTROL(1)  AND NOT(CONTROL(0));
M_F16x16     <= NOT(CONTROL(2)) AND     CONTROL(1)  AND     CONTROL(0);

M_GRAF       <=     CONTROL(2)  AND NOT(CONTROL(1)) AND NOT(CONTROL(0));
M_F16x32     <=     CONTROL(2)  AND NOT(CONTROL(1)) AND     CONTROL(0);
M_F32x16     <=     CONTROL(2)  AND     CONTROL(1)  AND NOT(CONTROL(0));
M_F32x32     <=     CONTROL(2)  AND     CONTROL(1)  AND     CONTROL(0);
-------------------------------------------------------------------------------
M_SCALE_x1   <= ( NOT(CONTROL(5)) AND NOT(CONTROL(4)) ) OR ( NOT(CONTROL(5)) AND CONTROL(4) );
M_SCALE_x2   <=       CONTROL(5)  AND NOT(CONTROL(4));
M_SCALE_x4   <=       CONTROL(5)  AND     CONTROL(4);

M_FONT_1bpp  <= ( NOT(CONTROL(7)) AND NOT(CONTROL(6)) ) OR ( CONTROL(7) AND CONTROL(6) AND NOT(M_F08Pix) );
M_FONT_2bpp  <=   NOT(CONTROL(7)) AND     CONTROL(6);
M_FONT_4bpp  <=       CONTROL(7)  AND NOT(CONTROL(6));
M_FONT_1bppE <=       CONTROL(7)  AND     CONTROL(6)    AND M_F08Pix;
-------------------------------------------------------------------------------
M_F08Pix     <= M_F08x08 OR M_F08x16;
M_F16Pix     <= M_F16x16 OR M_F16x08 OR M_F16x32;
M_F32Pix     <= M_F32x32 OR M_F32x16;

M_F08Line    <= M_F08x08 OR M_F16x08;
M_F16Line    <= M_F16x16 OR M_F08x16 OR M_F32x16;
M_F32Line    <= M_F32x32 OR M_F16x32;
-------------------------------------------------------------------------------
M_FMULTY     <= MMULTY_ENA AND NOT(CONTROL(2));

M_EXTATR     <= NOT(M_GRAF) AND NOT(M_FONT_1bpp);
M_FEXTEND    <= M_EXTATR AND NOT(CONTROL(2));

M_FBIG       <= M_F32x32 OR M_F16x32 OR M_F32x16;
-------------------------------------------------------------------------------
--M_GRAF4x4    <= M_FONT_4bpp AND M_SCALE_x4;
--M_GRAF2x4    <= M_FONT_2bpp AND M_SCALE_x4;
--M_GRAF2x2    <= M_FONT_2bpp AND M_SCALE_x2;
--M_GRAF1x4    <= M_FONT_1bpp AND M_SCALE_x4;
--M_GRAF1x2    <= M_FONT_1bpp AND M_SCALE_x2;
--M_GRAF1x1    <= M_FONT_1bpp AND M_SCALE_x1;

--M_GRAF+      <= (M_GRAF1x1 OR M_GRAF1x2 OR M_GRAF1x4 OR M_GRAF2x2 OR M_GRAF2x4 OR M_GRAF4x4) AND M_GRAF;
-------------------------------------------------------------------------------
M_DOTClk     <= '1' WHEN ( (M_SCALE_x1 = '1') OR
                           (M_SCALE_x2 = '1' AND H(0) = '0') OR
                           (M_SCALE_x4 = '1' AND H(1 DOWNTO 0) = "00") )
                           ELSE '0';
-------------------------------------------------------------------------------
M_COLs       <= H(6 DOWNTO 2) WHEN ( M_SCALE_x4 = '1' ) ELSE
                H(5 DOWNTO 1) WHEN ( M_SCALE_x2 = '1' ) ELSE
                H(4 DOWNTO 0);
-------------------------------------------------------------------------------
M_ROWs       <= V(6 DOWNTO 2) WHEN ( M_SCALE_x4 = '1' ) ELSE
                V(5 DOWNTO 1) WHEN ( M_SCALE_x2 = '1' ) ELSE
                V(4 DOWNTO 0);
-------------------------------------------------------------------------------
M_X          <= "00000" & H(9 DOWNTO 7) WHEN ( M_F32Pix = '1'  AND M_SCALE_x4 = '1' ) ELSE
                "0000"  & H(9 DOWNTO 6) WHEN ( M_F32Pix = '1'  AND M_SCALE_x2 = '1' ) OR
                                             ( M_F16Pix = '1'  AND M_SCALE_x4 = '1' ) ELSE
                "000"   & H(9 DOWNTO 5) WHEN ( M_F32Pix = '1'  AND M_SCALE_x1 = '1' ) OR
                                             ( M_F16Pix = '1'  AND M_SCALE_x2 = '1' ) OR
                                             ( M_F08Pix = '1'  AND M_SCALE_x4 = '1' ) ELSE
                "00"    & H(9 DOWNTO 4) WHEN ( M_F16Pix = '1'  AND M_SCALE_x1 = '1' ) OR
                                             ( M_F08Pix = '1'  AND M_SCALE_x2 = '1' ) ELSE
                '0'     & H(9 DOWNTO 3);
-------------------------------------------------------------------------------
M_Y          <= "0000" & V(9 DOWNTO 7) WHEN ( M_F32Line = '1'  AND M_SCALE_x4 = '1' ) ELSE
                "000"  & V(9 DOWNTO 6) WHEN ( M_F32Line = '1'  AND M_SCALE_x2 = '1' ) OR
                                            ( M_F16Line = '1'  AND M_SCALE_x4 = '1' ) ELSE
                "00"   & V(9 DOWNTO 5) WHEN ( M_F32Line = '1'  AND M_SCALE_x1 = '1' ) OR
                                            ( M_F16Line = '1'  AND M_SCALE_x2 = '1' ) OR
                                            ( M_F08Line = '1'  AND M_SCALE_x4 = '1' ) ELSE
                "0"    & V(9 DOWNTO 4) WHEN ( M_F16Line = '1'  AND M_SCALE_x1 = '1' ) OR
                                            ( M_F08Line = '1'  AND M_SCALE_x2 = '1' ) ELSE
                         V(9 DOWNTO 3);
-------------------------------------------------------------------------------
M_Xs         <= M_X + HSCROLLM WHEN MSPLIT_ENA = '0'     ELSE
                M_X            WHEN M_Y < '0' & M_SPLIT0 ELSE
                M_X + HSCROLLM WHEN M_Y <       M_SPLIT1 ELSE
                M_X;

M_Ys         <= M_Y + VSCROLLM WHEN MSPLIT_ENA = '0'     ELSE
                M_Y            WHEN M_Y < '0' & M_SPLIT0 ELSE
                M_Y + VSCROLLM WHEN M_Y <       M_SPLIT1 ELSE
                (M_Y(6) OR M_Y(5)) & (M_Y(5) XOR '1') & M_Y(4 DOWNTO 0);

M_V          <= "00"           WHEN M_FMULTY = '0'       ELSE
                V(9 DOWNTO 8)  WHEN MSPLIT_ENA = '0'     ELSE
                "01"           WHEN M_Y < '0' & M_SPLIT0 ELSE
                "10"           WHEN M_Y <       M_SPLIT1 ELSE
                "11";

-------------------------------------------------------------------------------
G_ADDR       <= "0000"    & V( 9 DOWNTO 2) & H( 9 DOWNTO 4) WHEN ( M_FONT_4bpp = '1' AND M_SCALE_x4 = '1' ) ELSE
--              "00000"   & V( 9 DOWNTO 2) & H( 9 DOWNTO 5) WHEN ( M_FONT_2bpp = '1' AND M_SCALE_x4 = '1' ) ELSE
                "000"     & V( 9 DOWNTO 1) & H( 9 DOWNTO 4) WHEN ( M_FONT_2bpp = '1' AND M_SCALE_x2 = '1' ) ELSE
--              "0000000" & V( 9 DOWNTO 2) & H( 9 DOWNTO 6) WHEN ( M_FONT_1bpp = '1' AND M_SCALE_x4 = '1' ) ELSE
--              "00000"   & V( 9 DOWNTO 1) & H( 9 DOWNTO 5) WHEN ( M_FONT_1bpp = '1' AND M_SCALE_x2 = '1' ) ELSE
                "00"      & V( 9 DOWNTO 0) & H( 9 DOWNTO 4);
-------------------------------------------------------------------------------
M_ADDR       <= G_ADDR WHEN M_GRAF = '1' ELSE "000" & M_Ys & M_Xs;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Slave plane
-------------------------------------------------------------------------------
S_F08x08      <=  NOT(CONTROL(10))  AND NOT(CONTROL(9)) AND NOT(CONTROL(8));
S_F08x16      <=  NOT(CONTROL(10))  AND NOT(CONTROL(9)) AND     CONTROL(8);
S_F16x08      <=  NOT(CONTROL(10))  AND     CONTROL(9)  AND NOT(CONTROL(8));
S_F16x16      <=  NOT(CONTROL(10))  AND     CONTROL(9)  AND     CONTROL(8);

S_F64x64      <=      CONTROL(10)   AND NOT(CONTROL(9)) AND NOT(CONTROL(8));
S_F16x32      <=      CONTROL(10)   AND NOT(CONTROL(9)) AND     CONTROL(8);
S_F32x16      <=      CONTROL(10)   AND     CONTROL(9)  AND NOT(CONTROL(8));
S_F32x32      <=      CONTROL(10)   AND     CONTROL(9)  AND     CONTROL(8);
-------------------------------------------------------------------------------
S_DISABLE     <=  NOT(CONTROL(13)) AND NOT(CONTROL(12));
S_SCALE_x1    <=  NOT(CONTROL(13)) AND     CONTROL(12);
S_SCALE_x2    <=      CONTROL(13)  AND NOT(CONTROL(12));
S_SCALE_x4    <=      CONTROL(13)  AND     CONTROL(12);

S_FONT_1bpp   <= (NOT(CONTROL(15)) AND NOT(CONTROL(14)) ) OR ( CONTROL(15) AND CONTROL(14) AND NOT(S_F08Pix) );
S_FONT_2bpp   <=  NOT(CONTROL(15)) AND     CONTROL(14);
S_FONT_4bpp   <=      CONTROL(15)  AND NOT(CONTROL(14));
S_FONT_1bppE  <=      CONTROL(15)  AND     CONTROL(14)    AND S_F08Pix;
-------------------------------------------------------------------------------
S_F08Pix     <= S_F08x08 OR S_F08x16;
S_F16Pix     <= S_F16x16 OR S_F16x08 OR S_F16x32 OR S_F64x64;
S_F32Pix     <= S_F32x32 OR S_F32x16;

S_F08Line    <= S_F08x08 OR S_F16x08;
S_F16Line    <= S_F16x16 OR S_F08x16 OR S_F32x16 OR S_F64x64;
S_F32Line    <= S_F32x32 OR S_F16x32;
-------------------------------------------------------------------------------
S_FMULTY     <= SMULTY_ENA AND NOT(CONTROL(10));

S_EXTATR     <= NOT(S_FONT_1bpp);
S_FEXTEND    <= S_EXTATR AND NOT(CONTROL(10));

S_FBIG       <= S_F32x32 OR S_F16x32 OR S_F32x16;
-------------------------------------------------------------------------------
S_DOTClk     <= '1' WHEN ( (S_SCALE_x1 = '1') OR
                           (S_SCALE_x2 = '1' AND H(0) = '0') OR
                           (S_SCALE_x4 = '1' AND H(1 DOWNTO 0) = "00") )
                           ELSE '0';
-------------------------------------------------------------------------------
S_COLs       <= H(6 DOWNTO 2) WHEN ( S_SCALE_x4 = '1' ) ELSE
                H(5 DOWNTO 1) WHEN ( S_SCALE_x2 = '1' ) ELSE
                H(4 DOWNTO 0);
-------------------------------------------------------------------------------
S_ROWs       <= V(6 DOWNTO 2) WHEN ( S_SCALE_x4 = '1' ) ELSE
                V(5 DOWNTO 1) WHEN ( S_SCALE_x2 = '1' ) ELSE
                V(4 DOWNTO 0);
-------------------------------------------------------------------------------
S_X          <= "00000" & H(9 DOWNTO 7) WHEN ( S_F32Pix = '1'  AND S_SCALE_x4 = '1' ) ELSE
                "0000"  & H(9 DOWNTO 6) WHEN ( S_F32Pix = '1'  AND S_SCALE_x2 = '1' ) OR
                                             ( S_F16Pix = '1'  AND S_SCALE_x4 = '1' ) ELSE
                "000"   & H(9 DOWNTO 5) WHEN ( S_F32Pix = '1'  AND S_SCALE_x1 = '1' ) OR
                                             ( S_F16Pix = '1'  AND S_SCALE_x2 = '1' ) OR
                                             ( S_F08Pix = '1'  AND S_SCALE_x4 = '1' ) ELSE
                "00"    & H(9 DOWNTO 4) WHEN ( S_F16Pix = '1'  AND S_SCALE_x1 = '1' ) OR
                                             ( S_F08Pix = '1'  AND S_SCALE_x2 = '1' ) ELSE
                '0'     & H(9 DOWNTO 3);
-------------------------------------------------------------------------------
S_Y          <= "0000" & V(9 DOWNTO 7) WHEN ( S_F32Line = '1'  AND S_SCALE_x4 = '1' ) ELSE
                "000"  & V(9 DOWNTO 6) WHEN ( S_F32Line = '1'  AND S_SCALE_x2 = '1' ) OR
                                            ( S_F16Line = '1'  AND S_SCALE_x4 = '1' ) ELSE
                "00"   & V(9 DOWNTO 5) WHEN ( S_F32Line = '1'  AND S_SCALE_x1 = '1' ) OR
                                            ( S_F16Line = '1'  AND S_SCALE_x2 = '1' ) OR
                                            ( S_F08Line = '1'  AND S_SCALE_x4 = '1' ) ELSE
                "0"    & V(9 DOWNTO 4) WHEN ( S_F16Line = '1'  AND S_SCALE_x1 = '1' ) OR
                                            ( S_F08Line = '1'  AND S_SCALE_x2 = '1' ) ELSE
                         V(9 DOWNTO 3);
-------------------------------------------------------------------------------
S_Xs         <= S_X + HSCROLLS WHEN SSPLIT_ENA = '0'     ELSE
                S_X            WHEN S_Y < '0' & S_SPLIT0 ELSE
                S_X + HSCROLLS WHEN S_Y <       S_SPLIT1 ELSE
                S_X;

S_Ys         <= S_Y + VSCROLLS WHEN SSPLIT_ENA = '0'     ELSE
                S_Y            WHEN S_Y < '0' & S_SPLIT0 ELSE
                S_Y + VSCROLLS WHEN S_Y <       S_SPLIT1 ELSE
                (S_Y(6) OR S_Y(5)) & (S_Y(5) XOR '1') & S_Y(4 DOWNTO 0);

S_V          <= "00"           WHEN S_FMULTY = '0'       ELSE
                V(9 DOWNTO 8)  WHEN SSPLIT_ENA = '0'     ELSE
                "01"           WHEN S_Y < '0' & S_SPLIT0 ELSE
                "10"           WHEN S_Y <       S_SPLIT1 ELSE
                "11";

-------------------------------------------------------------------------------
S_ADDR       <= "001" & S_Ys & S_Xs;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Background plane
-------------------------------------------------------------------------------
B_F08x08      <=  NOT(CONTROL(17)) AND NOT(CONTROL(16));
B_F08x16      <=  NOT(CONTROL(17)) AND     CONTROL(16);
B_F16x08      <=      CONTROL(17)  AND NOT(CONTROL(16));
B_F16x16      <=      CONTROL(17)  AND     CONTROL(16);
-------------------------------------------------------------------------------
B_FONT_1bpp   <=  NOT(CONTROL(22));
B_FONT_2bpp   <=      CONTROL(22);

B_DISABLE     <=  NOT(CONTROL(21)) AND NOT(CONTROL(20));
B_SCALE_x1    <=  NOT(CONTROL(21)) AND     CONTROL(20);
B_SCALE_x2    <=      CONTROL(21)  AND NOT(CONTROL(20));
B_SCALE_x4    <=      CONTROL(21)  AND     CONTROL(20);
-------------------------------------------------------------------------------
B_F08Pix     <= B_F08x08 OR B_F08x16;
B_F16Pix     <= B_F16x16 OR B_F16x08;

B_F08Line    <= B_F08x08 OR B_F16x08;
B_F16Line    <= B_F16x16 OR B_F08x16;
-------------------------------------------------------------------------------
B_FMULTY     <= BMULTY_ENA;

B_EXTATR     <= NOT(B_FONT_1bpp);
B_FEXTEND    <= B_EXTATR;
-------------------------------------------------------------------------------
B_DOTClk     <= '1' WHEN ( (B_SCALE_x1 = '1') OR
                           (B_SCALE_x2 = '1' AND H(0) = '0') OR
                           (B_SCALE_x4 = '1' AND H(1 DOWNTO 0) = "00") )
                           ELSE '0';
-------------------------------------------------------------------------------
B_COLs       <= H(6 DOWNTO 2) WHEN ( B_SCALE_x4 = '1' ) ELSE
                H(5 DOWNTO 1) WHEN ( B_SCALE_x2 = '1' ) ELSE
                H(4 DOWNTO 0);
-------------------------------------------------------------------------------
B_ROWs       <= V(6 DOWNTO 2) WHEN ( B_SCALE_x4 = '1' ) ELSE
                V(5 DOWNTO 1) WHEN ( B_SCALE_x2 = '1' ) ELSE
                V(4 DOWNTO 0);
-------------------------------------------------------------------------------
B_X          <= "0000"  & H(9 DOWNTO 6) WHEN ( B_F16Pix = '1'  AND B_SCALE_x4 = '1' ) ELSE
                "000"   & H(9 DOWNTO 5) WHEN ( B_F16Pix = '1'  AND B_SCALE_x2 = '1' ) OR
                                             ( B_F08Pix = '1'  AND B_SCALE_x4 = '1' ) ELSE
                "00"    & H(9 DOWNTO 4) WHEN ( B_F16Pix = '1'  AND B_SCALE_x1 = '1' ) OR
                                             ( B_F08Pix = '1'  AND B_SCALE_x2 = '1' ) ELSE
                '0'     & H(9 DOWNTO 3);
-------------------------------------------------------------------------------
B_Y          <= "000"  & V(9 DOWNTO 6) WHEN ( B_F16Line = '1'  AND B_SCALE_x4 = '1' ) ELSE
                "00"   & V(9 DOWNTO 5) WHEN ( B_F16Line = '1'  AND B_SCALE_x2 = '1' ) OR
                                            ( B_F08Line = '1'  AND B_SCALE_x4 = '1' ) ELSE
                "0"    & V(9 DOWNTO 4) WHEN ( B_F16Line = '1'  AND B_SCALE_x1 = '1' ) OR
                                            ( B_F08Line = '1'  AND B_SCALE_x2 = '1' ) ELSE
                         V(9 DOWNTO 3);
-------------------------------------------------------------------------------
B_Xs         <= B_X + HSCROLLB WHEN BSPLIT_ENA = '0'     ELSE
                B_X            WHEN B_Y < '0' & B_SPLIT0 ELSE
                B_X + HSCROLLB WHEN B_Y <       B_SPLIT1 ELSE
                B_X;

B_Ys         <= B_Y + VSCROLLB WHEN BSPLIT_ENA = '0'     ELSE
                B_Y            WHEN B_Y < '0' & B_SPLIT0 ELSE
                B_Y + VSCROLLB WHEN B_Y <       B_SPLIT1 ELSE
                (B_Y(6) OR B_Y(5)) & (B_Y(5) XOR '1') & B_Y(4 DOWNTO 0);

B_V          <= "00"           WHEN B_FMULTY = '0'       ELSE
                V(9 DOWNTO 8)  WHEN BSPLIT_ENA = '0'     ELSE
                "01"           WHEN B_Y < '0' & B_SPLIT0 ELSE
                "10"           WHEN B_Y <       B_SPLIT1 ELSE
                "11";

-------------------------------------------------------------------------------
B_ADDR       <= "010" & B_Ys & B_Xs;
-------------------------------------------------------------------------------
STAGE0       <=  NOT(H(2))  AND NOT(H(1)) AND NOT(H(0));
STAGE1       <=  NOT(H(2))  AND NOT(H(1)) AND     H(0);
STAGE2       <=  NOT(H(2))  AND     H(1)  AND NOT(H(0));
STAGE3       <=  NOT(H(2))  AND     H(1)  AND     H(0);
STAGE4       <=      H(2)   AND NOT(H(1)) AND NOT(H(0));
STAGE5       <=      H(2)   AND NOT(H(1)) AND     H(0);
STAGE6       <=      H(2)   AND     H(1)  AND NOT(H(0));
STAGE7       <=      H(2)   AND     H(1)  AND     H(0);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--PROCESS(CLKM)                 
--BEGIN                         
--  IF (RISING_EDGE(CLKM)) THEN 
--    CASE STATE IS             
--    WHEN IDLE =>              
--      IF STAGE0 = '1' THEN    
--        STATE <= LOAD0;       
--      END IF;                 
--    WHEN LOAD0 =>             
--      M_FONT0 <= MDi;         
--      STATE <= LOAD1;         
--    WHEN LOAD1 =>             
--      M_FONT1 <= MDi;         
--      STATE <= LOAD2;         
--    WHEN LOAD2 =>             
--      M_FONT2 <= MDi;         
--      STATE <= LOAD3;         
--    WHEN LOAD3 =>             
--      S_FONT0 <= MDi;         
--      STATE <= LOAD4;         
--    WHEN LOAD4 =>             
--      S_FONT1 <= MDi;         
--      STATE <= LOAD5;         
--    WHEN LOAD5 =>             
--      S_FONT2 <= MDi;         
--      STATE <= LOAD6;         
--    WHEN LOAD6 =>             
--      B_FONT0 <= MDi;         
--      STATE <= LOAD7;         
--    WHEN LOAD7 =>             
--      B_FONT1 <= MDi;         
--      STATE <= CPU0;          
--    WHEN CPU0 =>              
--      STATE <= CPU1;          
--    WHEN CPU1 =>              
--      STATE <= SPR;           
--    WHEN SPR =>               
--      STATE <= DONE;          
--    WHEN DONE =>              
--      STATE <= IDLE;          
--    WHEN OTHERS => NULL;      
--    END CASE;                 
--  END IF;                     
--END PROCESS;                  
-------------------------------------------------------------------------------
PROCESS(CLK)                  --
BEGIN                         --
  IF (RISING_EDGE(CLK)) THEN  --
    IF STAGE1 = '1' THEN      --
      M_FONT0 <= MDi;         --
    END IF;                   --
    IF STAGE2 = '1' THEN      --
      M_FONT1 <= MDi;         --
    END IF;                   --
    IF STAGE3 = '1' THEN      --
      M_FONT2 <= MDi;         --
    END IF;                   --
    IF STAGE4 = '1' THEN      --
      S_FONT0 <= MDi;         --
    END IF;                   --
    IF STAGE5 = '1' THEN      --
      S_FONT1 <= MDi;         --
    END IF;                   --
    IF STAGE6 = '1' THEN      --
      S_FONT2 <= MDi;         --
    END IF;                   --
  END IF;                     --
END PROCESS;                  --
-------------------------------------------------------------------------------
CURSOR      <= CURSOR_ENA AND M_FONT_1bpp WHEN VCURSOR = M_Y AND HCURSOR = M_X(6 DOWNTO 0) ELSE '0';
-------------------------------------------------------------------------------
M_VF        <= M_EXTATR  AND M_FONT0(15);
M_HF        <= M_EXTATR  AND M_FONT0(14);
M_Animat    <= M_EXTATR  AND M_FONT0(13);
M_TileIdx1  <= M_FEXTEND AND M_FONT0(12);
M_TileIdx0  <= M_FEXTEND AND M_FONT0(11);

M_LINE      <= M_ROWs WHEN M_VF = '0' ELSE NOT(M_ROWs);
M_COL       <= M_COLs WHEN M_HF = '0' ELSE NOT(M_COLs);
M_FONT      <= M_FONT0(7 DOWNTO 0) WHEN M_Animat = '0' ELSE 
               M_FONT0(7 DOWNTO 3) & ((M_FONT0(2) AND NOT(M_FONT(0))) OR (ANIMAT(2) AND M_FONT0(0))) & ANIMAT(1) & ANIMAT(0);
M_FADDR(15 DOWNTO 2) <= M_FONT & M_LINE & (M_F32Pix AND M_COL(4)) WHEN M_FBIG = '1' ELSE
                        M_V & M_FONT & (NOT(M_F08line) AND M_LINE(3)) & M_LINE(2 DOWNTO 0);
M_FADDR(1)  <= M_TileIdx1 WHEN M_F08Pix = '1'    ELSE NOT(M_FONT_1bpp OR M_FONT_1bppE) AND M_COL(3);
M_FA00      <= M_TileIdx0 WHEN M_FONT_4bpp = '0' ELSE M_COL(2);
M_FA01      <= M_TileIdx0 WHEN M_FONT_4bpp = '0' ELSE NOT(M_COL(2));
-------------------------------------------------------------------------------
S_VF        <= S_EXTATR  AND S_FONT0(15);
S_HF        <= S_EXTATR  AND S_FONT0(14);
S_Animat    <= S_EXTATR  AND S_FONT0(13);
S_TileIdx1  <= S_FEXTEND AND S_FONT0(12);
S_TileIdx0  <= S_FEXTEND AND S_FONT0(11);

S_LINE      <= S_ROWs WHEN S_VF = '0' ELSE NOT(S_ROWs);
S_COL       <= S_COLs WHEN S_HF = '0' ELSE NOT(S_COLs);
S_FONT      <= S_FONT0(7 DOWNTO 0) WHEN S_Animat = '0' ELSE 
               S_FONT0(7 DOWNTO 3) & ((S_FONT0(2) AND NOT(S_FONT(0))) OR (ANIMAT(2) AND S_FONT0(0))) & ANIMAT(1) & ANIMAT(0);
S_FADDR(15 DOWNTO 2) <= S_FONT & S_LINE & (S_F32Pix AND S_COL(4)) WHEN S_FBIG = '1' ELSE
                        S_V & S_FONT & (NOT(S_F08line) AND S_LINE(3)) & S_LINE(2 DOWNTO 0);
S_FADDR(1)  <= S_TileIdx1 WHEN S_F08Pix = '1'    ELSE NOT(S_FONT_1bpp OR S_FONT_1bppE) AND S_COL(3);
S_FA00      <= S_TileIdx0 WHEN S_FONT_4bpp = '0' ELSE S_COL(2);
S_FA01      <= S_TileIdx0 WHEN S_FONT_4bpp = '0' ELSE NOT(S_COL(2));
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
MC          <= M_FONT_4bpp OR M_FONT_1bppE WHEN M_FONT0(10 DOWNTO 8) /= "000" ELSE '0';
M_PALETE(8) <= MC;
M_PALETE(7) <= (M_V(1) AND NOT(MC));
M_PALETE(6) <=                                   MC AND M_FONT0(10);
M_PALETE(5) <= (M_V(0) AND NOT(MC))          OR (MC AND M_FONT0(9));
M_PALETE(4) <= (M_FONT_2bpp AND M_FONT0(10)) OR (MC AND M_FONT0(8));
M_PALETE(3) <=  M_FONT_2bpp AND M_FONT0(9);
M_PALETE(2) <=  M_FONT_2bpp AND M_FONT0(8);
-------------------------------------------------------------------------------
SC          <= S_FONT_4bpp OR S_FONT_1bppE WHEN S_FONT0(10 DOWNTO 8) /= "000" ELSE '0';
S_PALETE(8) <= SC;
S_PALETE(7) <= (S_V(1) AND NOT(SC));
S_PALETE(6) <=                                   SC AND S_FONT0(10);
S_PALETE(5) <= (S_V(0) AND NOT(SC))          OR (SC AND S_FONT0(9));
S_PALETE(4) <= (S_FONT_2bpp AND S_FONT0(10)) OR (SC AND S_FONT0(8));
S_PALETE(3) <=  S_FONT_2bpp AND S_FONT0(9);
S_PALETE(2) <=  S_FONT_2bpp AND S_FONT0(8);
-------------------------------------------------------------------------------
B_PALETE(5) <=  B_V(0);
B_PALETE(4) <=  B_FONT_2bpp AND B_FONT0(10);
B_PALETE(3) <=  B_FONT_2bpp AND B_FONT0(9);
B_PALETE(2) <=  B_FONT_2bpp AND B_FONT0(8);
-------------------------------------------------------------------------------
-- 000 - master screen (master tile map) 64 kbytes
-- 001 - slave screen  (slave tile map)  64 kbytes
-- 010 - background screen               64 kbytes
-- 011 -                                 64 kbytes
-- 10x - font          (tile)           128 kbytes
-- 110 - sprite map                      64 kbytes
-- 111 - sprite tile                     64 kbytes
--                                total 512 kbytes (256k x 16bit)
-------------------------------------------------------------------------------
-- MEMORY ACCESS - Font 4 bits
-------------------------------------------------------------------------------
--PROCESS(CLKM)                                                                  
                                                                                 
--variable vADDR  : STD_LOGIC_VECTOR(15 DOWNTO 0);                               
--variable vFONT  : STD_LOGIC_VECTOR(7 DOWNTO 0);                                
--variable vATR   : STD_LOGIC_VECTOR(7 DOWNTO 0);                                
                                                                                 
--variable vMLINE : STD_LOGIC_VECTOR(4 DOWNTO 0);                                
--variable vMCOL  : STD_LOGIC_VECTOR(4 DOWNTO 0);                                
                                                                                 
--variable vSLINE : STD_LOGIC_VECTOR(4 DOWNTO 0);                                
--variable vSCOL  : STD_LOGIC_VECTOR(4 DOWNTO 0);                                
                                                                                 
--variable vBLINE : STD_LOGIC_VECTOR(4 DOWNTO 0);                                
--variable vBCOL  : STD_LOGIC_VECTOR(4 DOWNTO 0);                                
                                                                                 
--BEGIN                                                                          
---------------------------------------------------------------------------------
--  IF (RISING_EDGE(CLKM)) THEN                                                  
                                                                                 
--    IF ( BLANK = '0' ) THEN                                                    
--      DOTBLANK <= '0';                                                         
--    END IF;                                                                    
---------------------------------------------------------------------------------
--    CASE STATE IS                                                              
--    WHEN IDLE =>                                                               
  --      vMLINE := M_ROWs;                                                      --
  --      vMCOL  := M_COLs;                                                      --
  --      vSLINE := S_ROWs;                                                      --
  --      vSCOL  := S_COLs;                                                      --
  --      vBLINE := B_ROWs;                                                      --
  --      vBCOL  := B_COLs;                                                      --
                                                                                 
--      MA <= M_ADDR;                                                            
---------------------------------------------------------------------------------
--    WHEN LOAD0 =>                                                              
  --      vFONT := MDi( 7 DOWNTO 0);                                             --
  --      vATR  := MDi(15 DOWNTO 8);                                             --
                                                                                   
  --      IF M_EXTATR = '1' AND vATR(7) = '1' THEN                               --
  --        vMLINE := NOT(vMLINE);                                               --
  --      END IF;                                                                --
                                                                                   
  --      IF M_EXTATR = '1' AND vATR(6) = '1' THEN                               --
  --        vMCOL := NOT(vMCOL);                                                 --
  --      END IF;                                                                --
                                                                                   
  --      IF M_EXTATR = '1' AND vATR(5) = '1' THEN                               --
  --        vFONT(2) := (vFONT(2) AND NOT(vFONT(0))) OR (ANIMAT(2) AND vFONT(0));--
  --        vFONT(1) := ANIMAT(1);                                               --
  --        vFONT(0) := ANIMAT(0);                                               --
  --      END IF;                                                                --
                                                                                   
  --      IF CONTROL(2) = '1' THEN                                               --
  --        vADDR(15 DOWNTO 8) := vFONT;                                         --
  --        vADDR( 7 DOWNTO 3) := vMLINE;                                        --
  --        vADDR(2)           := M_F32Pix AND vMCOL(4);                         --
  --      ELSE                                                                   --
  --        vADDR(15)          := M_V(1);                                        --
  --        vADDR(14)          := M_V(0);                                        --
  --        vADDR(13 DOWNTO 6) := vFONT;                                         --
  --        vADDR(5)           := NOT(M_F08line) AND vMLINE(3);                  --
  --        vADDR(4 DOWNTO 2)  := vMLINE(2 DOWNTO 0);                            --
  --      END IF;                                                                --
                                                                                   
  --      IF M_F08Pix = '1' THEN                                                 --
  --        vADDR(1) := M_FEXTEND AND vATR(3);                                   --
  --      ELSE                                                                   --
  --        vADDR(1) := NOT(M_FONT_1bpp OR M_FONT_1bppE) AND vMCOL(3);           --
  --      END IF;                                                                --
                                                                                   
  --      IF M_FONT_4bpp = '1' THEN                                              --
  --        vADDR(0)  := vMCOL(2);                                               --
  --      ELSE                                                                   --
  --        vADDR(0) := M_FEXTEND AND vATR(4);                                   --
  --      END IF;                                                                --
                                                                                 
--        MA <= "10" & M_FADDR & M_FA00;
---------------------------------------------------------------------------------
--    WHEN LOAD1 =>                                                              
  --      IF M_FONT_4bpp = '1' THEN                                              --
  --        vADDR(0) := NOT(vMCOL(2));                                           --
  --      ELSE                                                                   --
  --        vADDR(0) := M_FEXTEND AND vATR(4);                                   --
  --      END IF;                                                                --
                                                                                 
  --      MA <= "10" & vADDR;                                                    --
--        MA <= "10" & M_FADDR & M_FA01;
---------------------------------------------------------------------------------
--    WHEN LOAD2 =>                                                              
--      MA <= S_ADDR;                                                            
---------------------------------------------------------------------------------
--    WHEN LOAD3 =>                                                              
  --      vFONT := MDi( 7 DOWNTO 0);                                             --
  --      vATR  := MDi(15 DOWNTO 8);                                             --
                                                                                   
  --      IF S_EXTATR = '1' AND vATR(7) = '1' THEN                               --
  --        vSLINE := NOT(vSLINE);                                               --
  --      END IF;                                                                --
                                                                                   
  --      IF S_EXTATR = '1' AND vATR(6) = '1' THEN                               --
  --        vSCOL := NOT(vSCOL);                                                 --
  --      END IF;                                                                --
                                                                                   
  --      IF S_EXTATR = '1' AND vATR(5) = '1' THEN                               --
  --        vFONT(2) := (vFONT(2) AND NOT(vFONT(0))) OR (ANIMAT(2) AND vFONT(0));--
  --        vFONT(1) := ANIMAT(1);                                               --
  --        vFONT(0) := ANIMAT(0);                                               --
  --      END IF;                                                                --
                                                                                   
  --      IF CONTROL(10) = '1' THEN                                              --
  --        vADDR(15 DOWNTO 8) := vFONT;                                         --
  --        vADDR( 7 DOWNTO 3) := vSLINE;                                        --
  --        vADDR(2)           := S_F32Pix AND vSCOL(4);                         --
  --      ELSE                                                                   --
  --        vADDR(15)          := S_V(1);                                        --
  --        vADDR(14)          := S_V(0);                                        --
  --        vADDR(13 DOWNTO 6) := vFONT;                                         --
  --        vADDR(5)           := NOT(S_F08line) AND vSLINE(3);                  --
  --        vADDR(4 DOWNTO 2)  := vSLINE(2 DOWNTO 0);                            --
  --      END IF;                                                                --
                                                                                   
  --      IF S_F08Pix = '1' THEN                                                 --
  --        vADDR(1) := S_FEXTEND AND vATR(3);                                   --
  --      ELSE                                                                   --
  --        vADDR(1) := NOT(S_FONT_1bpp OR S_FONT_1bppE) AND vSCOL(3);           --
  --      END IF;                                                                --
                                                                                   
  --      IF S_FONT_4bpp = '1' THEN                                              --
  --        vADDR(0)  := vSCOL(2);                                               --
  --      ELSE                                                                   --
  --        vADDR(0) := S_FEXTEND AND vATR(4);                                   --
  --      END IF;                                                                --
                                                                                 
--      MA <= "10" & vADDR;                                                      
---------------------------------------------------------------------------------
--    WHEN LOAD4 =>                                                              
  --      IF S_FONT_4bpp = '1' THEN                                              --
  --        vADDR(0) := NOT(vSCOL(2));                                           --
  --      ELSE                                                                   --
  --        vADDR(0) := S_FEXTEND AND vATR(4);                                   --
  --      END IF;                                                                --
                                                                                 
--      MA <= "10" & vADDR;                                                      
---------------------------------------------------------------------------------
--    WHEN LOAD5 =>                                                              
--      MSEL <= '1';                                                             
---------------------------------------------------------------------------------
--    WHEN DONE =>                                                               
--      DOTBLANK <= '1';                                                         
                                                                                 
  --      M_HByte <= NOT M_F08Pix AND (NOT(vMCOL(3)) XOR (M_EXTATR AND vATR(6)));--
  --      M_HFlip <= M_EXTATR AND vATR(6);                                       --
--        M_HByte <= NOT M_F08Pix AND (NOT(M_COL(3)) XOR M_HF);  --
--        M_HFlip <= M_HF;                                         --
                                                                                 
--      S_HByte <= NOT S_F08Pix AND (NOT(vSCOL(3)) XOR (S_EXTATR AND vATR(6)));  
--      S_HFlip <= S_EXTATR AND vATR(6);                                         
                                                                                 
--      MSEL <= '0';                                                             
                                                                                 
--    WHEN OTHERS => NULL;                                                       
--    END CASE;                                                                  
                                                                                 
--  END IF;                                                                      
---------------------------------------------------------------------------------
--END PROCESS;                                                                   
---------------------------------------------------------------------------------

PROCESS(CLK)                                                                    --
                                                                                  
variable vADDR  : STD_LOGIC_VECTOR(15 DOWNTO 0);                                --
variable vFONT  : STD_LOGIC_VECTOR(7 DOWNTO 0);                                 --
variable vATR   : STD_LOGIC_VECTOR(7 DOWNTO 0);                                 --
                                                                                  
variable vMLINE : STD_LOGIC_VECTOR(4 DOWNTO 0);                                 --
variable vMCOL  : STD_LOGIC_VECTOR(4 DOWNTO 0);                                 --
                                                                                  
variable vSLINE : STD_LOGIC_VECTOR(4 DOWNTO 0);                                 --
variable vSCOL  : STD_LOGIC_VECTOR(4 DOWNTO 0);                                 --
                                                                                  
variable vBLINE : STD_LOGIC_VECTOR(4 DOWNTO 0);                                 --
variable vBCOL  : STD_LOGIC_VECTOR(4 DOWNTO 0);                                 --
                                                                                  
BEGIN                                                                           --
------------------------------------------------------------------------------- --
  IF (RISING_EDGE(CLK)) THEN                                                    --
                                                                                  
    IF ( BLANK = '0' ) THEN                                                     --
      DOTBLANK <= '0';                                                          --
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE0 = '1' THEN                                                        --
--      vMLINE := M_ROWs;                                                         --
--      vMCOL  := M_COLs;                                                         --
--      vSLINE := S_ROWs;                                                         --
--      vSCOL  := S_COLs;                                                         --
--      vBLINE := B_ROWs;                                                         --
--      vBCOL  := B_COLs;                                                         --
                                                                                  
      MA <= M_ADDR;                                                             --
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE1 = '1' THEN                                                        --
--      vFONT := MDi( 7 DOWNTO 0);                                                --
--      vATR  := MDi(15 DOWNTO 8);                                                --
                                                                                  
--      IF M_EXTATR = '1' AND vATR(7) = '1' THEN                                  --
--        vMLINE := NOT(vMLINE);                                                  --
--      END IF;                                                                   --
                                                                                  
--      IF M_EXTATR = '1' AND vATR(6) = '1' THEN                                  --
--        vMCOL := NOT(vMCOL);                                                    --
--      END IF;                                                                   --
                                                                                  
--      IF M_EXTATR = '1' AND vATR(5) = '1' THEN                                  --
--        vFONT(2) := (vFONT(2) AND NOT(vFONT(0))) OR (ANIMAT(2) AND vFONT(0));   --
--        vFONT(1) := ANIMAT(1);                                                  --
--        vFONT(0) := ANIMAT(0);                                                  --
--      END IF;                                                                   --
                                                                                  
--      IF CONTROL(2) = '1' THEN                                                  --
--        vADDR(15 DOWNTO 8) := vFONT;                                            --
--        vADDR( 7 DOWNTO 3) := vMLINE;                                           --
--        vADDR(2)           := M_F32Pix AND vMCOL(4);                            --
--      ELSE                                                                      --
--        vADDR(15)          := M_V(1);                                           --
--        vADDR(14)          := M_V(0);                                           --
--        vADDR(13 DOWNTO 6) := vFONT;                                            --
--        vADDR(5)           := NOT(M_F08line) AND vMLINE(3);                     --
--        vADDR(4 DOWNTO 2)  := vMLINE(2 DOWNTO 0);                               --
--      END IF;                                                                   --
                                                                                  
--      IF M_F08Pix = '1' THEN                                                    --
--        vADDR(1) := M_FEXTEND AND vATR(3);                                      --
--      ELSE                                                                      --
--        vADDR(1) := NOT(M_FONT_1bpp OR M_FONT_1bppE) AND vMCOL(3);              --
--      END IF;                                                                   --
                                                                                  
--      IF M_FONT_4bpp = '1' THEN                                                 --
--        vADDR(0)  := vMCOL(2);                                                  --
--      ELSE                                                                      --
--        vADDR(0) := M_FEXTEND AND vATR(4);                                      --
--      END IF;                                                                   --
                                                                                  
--      MA <= "10" & vADDR;                                                       --
      MA <= "10" & M_FADDR & M_FA00;
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE2 = '1' THEN                                                        --
--      IF M_FONT_4bpp = '1' THEN                                                 --
--        vADDR(0) := NOT(vMCOL(2));                                              --
--      ELSE                                                                      --
--        vADDR(0) := M_FEXTEND AND vATR(4);                                      --
--      END IF;                                                                   --
                                                                                  
--      MA <= "10" & vADDR;                                                       --
      MA <= "10" & M_FADDR & M_FA01;
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE3 = '1' THEN                                                        --
      MA <= S_ADDR;                                                             --
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE4 = '1' THEN                                                        --
--      vFONT := MDi( 7 DOWNTO 0);                                                --
--      vATR  := MDi(15 DOWNTO 8);                                                --
                                                                                  
--      IF S_EXTATR = '1' AND vATR(7) = '1' THEN                                  --
--        vSLINE := NOT(vSLINE);                                                  --
--      END IF;                                                                   --
                                                                                  
--      IF S_EXTATR = '1' AND vATR(6) = '1' THEN                                  --
--        vSCOL := NOT(vSCOL);                                                    --
--      END IF;                                                                   --
                                                                                  
--      IF S_EXTATR = '1' AND vATR(5) = '1' THEN                                  --
--        vFONT(2) := (vFONT(2) AND NOT(vFONT(0))) OR (ANIMAT(2) AND vFONT(0));   --
--        vFONT(1) := ANIMAT(1);                                                  --
--        vFONT(0) := ANIMAT(0);                                                  --
--      END IF;                                                                   --
                                                                                  
--      IF CONTROL(10) = '1' THEN                                                 --
--        vADDR(15 DOWNTO 8) := vFONT;                                            --
--        vADDR( 7 DOWNTO 3) := vSLINE;                                           --
--        vADDR(2)           := S_F32Pix AND vSCOL(4);                            --
--      ELSE                                                                      --
--        vADDR(15)          := S_V(1);                                           --
--        vADDR(14)          := S_V(0);                                           --
--        vADDR(13 DOWNTO 6) := vFONT;                                            --
--        vADDR(5)           := NOT(S_F08line) AND vSLINE(3);                     --
--        vADDR(4 DOWNTO 2)  := vSLINE(2 DOWNTO 0);                               --
--      END IF;                                                                   --
                                                                                  
--      IF S_F08Pix = '1' THEN                                                    --
--        vADDR(1) := S_FEXTEND AND vATR(3);                                      --
--      ELSE                                                                      --
--        vADDR(1) := NOT(S_FONT_1bpp OR S_FONT_1bppE) AND vSCOL(3);              --
--      END IF;                                                                   --
                                                                                  
--      IF S_FONT_4bpp = '1' THEN                                                 --
--        vADDR(0)  := vSCOL(2);                                                  --
--      ELSE                                                                      --
--        vADDR(0) := S_FEXTEND AND vATR(4);                                      --
--      END IF;                                                                   --
                                                                                  
--      MA <= "10" & vADDR;                                                       --
      MA <= "10" & S_FADDR & S_FA00;
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE5 = '1' THEN                                                        --
--      IF S_FONT_4bpp = '1' THEN                                                 --
--        vADDR(0) := NOT(vSCOL(2));                                              --
--      ELSE                                                                      --
--        vADDR(0) := S_FEXTEND AND vATR(4);                                      --
--      END IF;                                                                   --
                                                                                  
--      MA <= "10" & vADDR;                                                       --
      MA <= "10" & S_FADDR & S_FA01;
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE6 = '1' THEN                                                        --
      MSEL <= '1';                                                              --
    END IF;                                                                     --
------------------------------------------------------------------------------- --
    IF STAGE7 = '1' THEN                                                        --
      DOTBLANK <= '1';                                                          --
                                                                                  
--      M_HByte <= NOT M_F08Pix AND (NOT(vMCOL(3)) XOR (M_EXTATR AND vATR(6)));   --
--      M_HFlip <= M_EXTATR AND vATR(6);                                          --
                                                                                  
--      S_HByte <= NOT S_F08Pix AND (NOT(vSCOL(3)) XOR (S_EXTATR AND vATR(6)));   --
--      S_HFlip <= S_EXTATR AND vATR(6);                                          --

      M_HByte <= NOT M_F08Pix AND (NOT(M_COL(3)) XOR M_HF);
      M_HFlip <= M_HF;

      S_HByte <= NOT S_F08Pix AND (NOT(S_COL(3)) XOR S_HF);
      S_HFlip <= S_HF;
                                                                                  
      MSEL <= '0';                                                              --
    END IF;                                                                     --
                                                                                  
  END IF;                                                                       --
------------------------------------------------------------------------------- --
END PROCESS;                                                                    --
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------
--PROCESS(CLK)
--BEGIN
--  IF (RISING_EDGE(CLK)) THEN
--    IF H(2 DOWNTO 0) = "111" THEN
--      MvFONT_C <= M_FONT2;
--
--      IF ( M_GRAF = '1' ) THEN
--        MvFONT <= M_FONT0;
--
--        MvCOLOR <= "00001111";
--      ELSE
--        MvFONT <= M_FONT1;
--
--        IF ( M_FONT_1bppE = '1' ) THEN
--          MvCOLOR <= M_FONT1(15 DOWNTO 8);
--        ELSE
--          MvCOLOR <= M_FONT0(15 DOWNTO 8);
--        END IF;
--      END IF;
--    END IF;
--  END IF;
--END PROCESS;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- OUT Master
-------------------------------------------------------------------------------
PROCESS(CLK, RESET_n, M_DOTCLK, DOTBLANK)

variable vCOLOR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
variable tCOLOR    : STD_LOGIC_VECTOR(8 DOWNTO 0);
variable eCOLOR    : STD_LOGIC_VECTOR(8 DOWNTO 2);

variable tCURSOR   : STD_LOGIC;
variable tTMP      : STD_LOGIC;

variable vFONT     : STD_LOGIC_VECTOR(15 DOWNTO 0);
variable vFONTe    : STD_LOGIC_VECTOR(15 DOWNTO 0);

variable vPIXEL1   : STD_LOGIC;
variable vPIXEL2   : STD_LOGIC_VECTOR(1 DOWNTO 0);
variable vPIXEL4   : STD_LOGIC_VECTOR(3 DOWNTO 0);

variable vSTATE  : dot_state_type;

BEGIN
-------------------------------------------------------------------------------
  IF RESET_n = '0' THEN
    vSTATE := STEP0;
  ELSIF (RISING_EDGE(CLK)) THEN
    IF M_DOTCLK = '1' THEN

      CASE vSTATE IS
      WHEN STEP0 =>
        tCURSOR := CURSOR;
--------
        IF ( M_GRAF = '1' ) THEN
          vFONT := M_FONT0;

          vCOLOR := "00001111";
        ELSE
          vFONT := M_FONT1;

          IF ( M_FONT_1bppE = '1' ) THEN
            vCOLOR := M_FONT1(15 DOWNTO 8);
          ELSE
            vCOLOR := M_FONT0(15 DOWNTO 8);
          END IF;
        END IF;
        eCOLOR := M_PALETE;
        vFONTe := M_FONT2;
--------
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(8);
          ELSE
            vPIXEL1 := vFONT(0);
          END IF;
          vPIXEL2   := vFONT( 1 DOWNTO  0);
          vPIXEL4   := vFONTe( 3 DOWNTO  0);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(15);
          ELSE
            vPIXEL1 := vFONT(7);
          END IF;
          vPIXEL2   := vFONT(15 DOWNTO 14);
          vPIXEL4   := vFONT(15 DOWNTO 12);
        END IF;

        IF ( DOTBLANK = '0' ) THEN
          vSTATE := STEP0;
        ELSE
          vSTATE := STEP1;
        END IF;
-------------------------------------------------------------------------------
      WHEN STEP1 =>
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(9);
          ELSE
            vPIXEL1 := vFONT(1);
          END IF;
          vPIXEL2   := vFONT( 3 DOWNTO  2);
          vPIXEL4   := vFONTe( 7 DOWNTO  4);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(14);
          ELSE
            vPIXEL1 := vFONT(6);
          END IF;
          vPIXEL2   := vFONT(13 DOWNTO 12);
          vPIXEL4   := vFONT(11 DOWNTO 8);
        END IF;

        vSTATE := STEP2;
-------------------------------------------------------------------------------
      WHEN STEP2 =>
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(10);
          ELSE
            vPIXEL1 := vFONT(2);
          END IF;
          vPIXEL2   := vFONT(5 DOWNTO 4);
          vPIXEL4   := vFONTe(11 DOWNTO 8);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(13);
          ELSE
            vPIXEL1 := vFONT(5);
          END IF;
          vPIXEL2   := vFONT(11 DOWNTO 10);
          vPIXEL4   := vFONT(7 DOWNTO 4);
        END IF;

        vSTATE := STEP3;
-------------------------------------------------------------------------------
      WHEN STEP3 =>
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(11);
          ELSE
            vPIXEL1 := vFONT(3);
          END IF;
          vPIXEL2   := vFONT( 7 DOWNTO  6);
          vPIXEL4   := vFONTe(15 DOWNTO 12);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(12);
          ELSE
            vPIXEL1 := vFONT(4);
          END IF;
          vPIXEL2   := vFONT(9 DOWNTO 8);
          vPIXEL4   := vFONT(3 DOWNTO 0);
        END IF;

        IF ( M_GRAF = '1' AND M_SCALE_x4 = '1' AND M_FONT_4bpp = '1' ) THEN
          vSTATE := STEP0;
        ELSE
          vSTATE := STEP4;
        END IF;
-------------------------------------------------------------------------------
      WHEN STEP4 =>
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(12);
          ELSE
            vPIXEL1 := vFONT(4);
          END IF;
          vPIXEL2   := vFONT( 9 DOWNTO  8);
          vPIXEL4   := vFONT(3 DOWNTO 0);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(11);
          ELSE
            vPIXEL1 := vFONT(3);
          END IF;
          vPIXEL2   := vFONT(7 DOWNTO 6);
          vPIXEL4   := vFONTe(15 DOWNTO 12);
        END IF;

        vSTATE := STEP5;
-------------------------------------------------------------------------------
      WHEN STEP5 =>
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(13);
          ELSE
            vPIXEL1 := vFONT(5);
          END IF;
          vPIXEL2   := vFONT(11 DOWNTO 10);
          vPIXEL4   := vFONT(7 DOWNTO 4);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(10);
          ELSE
            vPIXEL1 := vFONT(2);
          END IF;
          vPIXEL2   := vFONT(5 DOWNTO 4);
          vPIXEL4   := vFONTe(11 DOWNTO 8);
        END IF;

        vSTATE := STEP6;
-------------------------------------------------------------------------------
      WHEN STEP6 =>
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(14);
          ELSE
            vPIXEL1 := vFONT(6);
          END IF;
          vPIXEL2   := vFONT(13 DOWNTO 12);
          vPIXEL4   := vFONT(11 DOWNTO 8);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(9);
          ELSE
            vPIXEL1 := vFONT(1);
          END IF;
          vPIXEL2   := vFONT(3 DOWNTO 2);
          vPIXEL4   := vFONTe(7 DOWNTO 4);
        END IF;

        vSTATE := STEP7;
-------------------------------------------------------------------------------
      WHEN STEP7 =>
        IF ( M_HFlip = '1' ) THEN
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(15);
          ELSE
            vPIXEL1 := vFONT(7);
          END IF;
          vPIXEL2   := vFONT(15 DOWNTO 14);
          vPIXEL4   := vFONT(15 DOWNTO 12);
        ELSE
          IF ( M_HByte = '1' ) THEN
            vPIXEL1 := vFONT(8);
          ELSE
            vPIXEL1 := vFONT(0);
          END IF;
          vPIXEL2   := vFONT(1 DOWNTO 0);
          vPIXEL4   := vFONTe(3 DOWNTO 0);
        END IF;

        vSTATE := STEP0;
      END CASE;
-------------------------------------------------------------------------------
    END IF;
-------------------------------------------------------------------------------
    IF ( DOTBLANK = '0' ) THEN
      tCOLOR := (OTHERS => '0');
    ELSE
      IF ( ( M_FONT_1bpp OR M_FONT_1bppE ) = '1' ) THEN
        tTMP := tCURSOR XOR vPIXEL1;
        IF ( tTMP = '1' ) THEN
          tCOLOR := eCOLOR(8 DOWNTO 4) & vCOLOR(3 DOWNTO 0);
        ELSE
          tCOLOR := eCOLOR(8 DOWNTO 4) & vCOLOR(7 DOWNTO 4);
        END IF;
      ELSIF ( M_FONT_2bpp = '1' ) THEN
        tCOLOR := eCOLOR & vPIXEL2;
      ELSE
        tCOLOR := eCOLOR(8 DOWNTO 4) & vPIXEL4;
      END IF;
    END IF;

  END IF;
-------------------------------------------------------------------------------
  M_COLOR <= tCOLOR;
-------------------------------------------------------------------------------
END PROCESS;

-------------------------------------------------------------------------------
-- OUT Slave
-------------------------------------------------------------------------------
PROCESS(CLK, RESET_n, S_DOTCLK, DOTBLANK)

variable vCOLOR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
variable tCOLOR    : STD_LOGIC_VECTOR(8 DOWNTO 0);
variable eCOLOR    : STD_LOGIC_VECTOR(8 DOWNTO 2);

variable vFONT     : STD_LOGIC_VECTOR(15 DOWNTO 0);
variable vFONTe    : STD_LOGIC_VECTOR(15 DOWNTO 0);

variable vPIXEL1   : STD_LOGIC;
variable vPIXEL2   : STD_LOGIC_VECTOR(1 DOWNTO 0);
variable vPIXEL4   : STD_LOGIC_VECTOR(3 DOWNTO 0);

variable vSTATE  : dot_state_type;

BEGIN
-------------------------------------------------------------------------------
  IF RESET_n = '0' THEN
    vSTATE := STEP0;
  ELSIF (RISING_EDGE(CLK)) THEN
    IF S_DOTCLK = '1' THEN

      CASE vSTATE IS
      WHEN STEP0 =>

        IF ( S_FONT_1bppE = '1' ) THEN
          vCOLOR := S_FONT1(15 DOWNTO 8);
        ELSE
          vCOLOR := S_FONT0(15 DOWNTO 8);
        END IF;

        eCOLOR := S_PALETE;

        vFONT  := S_FONT1;
        vFONTe := S_FONT2;

        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(8);
          ELSE
            vPIXEL1 := vFONT(0);
          END IF;
          vPIXEL2   := vFONT( 1 DOWNTO  0);
          vPIXEL4   := vFONTe( 3 DOWNTO  0);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(15);
          ELSE
            vPIXEL1 := vFONT(7);
          END IF;
          vPIXEL2   := vFONT(15 DOWNTO 14);
          vPIXEL4   := vFONT(15 DOWNTO 12);
        END IF;

        IF ( DOTBLANK = '0' ) THEN
          vSTATE := STEP0;
        ELSE
          vSTATE := STEP1;
        END IF;
-------------------------------------------------------------------------------
      WHEN STEP1 =>
        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(9);
          ELSE
            vPIXEL1 := vFONT(1);
          END IF;
          vPIXEL2   := vFONT( 3 DOWNTO  2);
          vPIXEL4   := vFONTe( 7 DOWNTO  4);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(14);
          ELSE
            vPIXEL1 := vFONT(6);
          END IF;
          vPIXEL2   := vFONT(13 DOWNTO 12);
          vPIXEL4   := vFONT(11 DOWNTO 8);
        END IF;

        vSTATE := STEP2;
-------------------------------------------------------------------------------
      WHEN STEP2 =>
        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(10);
          ELSE
            vPIXEL1 := vFONT(2);
          END IF;
          vPIXEL2   := vFONT( 5 DOWNTO  4);
          vPIXEL4   := vFONTe(11 DOWNTO 8);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(13);
          ELSE
            vPIXEL1 := vFONT(5);
          END IF;
          vPIXEL2   := vFONT(11 DOWNTO 10);
          vPIXEL4   := vFONT(7 DOWNTO 4);
        END IF;

        vSTATE := STEP3;
-------------------------------------------------------------------------------
      WHEN STEP3 =>
        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(11);
          ELSE
            vPIXEL1 := vFONT(3);
          END IF;
          vPIXEL2   := vFONT( 7 DOWNTO  6);
          vPIXEL4   := vFONTe(15 DOWNTO 12);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(12);
          ELSE
            vPIXEL1 := vFONT(4);
          END IF;
          vPIXEL2   := vFONT(9 DOWNTO 8);
          vPIXEL4   := vFONT(3 DOWNTO 0);
        END IF;

        vSTATE := STEP4;
-------------------------------------------------------------------------------
      WHEN STEP4 =>
        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(12);
          ELSE
            vPIXEL1 := vFONT(4);
          END IF;
          vPIXEL2   := vFONT( 9 DOWNTO  8);
          vPIXEL4   := vFONT(3 DOWNTO 0);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(11);
          ELSE
            vPIXEL1 := vFONT(3);
          END IF;
          vPIXEL2   := vFONT(7 DOWNTO 6);
          vPIXEL4   := vFONTe(15 DOWNTO 12);
        END IF;

        vSTATE := STEP5;
-------------------------------------------------------------------------------
      WHEN STEP5 =>
        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(13);
          ELSE
            vPIXEL1 := vFONT(5);
          END IF;
          vPIXEL2   := vFONT(11 DOWNTO 10);
          vPIXEL4   := vFONT(7 DOWNTO 4);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(10);
          ELSE
            vPIXEL1 := vFONT(2);
          END IF;
          vPIXEL2   := vFONT(5 DOWNTO 4);
          vPIXEL4   := vFONTe(11 DOWNTO 8);
        END IF;

        vSTATE := STEP6;
-------------------------------------------------------------------------------
      WHEN STEP6 =>
        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(14);
          ELSE
            vPIXEL1 := vFONT(6);
          END IF;
          vPIXEL2   := vFONT(13 DOWNTO 12);
          vPIXEL4   := vFONT(11 DOWNTO 8);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(9);
          ELSE
            vPIXEL1 := vFONT(1);
          END IF;
          vPIXEL2   := vFONT(3 DOWNTO 2);
          vPIXEL4   := vFONTe(7 DOWNTO 4);
        END IF;

        vSTATE := STEP7;
-------------------------------------------------------------------------------
      WHEN STEP7 =>
        IF ( S_HFlip = '1' ) THEN
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(15);
          ELSE
            vPIXEL1 := vFONT(7);
          END IF;
          vPIXEL2   := vFONT(15 DOWNTO 14);
          vPIXEL4   := vFONT(15 DOWNTO 12);
        ELSE
          IF ( S_HByte = '1' ) THEN
            vPIXEL1 := vFONT(8);
          ELSE
            vPIXEL1 := vFONT(0);
          END IF;
          vPIXEL2   := vFONT(1 DOWNTO 0);
          vPIXEL4   := vFONTe(3 DOWNTO 0);
        END IF;

        vSTATE := STEP0;
      END CASE;
-------------------------------------------------------------------------------
    END IF;
-------------------------------------------------------------------------------
    IF ( DOTBLANK = '0' OR S_DISABLE = '1' ) THEN
      tCOLOR := (OTHERS => '0');
    ELSE
      IF ( ( S_FONT_1bpp OR S_FONT_1bppE ) = '1' ) THEN
        IF ( vPIXEL1 = '1' ) THEN
          tCOLOR := eCOLOR(8 DOWNTO 4) & vCOLOR(3 DOWNTO 0);
        ELSE
          tCOLOR := eCOLOR(8 DOWNTO 4) & vCOLOR(7 DOWNTO 4);
        END IF;
      ELSIF ( S_FONT_2bpp = '1' ) THEN
        tCOLOR := eCOLOR & vPIXEL2;
      ELSE
        tCOLOR := eCOLOR(8 DOWNTO 4) & vPIXEL4;
      END IF;
    END IF;

  END IF;
-------------------------------------------------------------------------------
  S_COLOR <= tCOLOR;
-------------------------------------------------------------------------------
END PROCESS;

-------------------------------------------------------------------------------
-- OUT Background
-------------------------------------------------------------------------------
--PROCESS(CLK, RESET_n, B_DOTCLK, DOTBLANK)

--variable vCOLOR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
--variable tCOLOR    : STD_LOGIC_VECTOR(8 DOWNTO 0);
--variable eCOLOR    : STD_LOGIC_VECTOR(8 DOWNTO 2);

--variable vFONT     : STD_LOGIC_VECTOR(15 DOWNTO 0);
--variable vFONTe    : STD_LOGIC_VECTOR(15 DOWNTO 0);

--variable vPIXEL1   : STD_LOGIC;
--variable vPIXEL2   : STD_LOGIC_VECTOR(1 DOWNTO 0);

--variable vSTATE  : dot_state_type;

--BEGIN
-------------------------------------------------------------------------------
--  IF RESET_n = '0' THEN
--    vSTATE := STEP0;
--  ELSIF (RISING_EDGE(CLK)) THEN
--    IF B_DOTCLK = '1' THEN

--      CASE vSTATE IS
--      WHEN STEP0 =>

--        vCOLOR := B_FONT0(15 DOWNTO 8);

--        eCOLOR := B_PALETE;

--        vFONT  := B_FONT1;

--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(8);
--          ELSE
--            vPIXEL1 := vFONT(0);
--          END IF;
--          vPIXEL2   := vFONT( 1 DOWNTO  0);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(15);
--          ELSE
--            vPIXEL1 := vFONT(7);
--          END IF;
--          vPIXEL2   := vFONT(15 DOWNTO 14);
--        END IF;

--        IF ( DOTBLANK = '0' ) THEN
--          vSTATE := STEP0;
--        ELSE
--          vSTATE := STEP1;
--        END IF;
-------------------------------------------------------------------------------
--      WHEN STEP1 =>
--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(9);
--          ELSE
--            vPIXEL1 := vFONT(1);
--          END IF;
--          vPIXEL2   := vFONT( 3 DOWNTO  2);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(14);
--          ELSE
--            vPIXEL1 := vFONT(6);
--          END IF;
--          vPIXEL2   := vFONT(13 DOWNTO 12);
--        END IF;

--        vSTATE := STEP2;
-------------------------------------------------------------------------------
--      WHEN STEP2 =>
--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(10);
--          ELSE
--            vPIXEL1 := vFONT(2);
--          END IF;
--          vPIXEL2   := vFONT( 5 DOWNTO  4);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(13);
--          ELSE
--            vPIXEL1 := vFONT(5);
--          END IF;
--          vPIXEL2   := vFONT(11 DOWNTO 10);
--        END IF;
  
--        vSTATE := STEP3;
-------------------------------------------------------------------------------
--      WHEN STEP3 =>
--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(11);
--          ELSE
--            vPIXEL1 := vFONT(3);
--          END IF;
--          vPIXEL2   := vFONT( 7 DOWNTO  6);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(12);
--          ELSE
--            vPIXEL1 := vFONT(4);
--          END IF;
--          vPIXEL2   := vFONT(9 DOWNTO 8);
--        END IF;
  
--        vSTATE := STEP4;
-------------------------------------------------------------------------------
--      WHEN STEP4 =>
--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(12);
--          ELSE
--            vPIXEL1 := vFONT(4);
--          END IF;
--          vPIXEL2   := vFONT( 9 DOWNTO  8);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(11);
--          ELSE
--            vPIXEL1 := vFONT(3);
--          END IF;
--          vPIXEL2   := vFONT(7 DOWNTO 6);
--        END IF;
  
--        vSTATE := STEP5;
-------------------------------------------------------------------------------
--      WHEN STEP5 =>
--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(13);
--          ELSE
--            vPIXEL1 := vFONT(5);
--          END IF;
--          vPIXEL2   := vFONT(11 DOWNTO 10);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(10);
--          ELSE
--            vPIXEL1 := vFONT(2);
--          END IF;
--          vPIXEL2   := vFONT(5 DOWNTO 4);
--        END IF;
  
--        vSTATE := STEP6;
-------------------------------------------------------------------------------
--      WHEN STEP6 =>
--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(14);
--          ELSE
--            vPIXEL1 := vFONT(6);
--          END IF;
--          vPIXEL2   := vFONT(13 DOWNTO 12);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(9);
--          ELSE
--            vPIXEL1 := vFONT(1);
--          END IF;
--          vPIXEL2   := vFONT(3 DOWNTO 2);
--        END IF;
  
--        vSTATE := STEP7;
-------------------------------------------------------------------------------
--      WHEN STEP7 =>
--        IF ( B_HFlip = '1' ) THEN
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(15);
--          ELSE
--            vPIXEL1 := vFONT(7);
--          END IF;
--          vPIXEL2   := vFONT(15 DOWNTO 14);
--        ELSE
--          IF ( B_HByte = '1' ) THEN
--            vPIXEL1 := vFONT(8);
--          ELSE
--            vPIXEL1 := vFONT(0);
--          END IF;
--          vPIXEL2   := vFONT(1 DOWNTO 0);
--        END IF;
  
--        vSTATE := STEP0;
--      END CASE;
-------------------------------------------------------------------------------
--    END IF;
-------------------------------------------------------------------------------
--    IF ( DOTBLANK = '0' OR B_DISABLE = '1' ) THEN
--      tCOLOR := (OTHERS => '0');
--    ELSE
--      IF ( B_FONT_1bpp = '1' ) THEN
--        IF ( vPIXEL1 = '1' ) THEN
--          tCOLOR := eCOLOR(8 DOWNTO 4) & vCOLOR(3 DOWNTO 0);
--        ELSE
--          tCOLOR := eCOLOR(8 DOWNTO 4) & vCOLOR(7 DOWNTO 4);
--        END IF;
--      ELSE
--        tCOLOR := eCOLOR & vPIXEL2;
--      END IF;
--    END IF;

--  END IF;
-------------------------------------------------------------------------------
--  B_COLOR <= tCOLOR;
-------------------------------------------------------------------------------
--END PROCESS;

--S_COLOR <= (OTHERS => '0');
B_COLOR <= (OTHERS => '0');

-------------------------------------------------------------------------------
END;
