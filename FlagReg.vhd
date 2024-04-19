Library IEEE;
use ieee.std_logic_1164.all;

ENTITY FlagReg IS
GENERIC ( n : integer := 4);
    PORT( 
        clk,rst,en : IN std_logic;
        d : IN std_logic_vector(n-1 DOWNTO 0);
        q : OUT std_logic_vector(n-1 DOWNTO 0));
END FlagReg;

ARCHITECTURE FlagReg_Arch OF FlagReg IS
    BEGIN
        PROCESS (clk,rst)
        BEGIN
            IF rst = '1' THEN
                q <= (OTHERS=>'0');
            ELSIF rising_edge(clk) AND en='1' THEN
                q <= d;
            END IF;
        END PROCESS;
END FlagReg_Arch;