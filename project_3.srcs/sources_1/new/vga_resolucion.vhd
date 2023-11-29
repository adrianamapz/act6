----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2023 22:18:34
-- Design Name: 
-- Module Name: vga_resolucion - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.numeric_std.ALL;
library work;

entity vga_768x576 is
Port ( clk, clr : in STD_LOGIC;
hsync : out STD_LOGIC;
vsync : out STD_LOGIC;
hc : out STD_LOGIC_VECTOR (9 downto 0);
vc : out STD_LOGIC_VECTOR (9 downto 0);
vidon : out STD_LOGIC);
end vga_768x576;

architecture Behavioral of vga_768x576 is
-- horizontal timig --
constant hbp : std_logic_vector (9 downto 0) := "0010101101"; -- HBP = SP+BP = 19+154 = 173
constant hfp : std_logic_vector (9 downto 0) := "1110101101"; -- HFP = HBP+HV = 173+768 = 941
constant hpixels : std_logic_vector (9 downto 0) := "1111000000"; -- quantity of pixels on horizontal
-- line = SP+BP+HV+FP = 153.6+19.2+768+19.2=960

-- vertical timig --
constant vbp : std_logic_vector (9 downto 0) := "0011011100"; -- VBP = SP+BP = 2+218 = 220
constant vfp : std_logic_vector (9 downto 0) := "1100011100"; -- VFP = 220+576 = 796
constant vlines : std_logic_vector (9 downto 0) := "1101100100"; -- quantity of vertical lines on display = SP+BP+VV+FP = 2+218+576+72= 868
-- play = P+BP+VV+FP = 2+33+480+10= 521
 
signal hcs, vcs : std_logic_vector (9 downto 0); -- horizontal & vertical counters
signal vsenable : std_logic; -- vertical counter enable
begin

-- horizontal counter syncronization signal
process (clk, clr)
begin
if (clr = '1') then
hcs <= "0000000000";
elsif (rising_edge(clk)) then
if (hcs = hpixels - 1) then -- counter has reached end of count 
hcs <= "0000000000"; -- reset
vsenable <= '1'; -- set flag to go vertical counter
else
hcs <= hcs + 1; -- increment horizontal counter
vsenable <= '0'; -- clear vertical counter flag
end if ;
end if;
end process;
hsync <= '0' when (hcs < 96) else '1'; -- SP=0 when hc<128 pixels
-- vertical counter syncronization signal
process (clk, clr, vsenable)
begin
if (clr = '1') then
vcs <= "0000000000";
elsif ((rising_edge (clk)) and (vsenable = '1')) then
if (vcs = vlines - 1) then -- counter has reached the end of count ?
vcs <= "0000000000"; -- reset
else
vcs <= vcs + 1; -- increment vertical counter
end if;
end if;
end process;
vsync <= '0' when (vcs < 2) else '1' ; -- SP=0 when vc<2 lines
vidon <= '1' when (((hcs < hfp) and (hcs >= hbp)) and ((vcs < vfp) and (vcs >= vbp))) else '0'; -- set video on when visible area

-- horizontal and vertical counters update
hc <= hcs;
vc <= vcs ;
end Behavioral;