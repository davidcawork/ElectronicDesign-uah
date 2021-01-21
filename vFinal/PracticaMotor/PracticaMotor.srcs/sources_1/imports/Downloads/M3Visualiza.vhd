library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity M3_visualiza is
  
  port (
    CLK         : in  std_logic;                       -- reloj de 100 MHz
    rst         : in  std_logic;                       -- rst asÌncrono (nivel bajo)
    PWM_vector  : in  std_logic_vector (7 downto 0);   -- vector de ciclo de trabajo
    sw_Dir      : in  std_logic;                       -- switch (1) para sentido de giro
    sw_sel_disp : in  std_logic;                       -- switch (1) para selecciÛn de info-display
    sw_boot     : in  std_logic;                       -- switch M13 de arranque 
    velocidad   : in  std_logic_vector (7 downto 0);
    seg7_code   : out std_logic_vector (7 downto 0);   -- bus de 7 segmentos
    sel_disp    : out std_logic_vector (3 downto 0);   -- bus de anodos de los displays -> se va a utilizar solo 4 bits (para los 4 displays no 8)
    rgb_led1    : out std_logic_vector (2 downto 0);   -- Leds RGB de la tarjeta R G B (verde => 101 | rojo => 011)
    rgb_led2    : out std_logic_vector (2 downto 0));
 -- );

end entity M3_visualiza;
 
architecture rtl of M3_visualiza is

