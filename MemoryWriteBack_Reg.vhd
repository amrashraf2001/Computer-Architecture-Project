library ieee;
use ieee.std_logic_1164.all;

entity MemoryWriteBack_Reg is
port (
    A: IN std_logic_vector(169 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(169 downto 0));

end entity MemoryWriteBack_Reg;

--Read Wrtie signal -> 1 Bit (169)
--Write Back Source signal → 2 Bit (167->168)
--OUT Enable signal → 1 Bit (166)
--Memory Output → 32 Bit (134->165)
--ALU Output → 32 Bit (102->133)
--Second Operand → 32 Bit (70->101)
--Write Back Addresses → 6 Bit (64->69)
--IN -> 32 Bit (32->63)
--PC + 1 → 32 Bit (0->31)

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