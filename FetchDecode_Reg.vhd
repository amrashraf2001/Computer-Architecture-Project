library ieee;
use ieee.std_logic_1164.all;

entity FetchDecode_Reg is
port (
    A: IN std_logic_vector(80 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out std_logic_vector(80 downto 0);
	Flush: in std_logic);

end entity FetchDecode_Reg;

-- in port -> 32 bit (80 downto 49)
-- instruction -> 16 bit  (48 downto 33)
-- pcPlus -> 32 bit (32 downto 1)
-- exception -> 1 bit (0)

Architecture FetchDecode_Reg of FetchDecode_Reg is
begin
	process (clk,rest,Flush)
	begin
		if rest = '1' or Flush = '1' then 
			F<=(48=>'1',47=>'1',others=>'0'); -- lw 3mlt reset aw ha flush odam adman eni 7atet NOP
		elsif rising_edge(clk) and en='1' then 
			F<=A;
		end if;
	end process;
end FetchDecode_Reg;