type rom_t is array(0 to 255) of std_logic_vector(11 downto 0);     
  --
  constant rom : rom_t := (X"000", X"001", X"002", X"003", X"004", X"005", X"006", X"007", X"008", X"009", X"010", X"011", X"012", X"013", X"014", X"015",
                           X"016", X"017", X"018", X"019", X"020", X"021", X"022", X"023", X"024", X"025", X"026", X"027", X"028", X"029", X"030", X"031",
                           X"032", X"033", X"034", X"035", X"036", X"037", X"038", X"039", X"040", X"041", X"042", X"043", X"044", X"045", X"046", X"047",
                           X"048", X"049", X"050", X"051", X"052", X"053", X"054", X"055", X"056", X"057", X"058", X"059", X"060", X"061", X"062", X"063",
                           X"064", X"065", X"066", X"067", X"068", X"069", X"070", X"071", X"072", X"073", X"074", X"075", X"076", X"077", X"078", X"079",
                           X"080", X"081", X"082", X"083", X"084", X"085", X"086", X"087", X"088", X"089", X"090", X"091", X"092", X"093", X"094", X"095",
                           X"096", X"097", X"098", X"099", X"100", X"101", X"102", X"103", X"104", X"105", X"106", X"107", X"108", X"109", X"110", X"111",
                           X"112", X"113", X"114", X"115", X"116", X"117", X"118", X"119", X"120", X"121", X"122", X"123", X"124", X"125", X"126", X"127",
                           X"128", X"129", X"130", X"131", X"132", X"133", X"134", X"135", X"136", X"137", X"138", X"139", X"140", X"141", X"142", X"143",
                           X"144", X"145", X"146", X"147", X"148", X"149", X"150", X"151", X"152", X"153", X"154", X"155", X"156", X"157", X"158", X"159",
                           X"160", X"161", X"162", X"163", X"164", X"165", X"166", X"167", X"168", X"169", X"170", X"171", X"172", X"173", X"174", X"175",
                           X"176", X"177", X"178", X"179", X"180", X"181", X"182", X"183", X"184", X"185", X"186", X"187", X"188", X"189", X"190", X"191",
                           X"192", X"193", X"194", X"195", X"196", X"197", X"198", X"199", X"200", X"201", X"202", X"203", X"204", X"205", X"206", X"207", 
                           X"208", X"209", X"210", X"211", X"212", X"213", X"214", X"215", X"216", X"217", X"218", X"219", X"220", X"221", X"222", X"223", 
                           X"224", X"225", X"226", X"227", X"228", X"229", X"230", X"231", X"232", X"233", X"234", X"235", X"236", X"237", X"238", X"239", 
                           X"240", X"241", X"242", X"243", X"244", X"245", X"246", X"247", X"248", X"249", X"250", X"251", X"252", X"253", X"254", X"255");  -- matlab
  --
  signal rom_addr     : std_logic_vector(7 downto 0);
  signal rom_data     : std_logic_vector(11 downto 0);
  -- seleccion display
  signal mux_cnt      : unsigned(1 downto 0);
  --
  signal signo        : std_logic_vector(3 downto 0);
  signal bcd          : std_logic_vector(3 downto 0);
  --
  signal data_display : std_logic_vector(7 downto 0);
  --
  signal ciclos       : unsigned(19 downto 0);
  signal en_1khz      : std_logic;
  begin  
  contador : process(clk) 
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        ciclos  <= (others => '0');
        en_1khz <= '0';
      elsif ciclos >= 99999 then
        ciclos  <= (others => '0');
        en_1khz <= '1';
      else
        ciclos  <= ciclos + 1;
        en_1khz <= '0';
      end if;
    end if;
  end process;
  ----------------------------------------------------------------------------- 
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        mux_cnt <= "00";
      elsif en_1khz = '1' then
        mux_cnt <= mux_cnt + 1;
      end if;
    end if;
  end process;
  ----------------------------------------------------------------------------- 
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if (rising_edge(clk)) then
    if (rst = '1') then    ---
        rom_addr <= "00000000";
    else
      if sw_sel_disp = '1' then
        rom_addr <= velocidad;
      else
        rom_addr <= pwm_vector;
        end if;
        
      end if;
    end if;
  end process;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if (rising_edge(clk)) then
        if (rst = '1') then   ---
           rom_data <= rom(0);
        else
           rom_data <= rom(to_integer(unsigned(rom_addr)));
        end if;
    end if;
  end process;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if (rising_edge(clk)) then
      if(rst='1') then 
            signo <= X"f";         -- bcd 0xF (todos los segmentos apagados)
      else
          if sw_dir = '1' then     -- negativo
            signo <= X"A";         --bcd 0xA  codificado el signo menos
          else
            signo <= X"0";         -- bcd 0x0 (todos los segmentos apagados)
          end if;
       end if;
    end if;
  end process;
  ----------------------------------------------------------------------------- 
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        bcd <= (others => '1');
      elsif (sw_boot = '0') then
         case mux_cnt is
               when "00" =>
                 bcd <= "1111";  -- F
               when "01" =>
                  bcd <= "1111";  -- F
               when "10" =>
                  bcd <= "0000"; -- O
               when others =>                  --"11"
                 bcd <= "1000";
          end case;
      else
        case mux_cnt is
          when "00" =>
            bcd <= rom_data(3 downto 0);  -- digito de menos significativo
          when "01" =>
            bcd <= rom_data(7 downto 4);
          when "10" =>
            bcd <= rom_data(11 downto 8);
          when others =>                  --"11"
                bcd <= signo;
        end case;
      end if;
    end if;
  end process;
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------
  seg7_code <= data_display;
  process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        data_display <= (others => '1');
      else
      -- decodificador bcd a 7 segmentos
        case bcd is
          when "0000" => data_display <= "11000000"; -- 0xC0
          when "0001" => data_display <= "11111001"; -- 0xF9
          when "0010" => data_display <= "10100100"; -- 0xA4
          when "0011" => data_display <= "10110000"; -- 0xB0
          when "0100" => data_display <= "10011001"; -- 0x99
          when "0101" => data_display <= "10010010"; -- 0x92
          when "0110" => data_display <= "10000010"; -- 0x82
          when "0111" => data_display <= "11111000"; -- 0xF8
          when "1000" => data_display <= "10000000"; -- 0x80
          when "1001" => data_display <= "10011000"; -- 0x98
          when "1010" => data_display <= "10111111"; -- 0xBF  -> segmento "g"
          when "1111" => data_display <= "10001110"; -- 0x8E -> segmentos: e g f a
          when others => data_display <= "11111111"; -- 0xFF
        end case;
      end if;
    end if;
  end process;
  ----------------------------------------------------------------------------- 
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if (rising_edge(clk)) then
      if (rst = '1') then
        sel_disp <= (others => '1');
      else
        case mux_cnt is
          when "00"   => sel_disp <= "1110";  -- bcd_code := unidades 
          when "01"   => sel_disp <= "1101";  -- bcd_code := decenas
          when "10"   => sel_disp <= "1011";  -- bcd_code := centenas
          when others => sel_disp <= "0111";  -- bcd_code := signo
        end case;
      end if;
    end if;
  end process;
  
  ----------------------------------------------------------------------------- 
  -----------------------------------------------------------------------------
  process(clk)
  begin
    if (rising_edge(clk)) then
        if (rst = '1') then
            rgb_led1 <= "111";
            rgb_led2 <= "111";
        else
          if (sw_boot = '0') then  -- Apagado -> leds rojos
                rgb_led1 <= "001";  
                rgb_led2 <= "001";
          else                      -- Encendido -> Leds verdes 
                rgb_led1 <= "010";
                rgb_led2 <= "010";
          end if; --sw_boot
        end if; --rst
      end if; -- clk
  end process;

end architecture rtl;