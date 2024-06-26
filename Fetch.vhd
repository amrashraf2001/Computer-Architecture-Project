LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Fetch IS
GENERIC(n : integer :=32);
    PORT (
        clk : IN std_logic;
        branchingAddress: IN std_logic_vector(n-1 downto 0);
        en,rst,interrupt,branchingSel, exceptionSel, stall : IN std_logic;
        dataout: OUT std_logic_vector(15 DOWNTO 0);
        pcPlus: OUT std_logic_vector(n-1 downto 0);
        WrongAddress: OUT std_logic
    );
END ENTITY ;

ARCHITECTURE Fetch_Arch OF Fetch IS
    component PC IS
    PORT( 
        instmem0 : IN std_logic_vector (15 downto 0);
        instmem2 : IN std_logic_vector (15 downto 0);
        d : IN std_logic_vector (n-1 downto 0);
        q : OUT std_logic_vector (n-1 downto 0);
        clk,rst,en,INT : IN std_logic
    );
    END component ;

    component Instruction_Memory is
        PORT(
            ReadAddress : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
            ReadData: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            instmem0: out  std_logic_vector (15 downto 0);
            instmem2: out  std_logic_vector (15 downto 0);
            WrongAddress: OUT STD_LOGIC);
    end component;
 
    signal pcIn, pcOut: std_logic_vector(n-1 downto 0);
    signal instruction: std_logic_vector(15 downto 0);
    signal instmem0Temp, instmem2Temp: std_logic_vector(15 downto 0);
begin
    PC1: PC PORT MAP (instmem0 =>instmem0Temp, instmem2 => instmem2Temp ,d=>pcIn, q=>pcOut, clk=>clk, rst=>rst, en=>en, INT => interrupt);
    IM1: Instruction_Memory PORT MAP (ReadAddress=>pcOut, ReadData=>instruction, instmem0 =>instmem0Temp, instmem2 => instmem2Temp, WrongAddress=>WrongAddress);

    --TODO:en <= '1' when stall = '0' and interrupt = '0' else '0'; fl integration matensa4 ya amr nta w sarraa

    pcIn <= std_logic_vector(unsigned(pcOut) + "00000000000000000000000000000001") when branchingSel = '0' and exceptionSel = '0' and stall = '0'
        else "00000000000000000000111111111100" when branchingSel = '0' and exceptionSel = '1'
        else branchingAddress when branchingSel = '1' and exceptionSel = '0' and stall = '0'
        else "00000000000000000000111111111100" when exceptionSel = '1' and branchingSel = '1' 
        --else "0000000000000000" & instruction when rst ='1' or interrupt = '1'
        else std_logic_vector(unsigned(pcOut));

    dataout <= instruction when (stall = '0' and interrupt = '0') 
        else "1100000000000000" when interrupt = '0' and stall = '1'
        else "1110010000000000" when interrupt = '1' and stall = '0'
        else "1100000000000000" when interrupt = '1' and stall = '1' -- alah 23lm el prio lel stall wala interrupt (7atet nop)
        else "1100000000000000"; 

    pcPlus <= std_logic_vector(unsigned(pcOut) + 1);
END Fetch_Arch;
