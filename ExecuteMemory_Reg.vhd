library ieee;
use ieee.std_logic_1164.all;

entity ExecuteMemory_Reg is
port (
    A: IN std_logic_vector(150 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(150 downto 0));

end entity ExecuteMemory_Reg;
-- Flag value -> 4 bit (150 downto 147)
-- PC + 1 → 32 Bit (146 downto 115)
-- IN Port → 32 Bit (114 downto 83)
-- Write Back Addresses → 6 Bit (82 downto 77)
-- ALU Output → 32 Bit (76 downto 45)
-- Second Operand → 32 Bit (44 downto 13)
-- CALL/STD → 1 Bit (12)
-- OUT Enable → 1 Bit (11)
-- MR-MW-RW → 3 Bit (10 downto 8)
-- ALU_src → 1 Bit (7)
-- SP → 3 Bit (6 downto 4)
-- Write Back Source → 2 Bit (3 downto 2)
-- F/P/S → 2 Bit (1 downto 0)


Architecture ExecuteMemory_Reg of ExecuteMemory_Reg is
begin
	process (clk,rest)
	begin
		if rest = '1' then 
			F<= (others => '0'); -- lw 3mlt reset aw ha flush odam adman eni 7atet NOP
		elsif rising_edge(clk) and en='1' then 
			F<=A;
		end if;
	end process;
end ExecuteMemory_Reg;