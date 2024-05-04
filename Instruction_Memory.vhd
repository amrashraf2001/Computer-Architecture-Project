LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;
ENTITY Instruction_Memory IS
GENERIC(n : integer :=16);
	PORT(
        ReadAddress : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
        ReadData: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        WrongAddress: OUT STD_LOGIC);
END ENTITY Instruction_Memory;

ARCHITECTURE Instruction_Memory_Architecture OF Instruction_Memory IS

    TYPE ram_type IS ARRAY(0 TO 4095) OF std_logic_vector(n-1 DOWNTO 0);
    SIGNAL ram : ram_type ;
    
BEGIN
    PROCESS(ReadAddress) is
        begin
            if ReadAddress < "0000000000000000001000000000000" THEN
                ReadData <= ram(to_integer(unsigned(ReadAddress)));
                WrongAddress <= '0';
            else
                ReadData <= (others => '0');
                WrongAddress <= '1';
            end if;
    END PROCESS; 
    
END Instruction_Memory_Architecture;
