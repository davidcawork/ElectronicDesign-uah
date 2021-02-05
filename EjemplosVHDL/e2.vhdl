-- Supongo que se va a trabajar con la nexys 4, que va a unos 100MHz

library ieee;
use ieee.numeric_std.all;    -- necesario para definir los tipos signed y unsigned
use ieee.std_logic_1164.all;  -- necesario para definir los tipos de std_logic y std_logic_vector.


entity contador_seg is
    generic(
        cuentas1seg : integer := 100000000 -- Al final no hacemos mas que (Fpclk * Tseg)
    );

    port(  
        clk : in std_logic;
        rst : in std_logic;
        en1seg : out std_logic
    );
end contador_seg;

architecture RTL of contador_seg is
    -- Señales aqui
    signal cnt : unsigned (26 downto 0); -- 27 bits ya que 2^(27) -> 134M de cuentas, con 26 bits tendríamos la mitad

    process (clk)
        if rising_edge(clk) then
            if ( rst = '1') then
                cnt <= '0';
                cnt <= (others => '0');            
            else
                if ( cnt = cuentas1seg ) then
                    en1seg <= '1';
                    cnt <= (others => '0');
                end if; -- match del cnt
                    cnt <= cnt + 1;
                    en1seg <= '0';
            end if; --rst
        end if; -- clk
    end process; -- process
end RTL;
