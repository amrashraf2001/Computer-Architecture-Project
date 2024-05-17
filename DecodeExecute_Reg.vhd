library ieee;
use ieee.std_logic_1164.all;

entity DecodeExecute_Reg is
port (
    A: IN std_logic_vector(195 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(195 downto 0));
end entity DecodeExecute_Reg;
-- opcode 6 bit (195 downto 190)
-- RET 2 bit (189 downto 188)
-- swap 1 bit (187)
-- ALU src 1 bit (186)
-- Immediate value (32 bit) → 32 Bit (185 downto 154)
-- Mem Address → 3 Bit (153 downto 151)
--F/P/S → 2 Bit (150 downto 149)
--ALU Operation → 4 Bit(148 downto 145)
--SP → 3 Bit(144 downto 142)
--OUT Enable → 1 Bit(141)
--Write Back Source → 2 Bit(140 downto 139)
--MR-MW-RW → 3 Bit(138 downto 136)
--CALL/int/STD → 2 Bit(135 downto 134)
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
			F<= (148=>'1',147=>'1',146=>'1',145=>'0',others => '0'); -- lw 3mlt reset aw ha flush odam adman eni 7atet NOP
		elsif rising_edge(clk) and en='1' then 
			F<=A;
		end if;
	end process;
end DecodeExecute_Reg;