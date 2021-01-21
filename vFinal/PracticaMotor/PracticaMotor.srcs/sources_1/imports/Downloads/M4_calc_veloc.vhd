
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity M4_calc_veloc is
  port (
    clk       : in  std_logic;          -- reloj de 100 MHZ
    rst_n       : in  std_logic;          -- reset del sistema (nivel bajo)
    pinSA     : in  std_logic;          -- entrada Sensor A Encoder (PMOD)
    pinSB     : in  std_logic;          -- entrada Sensor B Encoder (PMOD)
    velocidad : out std_logic_vector (7 downto 0));  -- velocidad del motor en
                                                     -- rpm (max. 100)
end entity M4_calc_veloc;


architecture rtl2 of M4_calc_veloc is

  -----------------------------------------------------------------------------
  -- VALORES PARA SIMULACIÓN
  -----------------------------------------------------------------------------

  --constant FIN_CUENTA_025  : integer := 2500;  -- 2500*10ns(100MHz)=25us
  --signal cnt_prescaler_025 : unsigned (12 downto 0);  -- contador del prescaler de 0.25sg

  -----------------------------------------------------------------------------
  -- VALORES PARA IMPLEMENTACION
  -----------------------------------------------------------------------------
  constant FIN_CUENTA_025  : integer := 25000000;  -- 25.000.000x10ns(100MHz)=0.25s
  signal cnt_prescaler_025 : unsigned (24 downto 0);  -- contador del prescaler de 0.25sg

  signal TC_025, TC_025_n, TC_025_reg : std_logic;  -- señal de fin de cuenta Prescaler

  signal n_pulsos : unsigned (7 downto 0);  -- contador de pulsos de SA

  signal regSA, oldSA, oldSA2 : std_logic;  -- registros para detectar el cambio de nivel de SA

  signal velocidad_output : std_logic_vector (10 downto 0);  -- calculo intermedio de la velocidad

--   signal cte_Multiplicador_B : unsigned_vector (2 downto 0);  -- dato '3' para el multiplicador que calcula la velocidad

  signal n_pulsos_reg : std_logic_vector (7 downto 0);  -- dato B del multiplicador
  
  signal rst : std_logic;
  

begin  -- architecture rtl2

    rst <= not rst_n; 
    
  -----------------------------------------------------------------------------
  -- Prescaler de 0,250 sg / 25 us
  -----------------------------------------------------------------------------

  process (clk) is
  begin  -- process
      
    if rising_edge(clk) then  -- rising clock edge
		if rst_n = '0' then         -- synchronous reset (active low)
		  TC_025     <= '0';
		  cnt_prescaler_025 <= (others => '0');
		  TC_025_reg <= '0';
		else
		  if cnt_prescaler_025 /= FIN_CUENTA_025 -1 then
			cnt_prescaler_025 <= cnt_prescaler_025 + 1;
			TC_025            <= '0';
		  else
			TC_025            <= '1';
			cnt_prescaler_025 <= (others => '0');
		  end if;
		  TC_025_reg <= TC_025; -- registrado para usarlo en una etapa posterior, sincronizando el flujo de datos 
		end if; -- rst_n
    end if; -- clk
  end process;

  -- TC_025_n <= not TC_025;

