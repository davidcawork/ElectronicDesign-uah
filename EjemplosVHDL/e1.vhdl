-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplexor is 
	port(
    	in0, in1, in2, in3 : in std_logic;
        sel		: in std_logic_vector(1 downto 0);
        s_out	: out std_logic);
end multiplexor;

architecture RTL of multiplexor is
--	Aqui meteríamos las señales internas 
begin

	process (sel, in0, in1, in2, in3)
    -- aqui irian las variables 
	begin
		case sel is
        	when "00" =>
            	s_out <= in0;
            -----
            when "01" =>
            	s_out <= in1;
            -----
            when "10" =>
            	s_out <= in2;
            -----
            when "11" =>
            	s_out <= in3;
         end case;   
            
	end process;

end RTL;