library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity contr_motor is  
  port (
    clk          in  std_logic;        -- reloj de 100 MHZ
    rst_n        in  std_logic;        -- reset del sistema (síncrono a nivel bajo)
    btn_up       in  std_logic;        -- pulsador de incremento de D(%)
	-- btn_centro   in  std_logic;        -- para motor => PinEn = 0
    btn_down     in  std_logic;        -- pulsador de decremento de D(%)
    sw_Dir       in  std_logic;        -- switch (1) para sentido de giro
    sw_sel_disp  in  std_logic;         -- switch (1) para selección de info-display
    pinSA        in  std_logic;        -- entrada Sensor A Encoder (PMOD)
    pinSB        in  std_logic;        -- entrada Sensor B Encoder (PMOD)
    pinEn        out std_logic;        -- salida PWM para el puente en H (PMOD)
    pinDir       out std_logic;        -- sentido giro del motor (PMOD)
    seg7_code    out std_logic_vector (7 downto 0);   -- bus de 7 segmentos
    sel_disp     out std_logic_vector (7 downto 0));  -- bus de anodos de los displays
end entity contr_motor;


architecture rtl of contr_motor is

begin  -- architecture rtl



end architecture rtl;
