LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY ProtectedFlagReg IS
GENERIC(n : integer :=32);
    PORT(
        Clk, Rst, WriteEnable,ReadEnable : IN STD_LOGIC;
        ReadAddress, WriteAddress : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        ReadData : OUT STD_LOGIC;
        WriteData : IN STD_LOGIC;
		WrongAddress : OUT STD_LOGIC
    );
END ProtectedFlagReg;

ARCHITECTURE ProtectedFlags_Architecture OF ProtectedFlagReg IS
    
	TYPE ram_type IS ARRAY(0 TO 4096) OF STD_LOGIC;
	SIGNAL ram : ram_type ;

BEGIN
   PROCESS(Clk,Rst,WriteEnable,WriteAddress,ReadAddress) IS
			BEGIN
				IF rising_edge(Clk) THEN  
					IF Rst='1' THEN
						FOR i IN ram'range LOOP
							ram(i) <= '0';
						END LOOP;
					ELSIF WriteEnable = '1' THEN
						IF WriteAddress < "00000000000000000001000000000000" THEN
							ram(to_integer(unsigned(WriteAddress) + 1)) <= WriteData;
							ram(to_integer(unsigned(WriteAddress))) <= WriteData;
							WrongAddress <= '0';
						ELSE
							WrongAddress <= '1';
						END IF;
					ELSIF ReadEnable = '1' THEN
						IF ReadAddress < "00000000000000000001000000000000" THEN
                    		ReadData <= ram(to_integer(unsigned(ReadAddress))) and ram(to_integer(unsigned(ReadAddress) + 1));
                    		WrongAddress <= '0';
                		ELSIF ReadAddress = "00000000000000000001000000000000" then
                	    	WrongAddress <= '0';
                	    	ReadData <= ram(to_integer(unsigned(ReadAddress)));
						ELSE
							WrongAddress <= '1';
							ReadData <= '0';
						END IF;
					END IF;
				END IF;
	END PROCESS;
       

END ProtectedFlags_Architecture;

