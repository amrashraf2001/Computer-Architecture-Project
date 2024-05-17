LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY PC IS
GENERIC(n : integer :=32);
PORT( 
    instmem0 : IN std_logic_vector (15 downto 0);
    instmem2 : IN std_logic_vector (15 downto 0);
    d : IN std_logic_vector (n-1 downto 0);
    q : OUT std_logic_vector (n-1 downto 0);
    clk,rst,en,INT : IN std_logic
);
END ENTITY;

ARCHITECTURE PC_Arch OF PC IS
    BEGIN
        PROCESS(clk,rst)
        BEGIN
        IF(rst = '1') THEN
            q <= "0000000000000000" & instmem0;
        ELSIF INT = '1' THEN
            q <= "0000000000000000" & instmem2;
        ELSIF clk'event and clk = '1' THEN
            if en = '1' then 
                q <= d;
            END IF;
        END IF;
    END PROCESS;
END PC_Arch;