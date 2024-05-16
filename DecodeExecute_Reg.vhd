library ieee;
use ieee.std_logic_1164.all;

entity DecodeExecute_Reg is
port (
    A: IN std_logic_vector(194 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(194 downto 0));
end entity DecodeExecute_Reg;
-- opcode 6 bit (194 downto 189)
-- RET 2 bit (188 downto 187)
-- swap 1 bit (186)
-- ALU src 1 bit (185)
-- Immediate value (32 bit) → 32 Bit (184 downto 153)
-- Mem Address → 3 Bit (152 downto 150)
--F/P/S → 2 Bit (149 downto 148)
--ALU Operation → 4 Bit(147 downto 144)
--SP → 3 Bit(143 downto 141)
--OUT Enable → 1 Bit(140)
--Write Back Source → 2 Bit(139 downto 138)
--MR-MW-RW → 3 Bit(137 downto 135)
--CALL/STD → 1 Bit(134)
--Register 1 Value → 32 Bit(133 downto 102)
--Second Operand → 32 Bit(101 downto 70)
--IN Port → 32 Bit(69 downto 38)
--Write Back Addresses → 6 Bit(37 downto 32)
--PC + 1 → 32 Bit(31 downto 0)




Architecture DecodeExecute_Reg of DecodeExecute_Reg is
begin
	process (clk,rest)
	begin
		if rest = '1' then 
			F<= (147=>'1',146=>'1',145=>'1',144=>'0',others => '0'); -- lw 3mlt reset aw ha flush odam adman eni 7atet NOP
		elsif rising_edge(clk) and en='1' then 
			F<=A;
		end if;
	end process;
end DecodeExecute_Reg;