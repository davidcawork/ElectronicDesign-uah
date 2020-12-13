library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity M4_calc_veloc is
  port (
    clk       : in  std_logic;          -- reloj de 100 MHZ
    rst_n       : in  std_logic;        -- reset del sistema (nivel bajo)
    pinSA     : in  std_logic;          -- entrada Sensor A Encoder (PMOD)
    pinSB     : in  std_logic;          -- entrada Sensor B Encoder (PMOD)
    velocidad : out std_logic_vector (7 downto 0));  -- velocidad del motor en rpm
                                                     
end entity M4_calc_veloc;


architecture rtl of M4_calc_veloc is


begin  -- architecture rtl



end architecture rtl;




