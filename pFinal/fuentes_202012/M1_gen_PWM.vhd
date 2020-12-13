library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity M1_gen_PWM is
  
  port (
    clk         : in  std_logic;        -- reloj de 100 MHz
    rst_n       : in  std_logic;        -- rst síncrono (nivel bajo)
    sw_Dir      : in  std_logic;        -- switch (1) para sentido de giro
    PWM_vector  : in  std_logic_vector (7 downto 0);  -- vector de ciclo de
                                                      -- trabajo de 0 a 100%
    pinDir      : out std_logic;        -- sentido giro del motor (PMOD)
    pinEn       : out std_logic        -- salida PWM para el puente en H (PMOD)    
    );                                  

end entity M1_gen_PWM;


architecture rtl of M1_gen_PWM is

begin  -- architecture rtl



end architecture rtl;
