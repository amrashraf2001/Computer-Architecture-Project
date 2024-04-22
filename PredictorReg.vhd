LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY PredictorReg IS
PORT( 
    d : IN std_logic;
    q : OUT std_logic;
    clk,rst,en : IN std_logic 
);
END ENTITY;

ARCHITECTURE PredictorReg_Arch OF PredictorReg IS
    BEGIN
        PROCESS(clk,rst)
        BEGIN
        IF(rst = '1') THEN
            q <= '0';
        ELSIF clk'event and clk = '1' THEN
            if en = '1' then 
                q <= d;
            END IF;
        END IF;
    END PROCESS;
END PredictorReg_Arch;