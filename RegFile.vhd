LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY RegFile IS
    PORT(
        Clk, Rst, WriteEnable : IN STD_LOGIC;
        ReadAddress1, ReadAddress2, WriteAddress1,WriteAddress2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        ReadData1, ReadData2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        WriteData1,WriteData2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END RegFile;

ARCHITECTURE RegFile_Architecture OF RegFile IS
    
	TYPE ram_type IS ARRAY(0 TO 7) OF std_logic_vector(31 DOWNTO 0);
	SIGNAL ram : ram_type ;

BEGIN
   PROCESS(Clk,Rst,WriteEnable,WriteAddress1,WriteAddress2,ReadAddress1,ReadAddress2) IS
			BEGIN
				IF rising_edge(Clk) THEN  
					IF Rst='1' THEN
						FOR i IN ram'range LOOP
							ram(i) <= (others => '0');
						END LOOP;
					ELSIF WriteEnable = '1' THEN
						ram(to_integer(unsigned(WriteAddress1))) <= WriteData1;
						ram(to_integer(unsigned(WriteAddress2))) <= WriteData2;
					END IF;
				END IF;
	END PROCESS;
	ReadData1 <= ram(to_integer(unsigned(ReadAddress1)));
	ReadData2 <= ram(to_integer(unsigned(ReadAddress2)));
       

END RegFile_Architecture;

