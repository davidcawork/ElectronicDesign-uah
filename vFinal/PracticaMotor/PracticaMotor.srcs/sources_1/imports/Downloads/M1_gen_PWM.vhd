library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity M1_gen_PWM is
    generic(
        C_Tblanking  : integer := 1000000;    -- Num. de cuentas para obtener T_blanking a la frec Fclk (Fclk*T_blanking)
        C_Tpwm       : integer := 50000;      -- Num. de cuentas para obtener T_pwm a la frecuencia Fclk(Fclk*T_pwm)
        C_Tpwm_one   : integer := 500         -- Num. de cuentas para obtener T_pwm a la frecuencia Fclk(Fclk*T_pwm) en tanto por 1
    );        
  
    port (
        clk         : in  std_logic;          -- reloj de 100 MHz
        rst_n       : in  std_logic;          -- rst síncrono (nivel bajo)
        sw_Dir      : in  std_logic;          -- switch (1) para sentido de giro
        PWM_vector  : in  std_logic_vector (7 downto 0);    -- vector de ciclo de
                                                            -- trabajo de 0 a 100%
        pinDir      : out std_logic;        -- sentido giro del motor (PMOD)
        pinEn       : out std_logic         -- salida PWM para el puente en H (PMOD)    
    );                                  

end entity M1_gen_PWM;


architecture rtl of M1_gen_PWM is
    type   estados_t is (s0,s1,s2);                     -- Me declaro mi tipo lista de estados
    signal estado_actual : estados_t;                   -- Añado una señal que nos indique el estado actual en el que se encuentra el mod.
    signal sw_Dir_old : std_logic;                      -- Registro para gestionar mejor si han modificado la direccion de giro
    signal cnt_Tblanking : unsigned ( 19 downto 0);     -- Contador para contar las 1M de cuentas (2^20 s= 1M )
    signal cnt_Tpwm : unsigned ( 15 downto 0);          -- Contador para contar las C_Tpwm cuentas (2^16 s= 64K )
begin  
    -- Proceso de CLK (Cada vez que CLK varie el proceso se ejecuta, ya que está en su lista de sensibilidad)
    process(clk)	
       variable state : estados_t;                  -- Estado de la máquina secuencial
       variable Cduty : integer;                    -- Var aux para gestionar el duty cl.
    begin    
        if rising_edge(clk) then
           if (rst_n = '0') then
               state       := s0;  -- para que actualizar sea 1
               estado_actual <= state;
               cnt_Tblanking <= (others => '0');  -- Reiniciar contadores
               cnt_Tpwm <= (others => '0');       -- Reiniciar contadores
               pinDir <= sw_Dir;                  -- Marcamos la dirección giro en el inicio
               sw_Dir_old <= sw_Dir;              -- Importante -> necesitamos guardar el estado anterior 
               pinEn <= '0';                      -- Sacamos un cero en la PWM.
           else
               -- Init vars
               sw_Dir_old <= sw_Dir; 
               Cduty := to_integer(unsigned(PWM_vector))*C_Tpwm_one;

               -- Manejador de estados (FSM) 
               case state is
                  ---------------------------------------------------------------   
                  -- No es necesario este estado dado que si mantenemos pulsado el reset, no se ejecutaría.
                  -- Por tanto, debemos meter el codigo del estado init, en el handler del reset.
--                   when init =>
--                     cnt_Tblanking <= (others => '0');  -- Reiniciar contadores
--                     cnt_Tpwm <= (others => '0');       -- Reiniciar contadores
--                     state := s0;                       -- Establecemos el estado siguiente
--                     pinDir <= sw_Dir;                  -- Marcamos la dirección giro en el inicio
--                     pinEn <= '0';                      -- Sacamos un cero en la PWM.
                  ---------------------------------------------------------------   
                   when s0 =>
                     -- Debemos comprobar si se ha modificado sw_Dir
                     if (sw_Dir_old /= sw_Dir) then
                        cnt_Tblanking <= (others => '0');       -- Ponemos a 0 el contador del timeout, pasamos al siguiente estado
                        state := s1;
                     else
                        -- Generar PWM
                        if (cnt_Tpwm = C_Tpwm) then             -- Generador de PWM: teniendo las cuentas a nivel alto, obtenidas con el vector pwm,                                                               
                            cnt_Tpwm <= (others => '0');        --                   mantendremos pinEn en alto hasta que que se supere dicho umbral.
                        elsif (cnt_Tpwm  < Cduty) then          --                   
                            pinEn <= '1';                       --                  Cuando el umbral sea superado, cambiaremos a 0 el pinEn para respetar el 
                            cnt_Tpwm <= cnt_Tpwm +1;            --                  ciclo de trabajo :)
                        else
                            pinEn <= '0';
                            cnt_Tpwm <= cnt_Tpwm +1; 
                        end if;
                        pinDir <= sw_Dir;                      
                     end if;
                  ---------------------------------------------------------------   
                   when s1 =>
                     if (cnt_Tblanking = C_Tblanking) then
                        cnt_Tblanking <= (others => '0');       -- Ponemos a 0 el contador del timeout, pasamos al siguiente estado
                        state := s2;
                     else
                        cnt_Tblanking <= cnt_Tblanking + 1;
                        pinEn <= '0';
                     end if;
                  ---------------------------------------------------------------   
                   when s2 =>
                     if (cnt_Tblanking = C_Tblanking) then      -- Mayor o igual para hacer una implementación más segura, en caso de que nos pasemos de cuentas bnos aseguramos que pasemos estado.
                        cnt_Tblanking <= (others => '0');       -- Ponemos a 0 el contador del timeout, pasamos al siguiente estado
                        state := s0;
                     else
                        cnt_Tblanking <= cnt_Tblanking + 1;
                        pinEn <= '0';
                        pinDir <= sw_Dir;                       -- Marcamos la dirección de giro
                     end if;
               end case;
                  ---------------------------------------------------------------   
               estado_actual <= state;          
           end if;
        end if;
     end process;


end architecture rtl;
