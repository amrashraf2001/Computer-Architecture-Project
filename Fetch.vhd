LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Fetch IS
GENERIC(n : integer :=32);
    PORT (
        clk : IN std_logic;
        branchingAddress: IN std_logic_vector(n-1 downto 0);
        --exceptionAddress: IN std_logic_vector(n-1 downto 0);
        --inPort: IN std_logic_vector(n-1 DOWNTO 0);
        en,rst,interrupt,branchingSel, exceptionSel, stall : IN std_logic;
        dataout: OUT std_logic_vector(15 DOWNTO 0);
        pcPlus: OUT std_logic_vector(n-1 downto 0)
    );
END ENTITY ;

ARCHITECTURE Fetch_Arch OF Fetch IS
    component PC IS
    PORT( 
    d : IN std_logic_vector (n-1 downto 0);
    q : OUT std_logic_vector (n-1 downto 0);
    clk,rst,en : IN std_logic 
    );
    END component ;

    component Instruction_Memory is
        PORT(
        ReadAddress : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        ReadData: OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    end component;
 
    signal pcIn, pcOut: std_logic_vector(n-1 downto 0);
    signal instruction: std_logic_vector(15 downto 0);
begin
    PC1: PC PORT MAP (d=>pcIn, q=>pcOut, clk=>clk, rst=>rst, en=>en);
    IM1: Instruction_Memory PORT MAP (ReadAddress=>pcOut, ReadData=>instruction);

    pcIn <= std_logic_vector(unsigned(pcOut) + "00000000000000000000000000000001") when branchingSel = '0' and exceptionSel = '0' 
        else branchingAddress when branchingSel = '1' and exceptionSel = '0' 
        else "00000000000000000000111111111100";

    dataout <= instruction when (stall = '0' and interrupt = '0') 
        else "1110010000000000" when interrupt = '1'
        else "1100000000000000"; 

    pcPlus <= std_logic_vector(unsigned(pcOut) + 1);
END Fetch_Arch;