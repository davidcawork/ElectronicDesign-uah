library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity M2_sel_PWM is
    generic(
        C_step  : integer := 4000000    -- Num. de cuentas para obtener un tiempo de transición a la hora de apagar el motor
    );    

    Port ( clk : in STD_LOGIC;
           rst_n : in STD_LOGIC;
           btn_up : in STD_LOGIC;
           btn_down : in STD_LOGIC;
           sw_boot : in STD_LOGIC;
           PWM_vector : out STD_LOGIC_VECTOR (7 downto 0));
end M2_sel_PWM;

architecture Behavioral of M2_sel_PWM is
-- Detector de cuenta ascendente (Botón up)
    signal btn_up_reg : std_logic;                  --btn_up registrado
    signal btn_up_reg2 : std_logic;                 --Salida biestable D (detector flanco up)
    signal cnt_up_en : std_logic;                   --Salida total detector: Enable sumar 1
    signal up_TC : std_logic;                       --Fin cuenta temporización (250ms)
    signal up_cnt : unsigned(24 downto 0);          --Valor contador en cada iteración (VALUE = 25e6)
-- Detector de cuenta descendente (Botón down)
    signal btn_down_reg : std_logic;                --btn_down registrado
    signal btn_down_reg2 : std_logic;               --Salida biestable D (detector flanco down)
    signal cnt_down_en : std_logic;                 --Salida total detector: Enable restar 1
    signal down_TC : std_logic;                     --Fin cuenta temporización (250ms)
    signal down_cnt : unsigned(24 downto 0);        --Valor contador en cada iteración (VALUE = 25e6)
-- Contador para ciclo de trabajo
    signal PWM_cycle : unsigned(7 downto 0) := (others => '0');    --Valor del contador interno(+1 con up_cnt_en y -1 con down_cnt_en) Valor inicial = 0
-- Modulo de arranque
    signal boot_cnt : unsigned(21 downto 0);         -- Necesitamos minimo 22 bits para contar 4M de cuentas -> 2^22 => 4M.19
    signal boot_step : std_logic; 
