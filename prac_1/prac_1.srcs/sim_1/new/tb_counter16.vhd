----------------------------------------------------------------------------------
-- Company: UAH
-- Engineer: David Carrascal
-- 
-- Create Date: 15.11.2020 12:01:12
-- Design Name: Counter16
-- Module Name: counter16 - Behavioral
-- Project Name: Counter16 - Prac. 1 
-- Target Devices: Nexys 4
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_counter16 is
end tb_counter16;

architecture tb of tb_counter16 is

    component counter16
        port (clk         : in std_logic;
              reset       : in std_logic;
              ce          : in std_logic;
              load_enable : in std_logic;
              input_load  : in std_logic_vector (3 downto 0);
              count       : out std_logic_vector (3 downto 0));
    end component;

    signal clk         : std_logic;
    signal reset       : std_logic;
    signal ce          : std_logic;
    signal load_enable : std_logic;
    signal input_load  : std_logic_vector (3 downto 0);
    signal count       : std_logic_vector (3 downto 0);

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : counter16
    port map (clk         => clk,
              reset       => reset,
              ce          => ce,
              load_enable => load_enable,
              input_load  => input_load,
              count       => count);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        ce <= '0';
        load_enable <= '0';
        input_load <= (others => '0');

        -- Reset generation
        -- EDIT: Check that reset is really your reset signal
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        ce<='1';
        wait for 100 ns;
        input_load <="0011";
        load_enable <='1';
        wait for 100ns;
        load_enable <='0';

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_counter16 of tb_counter16 is
    for tb
    end for;
end cfg_tb_counter16;