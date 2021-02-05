library ieee;
use ieee.numeric_std.all;    -- necesario para definir los tipos signed y unsigned
use ieee.std_logic_1164.all;  -- necesario para definir los tipos de std_logic y std_logic_vector.

entity tb_e2 is
end tb_e2;

architecture  tb of tb_e2 is
-- Aqui debemos declarar las señales necesarias para la simulación y las entidades a simular
    signal rst : std_logic;
    signal clk : std_logic;
    signal en1seg : std_logic;

    component contador_seg 
        port(
            rst : in std_logic;
            clk : in std_logic;
            en1seg : out std_logic
        );
    end component;

    -- lapinoo  signals and constants 
    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin 

-- En el alpinoo nos meten estas señales para definir el clock 
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    --  EDIT: Replace YOURCLOCKSIGNAL below by the name of your clock as I haven't guessed it
    --  YOURCLOCKSIGNAL <= TbClock;

-- En este punto debemos instaciar el componente declarado 
    DUT : contador_seg
    port_map(
        rst => rst,
        clk => clk,
        en1seg => en1seg
    );

-- Y ahora en este proceso vamos a indicar el funcionamiento de la simulacion
    stimuli : process
    begin
        -- init 
        rst <= '0';
        wait for 10sec;

        -- fin
        -- tbSimEnded <= '1';
        wait;
    end process;
end tb;