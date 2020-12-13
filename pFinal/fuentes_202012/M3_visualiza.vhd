library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity M3_visualiza is
  
  port (
    CLK         : in  std_logic;        -- reloj de 100 MHz
    rst         : in  std_logic;        -- rst asíncrono (nivel bajo)
    PWM_vector  : in  std_logic_vector (7 downto 0);  -- vector de ciclo de trabajo
    sw_Dir      : in  std_logic;        -- switch (1) para sentido de giro
    sw_sel_disp : in  std_logic;  -- switch (1) para selección de info-display
    velocidad   : in  std_logic_vector (7 downto 0);
    seg7_code   : out std_logic_vector (7 downto 0);  -- bus de 7 segmentos
    sel_disp    : out std_logic_vector (7 downto 0));  -- bus de anodos de los displays
  );

end entity M3_visualiza;


 


architecture rtl of M3_visualiza is

begin  -- architecture rtl



end architecture rtl;
