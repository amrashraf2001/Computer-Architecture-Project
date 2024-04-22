LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Data_Memory IS
GENERIC(n : integer :=32);
    PORT(
        Clk, Rst, WriteEnable : IN STD_LOGIC;
        ReadAddress, WriteAddress : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        ReadData : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        WriteData : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0)
    );
END Data_Memory;

ARCHITECTURE Data_Memory_Architecture OF Data_Memory IS
    
	TYPE ram_type IS ARRAY(0 TO 1023) OF std_logic_vector(n-1 DOWNTO 0);
	SIGNAL ram : ram_type ;

BEGIN
   PROCESS(Clk,Rst,WriteEnable,WriteAddress,ReadAddress) IS
			BEGIN
				IF rising_edge(Clk) THEN  
					IF Rst='1' THEN
						FOR i IN ram'range LOOP
							ram(i) <= (others => '0');
						END LOOP;
					ELSIF WriteEnable = '1' THEN
						ram(to_integer(unsigned(WriteAddress))) <= WriteData;
					END IF;
				END IF;
	END PROCESS;
	ReadData <= ram(to_integer(unsigned(ReadAddress)));
       

END Data_Memory_Architecture;