-------------------------------------------------------------------------------
-- detección y cuenta de pulsos
-------------------------------------------------------------------------------

  process (clk) is   -- durante el tiempo marcado por el proceso p1, cuenta el número de pulsos recibidos por pinSA
    variable filtro_rebotes_pinSA :  std_logic_vector(9 downto 0); -- retardo de 10 ciclos   
    variable aux_multiplicacion : unsigned(10 downto 0);
    constant cte_u3 : unsigned(2 downto 0):= "011";
  begin  -- process
    if rising_edge(clk) then  -- rising clock edge
		if rst_n = '0' then         -- synchronous reset (active low)
		  n_pulsos     <= (others => '0');
		  n_pulsos_reg <= (others => '0');
		  aux_multiplicacion  := (others => '0');
			  
    	   filtro_rebotes_pinSA := (others => '0');  
		else		 

          filtro_rebotes_pinSA := PinSA & filtro_rebotes_pinSA(9 downto 1);  -- registro de desplazamiento
            
		  -- detecto pulso de subida de SA estando habilitado el timer
		  if (TC_025 = '0') then -- no hemos llegado al final del tiempo de cuenta
		   
		      if (filtro_rebotes_pinSA(filtro_rebotes_pinSA'left) = '1' and  filtro_rebotes_pinSA(0) = '0' ) then   -- si llega un nuevo pulso en "SA"
			     n_pulsos <= n_pulsos + 1;  -- almacena el número de pulsos recibidos / base_de_tiempo dada
			     filtro_rebotes_pinSA := (others => '1'); 
              end if;
		  else  -- f (TC_025_n = '0') then       -- fin del timer  => TC_025 = '1'
		  	n_pulsos     <= (others => '0');		  			 
		    aux_multiplicacion := (n_pulsos *  cte_u3 );
		    velocidad <=  std_logic_vector (aux_multiplicacion (8 downto 1));
		  end if;
		end if;
	end if;
  end process;


---------------------------------------------------------------------------------
---- proceso para generar el CE del multiplicador
---------------------------------------------------------------------------------

--  process (clk) is
--  begin  -- process
--    if rising_edge(clk) then  -- rising clock edge
--    	if rst_n = '0' then         -- synchronous reset (active low)
--			TC_025_reg <= '0';
--		else
--			TC_025_reg <= '0';
--			if TC_025 = '1' then
--				TC_025_reg <= '1';
--			end if;
--		end if;
--    end if;
--  end process;

  -----------------------------------------------------------------------------
  -- Cálculo de la velocidad:
  -- Vmax= 150 r.p.m; Reductora: 1:53; PulsosxVuelta=3; base_sg=4 (4*0,25)
  -- velocidad= n_pulsos_reg x base_sg x 60 sg /(reductora x PulsosxVuelta)
  -- velocidad= n_pulsos_reg x 4 x 60/(53 x 3)= n_pulsos_reg x 1.5 =
  -- = (3 x pulsos_reg) / 2
  -----------------------------------------------------------------------------

--  cte_Multiplicador_B <= "011";  

--  --MULT_MACRO: Multiply Function implemented in a DSP48E
--  --7 Series
--  --Xilinx HDL Language Template, version 2017.4
--  MULT_MACRO_inst : MULT_MACRO
--    generic map (
--      DEVICE  => "7SERIES",  -- Target Device: "VIRTEX5", "7SERIES", "SPARTAN6"
--      LATENCY => 1,                     -- Desired clock cycle latency, 0-4
--      WIDTH_A => 6,                     -- Multiplier A-input bus width, 1-25  , vale poner 6 bits en n_pulsos_reg 
--      WIDTH_B => 3)                     -- Multiplier B-input bus width, 1-18
--    port map (
--      P   => velocidad_output,  -- Multiplier ouput bus, width determined by WIDTH_P generic
--      A   => n_pulsos_reg,  -- Multiplier input A bus, width determined by WIDTH_A generic
--      B   => cte_Multiplicador_B,  -- Multiplier input B bus, width determined by WIDTH_B generic
--      CE  => TC_025_reg,                -- 1-bit active high input clock enable
--      CLK => CLK,                       -- 1-bit positive edge clock input
--      RST => rst);                    -- 1-bit input active high reset

--  --end of MULT_MACRO_inst instantiation

--  -- la velocidad es la velocidad output dividida entre dos  velocidad_output => era de 11 bits, nos quedamos con 9
--  velocidad <= (velocidad_output (8 downto 1));   -- la velocidad máxima nunca supera el valor de 255




end architecture rtl2;




