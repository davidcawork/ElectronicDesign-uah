----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.12.2020 00:26:20
-- Design Name: 
-- Module Name: tb_M1_gen_PWM - Behavioral
-- Project Name: 
-- Target Devices: 
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_M1_gen_PWM is
end tb_M1_gen_PWM;

architecture tb of tb_M1_gen_PWM is

    component M1_gen_PWM
        port (clk        : in std_logic;
              rst_n      : in std_logic;
              sw_Dir     : in std_logic;
              PWM_vector : in std_logic_vector (7 downto 0);
              pinDir     : out std_logic;
              pinEn      : out std_logic);
    end component;

    signal clk        : std_logic;
    signal rst_n      : std_logic;
    signal sw_Dir     : std_logic;
    signal PWM_vector : std_logic_vector (7 downto 0);
    signal pinDir     : std_logic;
    signal pinEn      : std_logic;

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : M1_gen_PWM
    port map (clk        => clk,
              rst_n      => rst_n,
              sw_Dir     => sw_Dir,
              PWM_vector => PWM_vector,
              pinDir     => pinDir,
              pinEn      => pinEn);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        sw_Dir <= '0';
        PWM_vector <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rst_n is really your reset signal
        rst_n <= '0';
        wait for 100 ns;
        rst_n <= '1';
        wait for 100 ns;
        
        -- Primer test probar distintos PWM vectors
        PWM_vector <= std_logic_vector(to_unsigned(10,PWM_vector'length)); -- 10% PWM
        wait for 10 ms;
        
        PWM_vector <= std_logic_vector(to_unsigned(25,PWM_vector'length)); -- 25% PWM
        wait for 10 ms; 
        
        PWM_vector <= std_logic_vector(to_unsigned(50,PWM_vector'length)); -- 50% PWM
        wait for 10 ms;
        
        PWM_vector <= std_logic_vector(to_unsigned(75,PWM_vector'length)); -- 75% PWM
        wait for 10 ms;
        
        -- Segundo test sw_Dir
        PWM_vector <= std_logic_vector(to_unsigned(50,PWM_vector'length)); -- 50% PWM
        wait for 10 ms;
        sw_Dir <= '1';
        wait for 25 ms;
        
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_M1_gen_PWM of tb_M1_gen_PWM is
    for tb
    end for;
end cfg_tb_M1_gen_PWM;