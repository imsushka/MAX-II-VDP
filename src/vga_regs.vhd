LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

LIBRARY work;

ENTITY VGA_REGS IS 
	PORT
	(
		CLK     : IN  STD_LOGIC;
		RESET_n : IN  STD_LOGIC;

		CS      : IN  STD_LOGIC;
		A       : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		D       : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);

		CONTROL : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		HSCROLLM: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VSCROLLM: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HSCROLLS: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VSCROLLS: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		HSCROLLB: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VSCROLLB: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

		HCURSOR : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		VCURSOR : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

		M_SPLIT0: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		M_SPLIT1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

		S_SPLIT0: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		S_SPLIT1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

		B_SPLIT0: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		B_SPLIT1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

		MSEL    :  IN STD_LOGIC;
		MDo     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		MA      : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		MWE     : OUT STD_LOGIC;
		MBLE    : OUT STD_LOGIC;
		MBHE    : OUT STD_LOGIC
	);
END;

ARCHITECTURE bdf_type OF VGA_REGS IS 

SIGNAL	WE :  STD_LOGIC;
SIGNAL	OEo : STD_LOGIC;
SIGNAL	OEn : STD_LOGIC;
SIGNAL	OE  : STD_LOGIC;

SIGNAL	B_ADDR    : STD_LOGIC_VECTOR(18 DOWNTO 0);
SIGNAL	B_DATA    : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

OE <= '1' WHEN OEn = '1' AND OEo = '0' ELSE '0';

-------------------------------------------------------------------------------
-- REGISTERS
-------------------------------------------------------------------------------
-- CONTROL  ( x7 )
--       D 7654 3210
-- ( 2- 0) 0000 -xxx Master video mode
-- (    3) 0000 x--- Master multy font

-- ( 5- 4) 0001 --xx Master scale          (00/01 - 1x, 10 - 2x, 11 - 4x)
-- ( 7- 6) 0001 xx-- Master bits           (00 - 1bpp, 01 - 2bpp, 10 - 4bpp, 11 - 1bppE)
--
-- (10- 8) 0010 -xxx Slave video mode
-- (   11) 0010 x--- Slave multy font

-- (13-12) 0011 --xx Slave scale           (00 - Slave disable, 01 - 1x, 10 - 2x, 11 - 4x)
-- (15-14) 0011 xx-- Slave bits            (00 - 1bpp, 01 - 2bpp, 10 - 4bpp, 11 - 1bppE)

-- (17-16) 0100 --xx Background video mode
-- (   18) 0100 -x-- NONE
-- (   19) 0100 x--- Background multy font

-- (21-20) 0101 --xx Background scale      (00 - Background disable, 01 - 1x, 10 - 2x, 11 - 4x)
-- (   22) 0101 -x-- Background bits       (0  - 1bpp, 1 - 2bpp)
-- (   23) 0101 x--- NONE

-- (   24) 0110 ---x Master cursor
-- (   25) 0110 --x- NONE
-- (   26) 0110 -x-- NONE
-- (   27) 0110 x--- NONE
--     
-- (   28) 0111 ---x M_SPLIT_ENABLE
-- (   29) 0111 --x- S_SPLIT_ENABLE
-- (   30) 0111 -x-- B_SPLIT_ENABLE
-- (   31) 0111 x--- SPRITE_ENABLE
--
-- (63-32) 1xxx      NONE
--
-- PALETE_ADDRhi ( x6 ) 
-- 7-0 ADDR        1AAAAAAAA
--              
-- PALETE_ADDRlo ( x5 )
-- 7-0 ADDR        0AAAAAAAA
--              
-- PALETE_DATA   ( x4 )
-- 00 -xxxxx R
-- 01 -xxxxx G
-- 10 -xxxxx B
-- 11 ------ increment address
--
-- REG_DATA ( x3 )
-- 0000 -xxxxxxx HCURSOR
-- 0001 -xxxxxxx VCURSOR
-- 0010 xxxxxxxx HSCROLLM
-- 0011 -xxxxxxx VSCROLLM
-- 0100 xxxxxxxx HSCROLLS
-- 0101 -xxxxxxx VSCROLLS
-- 0110 xxxxxxxx HSCROLLB
-- 0111 -xxxxxxx VSCROLLB
-- 1000 ---xxxxx M_SPLIT0
-- 1001 ---xxxxx M_SPLIT1
-- 1010 ---xxxxx S_SPLIT0
-- 1011 ---xxxxx S_SPLIT1
-- 1100 ---xxxxx B_SPLIT0
-- 1101 ---xxxxx B_SPLIT1
-- 1110
-- 1111
--
-- REG_ADDR ( x2 )
--
-- MEM_DATA ( x1 )
-- 7-0 DATA
--
-- MEM_ADDR ( x0 )
-- 00 5-0 ADDRESS(05-00)
-- 01 5-0 ADDRESS(11-06)
-- 10 5-0 ADDRESS(17-12)
-- 11 5-0 INCREMENT
-------------------------------------------------------------------------------
PROCESS(RESET_n, CLK)
variable WR  : STD_LOGIC;
variable REG_ADDR    : STD_LOGIC_VECTOR(18 DOWNTO 0);
variable REG_DATA    : STD_LOGIC_VECTOR(7 DOWNTO 0);
variable REG_INC     : STD_LOGIC_VECTOR(4 DOWNTO 0);

