LIBRARY ieee;
USE ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

LIBRARY work;

ENTITY VGA_ARBITER IS 
	PORT
	(
		CLK     : IN  STD_LOGIC;
		CLKM    : IN  STD_LOGIC;
		RESET_n : IN  STD_LOGIC;

		H       :  IN STD_LOGIC_VECTOR(11 DOWNTO 0);

		HACTIVE :  IN STD_LOGIC;
		VACTIVE :  IN STD_LOGIC;

		VA      :  IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		VDo     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);

		SA      :  IN STD_LOGIC_VECTOR(16 DOWNTO 0);
		SREQ    :  IN STD_LOGIC;
		SDo     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		SRDY    : OUT STD_LOGIC;

		CREQ    :  IN STD_LOGIC;
		CA      :  IN STD_LOGIC_VECTOR(18 DOWNTO 0);
		CDi     :  IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		CDo     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		CWE     : OUT STD_LOGIC;


		MA      : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
		MDi     :  IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		MDo     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		MWE     : OUT STD_LOGIC;
		MOE     : OUT STD_LOGIC;
		MBLE    : OUT STD_LOGIC;
		MBHE    : OUT STD_LOGIC
	);
END;

ARCHITECTURE bdf_type OF VGA_ARBITER IS 

PROCESS(RESET_n, CLK)
BEGIN
  IF (RESET_n = '0') THEN
  ELSIF (RISING_EDGE(CLK)) THEN
    CPU_RDY <= '0';
    IF MSEL_V = '0' THEN
      IF CPU_REQ = '1' THEN
        MSEL <= "10";
        CPU_RDY <= '1';
      ELSIF SPR_REQ = '1' THEN
        MSEL <= "01";
        SPR_RDY <= '1';
      END IF;
    ELSE
      MSEL <= "00";
      SPR_RDY <= '0';
    END IF;

    CASE STAGE IS
    WHEN "0000" => -- Master tile map
      STAGE := "0001";
    WHEN "0001" => -- Master tile data
      STAGE := "0010";
    WHEN "0100" => -- Master tile data ext
      IF MSEL_V = '1' THEN
        STAGE := "0110";
      ELSE
        STAGE := "0101";
      END IF;
    WHEN "0010" => -- Slave tile map
      IF MSEL_V = '1' THEN
        STAGE := "1000";
      ELSE
        STAGE := "0011";
      END IF;
    WHEN "0011" => -- Slave tile data
      IF MSEL_V = '1' THEN
        STAGE := "1000";
      ELSE
        STAGE := "0100";
      END IF;
    WHEN "0101" => -- Slave tile data ext
      IF MSEL_V = '1' THEN
        STAGE := "1000";
      ELSE
        STAGE := "0110";
      END IF;
    WHEN "0110" => -- Background tile map
      IF MSEL_V = '1' THEN
        STAGE := "1000";
      ELSE
        STAGE := "0111";
      END IF;
      STAGE := "0111";
    WHEN "0111" => -- Background tile data
      STAGE := "1000";
    WHEN "1000" =>
      IF CPU_REQ = '1' THEN
        MSEL <= "10";
      END IF;
      STAGE := "0000";
      IF SPR_REQ = '1' THEN
        MSEL <= "01";
      END IF;
    WHEN "1001" => STAGE := "0000";
    WHEN "1010" => STAGE := "0000";
    WHEN "1011" => STAGE := "0000";
    WHEN "1100" =>
      STAGE := "0000";
    WHEN "1101" =>
      MSEL <= "00";
      IF H(2 DOWNTO 0) = "000" THEN
        STAGE := "0000";
      END IF;
    END CASE;
  END IF;
END PROCESS;

MA   <= B_ADDR(17 DOWNTO 1);
MDo  <= B_DATA & B_DATA;
MWE  <= NOT(WE AND VOE);
MBLE <= B_ADDR(0);
MBHE <= NOT(B_ADDR(0));

-------------------------------------------------------------------------------
END;