begin
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Detector de flanco ASCENDENTE + temporización (250ms)  BOTÓN UP 
-- Cada biestable es un proceso dependiente de clk + contador (Todo sync con clk)
    sync_clk_up: process(clk)    -- Primer biestable = sincronizar cambios boton up con flancos activos clk
    begin 
        if (clk'event and clk='1') then  
            if(rst_n='0' or up_TC='0' or sw_boot='0') then    -- Reset activo sincrono y comprobamos que si está apagado
                btn_up_reg <= '0';
            else                               -- Pasa valor de entrada (btn_up) a salida registro (btn_up_reg)
                btn_up_reg <= btn_up;
            end if;         
        end if;
    end process;
    
    detector_flanco_up: process(clk)    -- Segundo biestable = detector de flanco
    begin 
        if (clk'event and clk='1') then  
            if(rst_n='0' or sw_boot='0') then  -- Reset y arranque activo sincrono
                btn_up_reg2 <= '0';
            else                               -- Pasa valor de entrada (btn_up_reg) a salida detector (btn_up_reg2)
                btn_up_reg2 <= btn_up_reg;
            end if;         
        end if;
    end process;
    
    cnt_up_en <= btn_up_reg and not btn_up_reg2;
    
    temporizacion_up: process(clk)  --Contador para temporización
    begin
        if(clk'event and clk='1') then                      -- Todo sincrono
            if(rst_n='0' or sw_boot='0') then
                up_cnt <= (others => '0');
                up_TC <= '0';
            else
                if (cnt_up_en='1') then
                    up_cnt <= to_unsigned(25e6-1-2,25);     -- Cargar VALUE de 25e6 para 250ms en 25 bits
                elsif(up_cnt > 0) then                      -- Cuando llegue a 0 paramos de restar hasta volver a cargar VALUE (cnt_up_en = 1)              
                    up_cnt <= up_cnt-1;                     -- Contador descendente
                end if;
                if (up_cnt = 0) then
                    up_TC <= '1';
                else
                    up_TC <= '0';
                end if;
            end if;
        end if;
    end process;
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Detector de flanco ASCENDENTE + temporización (250ms)  BOTÓN DOWN
-- Cada biestable es un proceso dependiente de clk + contador (Todo sync con clk)
    sync_clk_down: process(clk)    -- Primer biestable = sincronizar cambios boton down con flancos activos clk
    begin 
        if (clk'event and clk='1') then  
            if(rst_n='0' or down_TC='0' or sw_boot='0') then     -- Reset activo sincrono
                btn_down_reg <= '0';
            else                                  -- Pasa valor de entrada (btn_up) a salida registro (btn_up_reg)
                btn_down_reg <= btn_down;
            end if;         
        end if;
    end process;
    
    detector_flanco_down: process(clk)    -- Segundo biestable = detector de flanco
    begin
        if (clk'event and clk='1') then
            if (rst_n ='0' or sw_boot='0') then
                btn_down_reg2 <= '0';
            else                                  -- Pasa valor de entrada (btn_up_reg) a salida detector (btn_up_reg2)
                btn_down_reg2 <= btn_down_reg;
            end if;
        end if;
    end process;
    
    cnt_down_en <= btn_down_reg and not btn_down_reg2;
    
    temporizacion_down: process(clk)    -- Contador para la temporización (250ms) + evitar rebotes botones
    begin
        if (clk'event and clk='1') then
            if (rst_n = '0' or sw_boot='0') then
                down_cnt<=(others => '0');
                down_TC <= '0';
            else
                if(cnt_down_en = '1') then
                    down_cnt<=to_unsigned(25e6-1,25);   -- Cargar VALUE de 25e6 para 250ms en 25 bits
                elsif(down_cnt>0) then                  -- Cuando llegue a 0 paramos de restar hasta volver a cargar VALUE (cnt_up_en = 1)
                    down_cnt <= down_cnt-1;             -- Contador descendente
                end if;
                if (down_cnt = 0) then
                    down_TC <= '1';
                else
                    down_TC <= '0';
                end if;
            end if;            
        end if;
    end process;
----------------------------------------------------------------------------------------------------------------------------------------------------
-- Contador con rango [0-100] para ciclo de trabajo PWM -> +1 con cnt_up_en y -1 con cnt_down_en
-- Valor inicial de 0 (No baja más de 0 y no sube más de 100) -> Salida PWM_vector[7:0]
    contador_ciclo_PWM: process(clk)
    begin
        if(clk'event and clk='1') then  --Todo síncrono
            if (rst_n='0') then
                PWM_cycle <= (others => '0');
            elsif (sw_boot='0') then
                if (PWM_cycle /= 0) then
                    if (boot_step = '1') then 
                        if (PWM_cycle > 0) then                    -- No bajamos más de 0
                            PWM_cycle <= PWM_cycle - 1;
                        else
                            PWM_cycle <= (others => '0');           -- Más seguro
                        end if;
                    end if; -- si se ha cumplido el step de 50ms
                end if; 
            else
                if(cnt_up_en ='1') then                        -- Botón up = +1
                    if (PWM_cycle < 100) then                  -- No subimos más de 100
                        PWM_cycle <= PWM_cycle+1;
                    else 
                        PWM_cycle <= to_unsigned(100,8);       -- Más seguro
                    end if;
                elsif(cnt_down_en = '1') then                  -- Botón down = -1
                    if (PWM_cycle > 0) then                    -- No bajamos más de 0
                        PWM_cycle <= PWM_cycle-1;
                    else
                        PWM_cycle <= (others => '0');           -- Más seguro
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    PWM_vector <= std_logic_vector(PWM_cycle);
    
    ----------------------------------------------------------------------------------------------------------------------------------------------------
    contador_50ms: process(clk)
    begin
        if(clk'event and clk='1') then  --Todo síncrono
             if (rst_n='0') then
                boot_cnt <= (others => '0');
             else
                if (sw_boot='0') then
                    if ( boot_cnt = C_step) then        -- Cada 40ms
                        boot_cnt <= (others => '0');
                        boot_step <= '1';
                    else
                        boot_cnt <= boot_cnt + 1;
                        boot_step <= '0';
                    end if; -- boot_cnt
                end if; -- sw_boot
             end if; -- rst
        end if; --clk
    end process;
    
end Behavioral;













