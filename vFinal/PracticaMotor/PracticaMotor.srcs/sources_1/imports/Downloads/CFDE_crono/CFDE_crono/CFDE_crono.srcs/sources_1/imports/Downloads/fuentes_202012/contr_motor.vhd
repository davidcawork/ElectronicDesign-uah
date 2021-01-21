library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity contr_motor is
port(
    clk  : in std_logic; -- reloj de 100 MHZ
    rst_n  :       in  std_logic;        -- reset del sistema (sncrono a nivel bajo)
    btn_up  :     in  std_logic;        -- pulsador de incremento de D(%)
	-- btn_centro   in  std_logic;        -- para motor => PinEn = 0
    btn_down :    in  std_logic;        -- pulsador de decremento de D(%)
    sw_boot   :   in  std_logic;        -- switch (1) para apagar
    sw_Dir   :   in  std_logic;        -- switch (1) para sentido de giro
    sw_sel_disp :  in  std_logic;         -- switch (1) para seleccin de info-display
    pinSA      :  in  std_logic;        -- entrada Sensor A Encoder (PMOD)
    pinSB      :  in  std_logic;        -- entrada Sensor B Encoder (PMOD)
    pinEn      : out std_logic;        -- salida PWM para el puente en H (PMOD)
    pinDir     :  out std_logic;        -- sentido giro del motor (PMOD)
    seg7_code  :  out std_logic_vector (7 downto 0);   -- bus de 7 segmentos
    sel_disp   :  out std_logic_vector (7 downto 0);  -- bus de anodos de los displays
    rgb_led1   :  out std_logic_vector (2 downto 0);  -- rgb led 1
    rgb_led2   :  out std_logic_vector (2 downto 0));  -- rgb led 2
end entity contr_motor;


architecture rtl of contr_motor is
  
  signal rst : std_logic;
  signal PWM_vector : std_logic_vector (7 downto 0);
  
  component M1_gen_PWM
   generic(
         C_Tblanking  : integer;    -- Num. de cuentas para obtener T_blanking a la frec Fclk (Fclk*T_blanking)
         C_Tpwm       : integer;      -- Num. de cuentas para obtener T_pwm a la frecuencia Fclk(Fclk*T_pwm)
         C_Tpwm_one   : integer         -- Num. de cuentas para obtener T_pwm a la frecuencia Fclk(Fclk*T_pwm) en tanto por 1
     );     
     port ( 
           clk        : in std_logic;
           rst_n      : in std_logic;
           sw_Dir     : in std_logic;
           PWM_vector : in std_logic_vector (7 downto 0);   -- viene de M2 
           pinDir     : out std_logic;
           pinEn      : out std_logic);
  end component;
 
   component M2_sel_PWM
    generic(
            C_step  : integer
        );  
      port (clk        : in std_logic;
              rst_n      : in std_logic;
              btn_up     : in std_logic;
              sw_boot   :   in  std_logic;        -- switch (1) para apagar
              btn_down   : in std_logic;
              PWM_vector : out std_logic_vector (7 downto 0));
    end component; 



component M3_visualiza
        port (CLK         : in std_logic;
              rst         : in std_logic;
              PWM_vector  : in std_logic_vector (7 downto 0);
              sw_boot   :   in  std_logic;        -- switch (1) para apagar
              sw_Dir      : in std_logic;
              sw_sel_disp : in std_logic;
              velocidad   : in std_logic_vector (7 downto 0);  -- viene de M4 
              seg7_code   : out std_logic_vector (7 downto 0);
              sel_disp    : out std_logic_vector (3 downto 0);
              rgb_led1   :  out std_logic_vector (2 downto 0);  -- rgb led 1
              rgb_led2   :  out std_logic_vector (2 downto 0));  -- rgb led 2
    end component;


    signal velocidad   : std_logic_vector (7 downto 0);


 component M4_calc_veloc
        port (clk       : in std_logic;
              rst_n     : in std_logic;
              pinSA     : in std_logic;
              pinSB     : in std_logic;
              velocidad : out std_logic_vector (7 downto 0));
    end component;



begin  -- architecture rtl


  rst <= not rst_n;

-- instaciacion de componentes 

 bloque_M1 : M1_gen_PWM
    generic map (
     C_Tblanking  => 1000000,    -- Num. de cuentas para obtener T_blanking a la frec Fclk (Fclk*T_blanking)
     C_Tpwm       => 50000,    -- Num. de cuentas para obtener T_pwm a la frecuencia Fclk(Fclk*T_pwm)
     C_Tpwm_one   => 500         -- Num. de cuentas para obtener T_pwm a la frecuencia Fclk(Fclk*T_pwm) en tanto por 1
    )    
    port map (clk        => clk,
              rst_n      => rst_n,
              sw_Dir     => sw_Dir,
              PWM_vector => PWM_vector,
              pinDir     => pinDir,
              pinEn      => pinEn);



  bloque_M2 : M2_sel_PWM
      generic map (
       C_step  => 4000000
      )    
    port map (clk        => clk,
              rst_n      => rst_n,
              sw_boot    => sw_boot,
              btn_up     => btn_up,
              btn_down   => btn_down,
              PWM_vector => PWM_vector);


  bloque_M3 : M3_visualiza
    port map (CLK         => clk,
              rst         => rst,
              PWM_vector  => PWM_vector,
              sw_boot    => sw_boot,
              sw_Dir      => sw_Dir,
              sw_sel_disp => sw_sel_disp, -- sw entrada que selecciona PWM o velocidad
              velocidad   => velocidad,
              seg7_code   => seg7_code,
              sel_disp    => sel_disp(3 downto 0),
              rgb_led1    => rgb_led1,
              rgb_led2    => rgb_led2);  -- solo 4 bits
              
    sel_disp(7 downto 4) <= "0000" ; -- los dejo encendidos, para ver algo más...
              
   bloque_M4 : M4_calc_veloc
               port map (clk       => clk,
                         rst_n     => rst_n,
                         pinSA     => pinSA,
                         pinSB     => pinSB,
                         velocidad => velocidad);       
              

end architecture rtl;
