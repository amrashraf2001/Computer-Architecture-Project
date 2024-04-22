LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Decode IS
GENERIC(n : integer :=32);
    PORT(  
        clk,rst,wrten:in std_logic;
        writeport1:in std_logic_vector(n-1 downto 0);
        writeport2:in std_logic_vector(n-1 downto 0);
        readport1:out std_logic_vector(n-1 downto 0);
        readport2:out std_logic_vector(n-1 downto 0);
        WriteAdd1: in  std_logic_vector (2 downto 0);
        WriteAdd2: in  std_logic_vector (2 downto 0);
        ReadAdd1: in  std_logic_vector (2 downto 0);
        ReadAdd2: in  std_logic_vector (2 downto 0)
    );
END ENTITY Decode;

ARCHITECTURE struct OF Decode IS
    
END struct;
