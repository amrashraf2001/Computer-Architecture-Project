library ieee;
use ieee.std_logic_1164.all;

entity MemoryWriteBack_Reg is
port (
    A: IN std_logic_vector(169 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(169 downto 0));

end entity MemoryWriteBack_Reg;
-- RET 2 bits (172 downto 171)
-- swap 1 bit (170)
--RWrtie signal -> 1 Bit (169)
--Write Back Source signal → 2 Bit (168 downto 167)
--OUT Enable signal → 1 Bit (166)
--Memory Output → 32 Bit (165 downto 134)
--ALU Output → 32 Bit (133 downto 102)
--Second Operand → 32 Bit (101 downto 70)
--Write Back Addresses → 6 Bit (69 downto 64)
--IN -> 32 Bit (63 downto 32)
--PC + 1 → 32 Bit (31 downto 0)

Architecture MemoryWriteBack_Reg of MemoryWriteBack_Reg is
begin
	process (clk,rest)
	begin
		if rest = '1' then 
			F<= (others => '0'); -- lw 3mlt reset aw ha flush odam adman eni 7atet NOP
		elsif rising_edge(clk) and en='1' then 
			F<=A;
		end if;
	end process;
end MemoryWriteBack_Reg;