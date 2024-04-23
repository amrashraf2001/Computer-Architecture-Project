library ieee;
use ieee.std_logic_1164.all;

entity ExecuteMemory_Reg is
port (
    A: IN std_logic_vector(146 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(146 downto 0));

end entity ExecuteMemory_Reg;

-- PC + 1 → 32 Bit (115 → 146)
-- IN Port → 32 Bit (83 → 114)
-- Write Back Addresses → 6 Bit (77 → 82)
-- ALU Output → 32 Bit (45 → 76)
-- Second Operand → 32 Bit (13 → 44)
-- CALL/STD → 1 Bit (12)
-- OUT Enable → 1 Bit (11)
-- MR-MW-RW → 3 Bit (8 → 10)
-- ALU_src → 1 Bit (7)
-- SP → 3 Bit (4 → 6)
-- Write Back Source → 2 Bit (2 → 3)
-- F/P/S → 2 Bit (0 → 1)


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