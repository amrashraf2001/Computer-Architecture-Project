LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Data_Memory IS
    GENERIC (n : INTEGER := 32);
    PORT (
        Clk, Rst, WriteEnable : IN STD_LOGIC;
        ReadAddress, WriteAddress : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        ReadData : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        WriteData : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        WrongAddress : OUT STD_LOGIC
    );
END Data_Memory;

ARCHITECTURE Data_Memory_Architecture OF Data_Memory IS
    TYPE ram_type IS ARRAY (0 TO 4096) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ram : ram_type;

BEGIN
    PROCESS (Clk, Rst)
    BEGIN
        IF Rst = '1' THEN
            FOR i IN ram'range LOOP
                ram(i) <= (OTHERS => '0');
            END LOOP;
        ELSIF RISING_EDGE(Clk) THEN
            IF WriteEnable = '1' THEN
                IF WriteAddress < "00000000000000000001000000000000" THEN
                    ram(to_integer(unsigned(WriteAddress) + 1)) <= WriteData(15 downto 0);
                    ram(to_integer(unsigned(WriteAddress))) <= WriteData(31 downto 16);
                    WrongAddress <= '0';
                ELSE
                    WrongAddress <= '1';
                END IF;
            END IF;

            IF ReadAddress < "00000000000000000001000000000000" THEN
                ReadData <= ram(to_integer(unsigned(ReadAddress)+ 1)) & ram(to_integer(unsigned(ReadAddress)));
                WrongAddress <= '0';
            ELSE
                WrongAddress <= '1';
                ReadData <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;

END Data_Memory_Architecture;
