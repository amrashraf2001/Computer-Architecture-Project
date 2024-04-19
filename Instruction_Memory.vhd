LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.math_real.all;
ENTITY Instruction_Memory IS
GENERIC(n : integer :=16);
	PORT(
        ReadAddress : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- manensa4 n handle fl exception eni a address makan m4 mawgud
        ReadData: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0));
END ENTITY Instruction_Memory;

ARCHITECTURE Instruction_Memory_Architecture OF Instruction_Memory IS

    TYPE ram_type IS ARRAY(0 TO 4095) OF std_logic_vector(n-1 DOWNTO 0);
    SIGNAL ram : ram_type ;
    
BEGIN

    ReadData <= ram(to_integer(unsigned(ReadAddress)));
    
END Instruction_Memory_Architecture;
