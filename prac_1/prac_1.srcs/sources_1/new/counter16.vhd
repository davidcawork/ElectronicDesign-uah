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
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter16 is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           ce : in STD_LOGIC;
           load_enable : in STD_LOGIC;
           input_load : in STD_LOGIC_VECTOR (3 downto 0);
           count : out STD_LOGIC_VECTOR (3 downto 0));
end counter16;

architecture Behavioral of counter16 is
    signal count_aux: std_logic_vector(3 downto 0);
    
begin
    process (clk)
    begin
        if clk='1' and clk'event then
            if reset='1' then
                count_aux <= (others => '0');
            elsif ce='1' then
                if load_enable='1' then
                    count_aux <= input_load;
                else
                    count_aux <= count_aux + 1;
                end if;
            end if;
        end if;
    end process;
    
    count <= count_aux;

end Behavioral;
