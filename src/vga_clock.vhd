library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
 
entity vga_clock is
   port(
      CLK   	: in  std_logic;
      RESET 	: in  std_logic;

      ce324     : out std_logic;
      ce97	: out std_logic;
      ce65	: out std_logic;

      vce324    : out std_logic;
      vce97	: out std_logic;
      vce65	: out std_logic
   );
end vga_clock;
 
architecture rtl of vga_clock is

signal cnt : unsigned(3 downto 0);
signal r15 : std_logic_vector(14 downto 0);

BEGIN

process(clk)
begin
  IF (RESET = '0') THEN
    r15 <= "100000000000000";
  elsif rising_edge(clk) then
    if cnt = 14 then
      cnt <= (others=>'0');
    else
      cnt <= cnt + 1;
    end if;

    r15    <= r15(13 downto 0) & r15(14);
    vce97  <= r15(0) or r15(5) or r15(10);
    vce65  <= r15(0) or r15(7);
    vce324 <= not (r15(2) or r15(5) or r15(8) or r15(11) or r15(14));
  end if;
end process;

    -- 324 MHz (div 2/3 or 10/15)
    ce324 <= '1' when (cnt /= 2 and cnt /= 5 and cnt /= 8 and cnt /= 11 and cnt /= 14) else '0';

    -- 97.2 MHz (div 5)
    ce97  <= '1' when (cnt=0 or cnt=5 or cnt=10) else '0';

    -- 64.8 MHz (div 2/15)
    ce65  <= '1' when (cnt=0 or cnt=7) else '0';

END;
