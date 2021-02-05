-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 5.2.2021 11:43:44 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_multiplexor is
end tb_multiplexor;

architecture tb of tb_multiplexor is

    component multiplexor
        port (in0   : in std_logic;
              in1   : in std_logic;
              in2   : in std_logic;
              in3   : in std_logic;
              sel   : in std_logic_vector (1 downto 0);
              s_out : out std_logic);
    end component;

    signal in0   : std_logic;
    signal in1   : std_logic;
    signal in2   : std_logic;
    signal in3   : std_logic;
    signal sel   : std_logic_vector (1 downto 0);
    signal s_out : std_logic;

begin

    dut : multiplexor
    port map (in0   => in0,
              in1   => in1,
              in2   => in2,
              in3   => in3,
              sel   => sel,
              s_out => s_out);

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        in0 <= '1';
        in1 <= '1';
        in2 <= '0';
        in3 <= '0';
        sel <= (others => '0');
        wait for 100ns;

        -- Test sel 1 
        sel <= "01";
        wait for 100ns;

        -- Test sel 2 
        sel <= "10";
        wait for 100ns;

        -- Test sel 3
        sel <= std_logic_vector(to_unsigned(3, sel'lenght));
        wait for 100ns;

        -- TbSimEnd <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_multiplexor of tb_multiplexor is
    for tb
    end for;
end cfg_tb_multiplexor;