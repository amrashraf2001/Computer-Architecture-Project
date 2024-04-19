library ieee;
use ieee.std_logic_1164.all;

entity FetchDecode_Reg is
port (
    A: IN std_logic_vector(96 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out std_logic_vector(96 downto 0));

end entity FetchDecode_Reg;

-- in port -> 32 bit (96 downto 65)
-- instruction -> 16 bit  (64 downto 49)
-- immediate -> ha7ot nafs el instruction tani hna, law galy isImmediate b one 16 bit (48 downto 33)
-- pcPlus -> 32 bit (32 downto 1)
-- isImmediate -> 1 bit (0)

Architecture FetchDecode_Reg of FetchDecode_Reg is
begin
	process (clk,rest)
	begin
		if rest = '1' then 
			F<=(64=>'1',63=>'1',others=>'0'); -- lw 3mlt reset aw ha flush odam adman eni 7atet NOP
		elsif rising_edge(clk) and en='1' then 
			F<=A;
		end if;
	end process;
end FetchDecode_Reg;