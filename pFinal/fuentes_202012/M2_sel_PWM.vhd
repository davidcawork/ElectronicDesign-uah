library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity M2_sel_PWM is
  
  port (
    clk         : in  std_logic;        -- reloj de 100 MHz
    rst_n       : in  std_logic;        -- rst síncrono (nivel bajo)
    btn_up   : in  std_logic;           -- pulsador de incremento de D(%)
    btn_down : in  std_logic;           -- pulsador de decremento de D(%)
    PWM_vector   : out std_logic_vector (7 downto 0));  -- vector de PWM 0 a 100

end entity M2_sel_PWM;



architecture rtl of M2_sel_PWM is
  
  
begin  -- architecture rtl



  
end architecture rtl;