variable ADDR        : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
  IF (RESET_n = '0') THEN
    CONTROL  <= (OTHERS => '0');
    VSCROLLM <= (OTHERS => '0');
    HSCROLLM <= (OTHERS => '0');
    VSCROLLS <= (OTHERS => '0');
    HSCROLLS <= (OTHERS => '0');
    VSCROLLB <= (OTHERS => '0');
    HSCROLLB <= (OTHERS => '0');
    M_SPLIT0 <= (OTHERS => '0');
    M_SPLIT1 <= (OTHERS => '0');
    S_SPLIT0 <= (OTHERS => '0');
    S_SPLIT1 <= (OTHERS => '0');
    B_SPLIT0 <= (OTHERS => '0');
    B_SPLIT1 <= (OTHERS => '0');
    VCURSOR  <= (OTHERS => '0');
    HCURSOR  <= (OTHERS => '0');

--    REG_DATA := (OTHERS => '0');
    REG_ADDR := (OTHERS => '0');
    REG_INC  := (OTHERS => '0');

    OEn <= '0';
    OEo <= '0';
    WR  := '0';
    WE  <= '0';
  ELSIF (RISING_EDGE(CLK)) THEN

    OEo <= OEn;
    OEn <= MSEL;

    WE <= '0';

    IF CS = '0' THEN
      CASE A IS
      WHEN "000" => -- ADDRESS MEMORY 256 KBytes / Increment
        CASE D(7 DOWNTO 6) IS
        WHEN "00" => REG_ADDR( 5 DOWNTO  0) := D( 5 DOWNTO  0);
        WHEN "01" => REG_ADDR(11 DOWNTO  6) := D( 5 DOWNTO  0);
        WHEN "10" => REG_ADDR(17 DOWNTO 12) := D( 5 DOWNTO  0);
        WHEN "11" => REG_INC                := D( 4 DOWNTO  0);
                     REG_ADDR(18)           := D( 5);
        END CASE;
      WHEN "001" => -- DATA for write to memory
        B_ADDR <= REG_ADDR;
        B_DATA <= D;
        WR     := '1';
        REG_ADDR := REG_ADDR + REG_INC;
      WHEN "010" =>
        ADDR := D(3 DOWNTO 0);
      WHEN "011" =>
        CASE ADDR IS
        WHEN "0000" =>
          HCURSOR <= D(6 DOWNTO 0);
        WHEN "0001" =>
          VCURSOR <= D(6 DOWNTO 0);
        WHEN "0010" =>
          HSCROLLM <= D;
        WHEN "0011" =>
          VSCROLLM <= D(6 DOWNTO 0);
        WHEN "0100" =>
          HSCROLLS <= D;
        WHEN "0101" =>
          VSCROLLS <= D(6 DOWNTO 0);
        WHEN "0110" =>
          HSCROLLB <= D;
        WHEN "0111" =>
          VSCROLLB <= D(6 DOWNTO 0);
        WHEN "1000" =>
          M_SPLIT0 <= D(5 DOWNTO 0);
        WHEN "1001" =>
          M_SPLIT1(4 DOWNTO 0) <= D(4 DOWNTO 0); -- Split1 - 32 to 95
          M_SPLIT1(5)          <= NOT(D(5));
          M_SPLIT1(6)          <= D(5);
        WHEN "1010" =>
          S_SPLIT0 <= D( 5 DOWNTO  0);
        WHEN "1011" =>
          S_SPLIT1(4 DOWNTO 0) <= D(4 DOWNTO 0); -- Split1 - 32 to 95
          S_SPLIT1(5)          <= NOT(D(5));
          S_SPLIT1(6)          <= D(5);
        WHEN "1100" =>
          B_SPLIT0 <= D( 5 DOWNTO  0);
        WHEN "1101" =>
          B_SPLIT1(4 DOWNTO 0) <= D(4 DOWNTO 0); -- Split1 - 32 to 95
          B_SPLIT1(5)          <= NOT(D(5));
          B_SPLIT1(6)          <= D(5);
        WHEN "1110" =>
        WHEN "1111" =>
--        WHEN "10000" => M_START   <= D;
--        WHEN "10001" => S_START   <= D;
--        WHEN "10010" => B_START   <= D;
--        WHEN "10011" => F_START   <= D;
--        WHEN "10100" => SPR_START <= D;
--        WHEN "10101" => SF_START  <= D;
        END CASE;
        ADDR := ADDR + 1;

      WHEN "100" =>
      WHEN "101" =>
      WHEN "110" =>
      WHEN "111" =>
        CASE D(6 DOWNTO 4) IS
        WHEN "000" => CONTROL( 3 DOWNTO  0) <= D(3 DOWNTO 0);
        WHEN "001" => CONTROL( 7 DOWNTO  4) <= D(3 DOWNTO 0);
        WHEN "010" => CONTROL(11 DOWNTO  8) <= D(3 DOWNTO 0);
        WHEN "011" => CONTROL(15 DOWNTO 12) <= D(3 DOWNTO 0);
        WHEN "100" => CONTROL(19 DOWNTO 16) <= D(3 DOWNTO 0);
        WHEN "101" => CONTROL(23 DOWNTO 20) <= D(3 DOWNTO 0);
        WHEN "110" => CONTROL(27 DOWNTO 24) <= D(3 DOWNTO 0);
        WHEN "111" => CONTROL(31 DOWNTO 28) <= D(3 DOWNTO 0);
        END CASE;
      END CASE;
    ELSE
      IF (WR = '1' AND OE = '1') THEN
        WR := '0';
        WE <= '1';
      END IF;
    END IF;
  END IF;

END PROCESS;

MA   <= B_ADDR(18 DOWNTO 1);
MDo  <= B_DATA & B_DATA;
MBLE <= B_ADDR(0);
MBHE <= NOT(B_ADDR(0));
MWE  <= NOT(WE AND MSEL);

-------------------------------------------------------------------------------
END;
