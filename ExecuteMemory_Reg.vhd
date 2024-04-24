library ieee;
use ieee.std_logic_1164.all;

entity ExecuteMemory_Reg is
port (
    A: IN std_logic_vector(153 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(153 downto 0));

end entity ExecuteMemory_Reg;
-- Mem Address → 2 Bit (153 downto 152)
-- Flag value -> 4 bit (151 downto 148)
-- PC + 1 → 32 Bit (147 downto 116)
-- IN Port → 32 Bit (115 downto 84)
-- Write Back Addresses → 6 Bit (83 downto 78)
-- ALU Output → 32 Bit (77 downto 46)
-- Second Operand → 32 Bit (45 downto 14)
-- CALL/STD → 1 Bit (13)
-- OUT Enable → 1 Bit (12)
-- MR-MW1-MW2-RW → 4 Bit (11 downto 8)
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