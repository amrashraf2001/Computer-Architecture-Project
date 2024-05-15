library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ForwardingUnit is
    port (
        clk : in std_logic;
        rst : in std_logic;
        swap: in std_logic;
        WBenable_EX_MEM , WBenable_MEM_WB : in std_logic;
        WBsource_EX_MEM : in std_logic_vector(1 downto 0);  -- for load use case
        DestREG_EX_MEM , DestREG_MEM_WB : in std_logic_vector(2 downto 0);
        Src1_From_ID_EX , Src2_From_ID_EX : in std_logic_vector(2 downto 0);
        Selector_Mux1 , Selector_Mux2 : out std_logic_vector (1 downto 0);
        stall : out std_logic
    );
end entity ForwardingUnit;

architecture FU_arch of ForwardingUnit is
    signal Src1_signal, Src2_signal : std_logic_vector(2 downto 0);
begin
    --process (clk)
    --begin
    --    if rising_edge(clk) then
            Src1_signal <= Src1_From_ID_EX when swap = '0' else Src2_From_ID_EX;
            Src2_signal <= Src2_From_ID_EX when swap = '0' else Src1_From_ID_EX;    
    --    end if;

    Selector_Mux1 <= "00" when (DestREG_EX_MEM = Src1_signal) and (WBenable_EX_MEM = '1') and (WBenable_MEM_WB /= '1') and (WBsource_EX_MEM /= "01") else --forward from EX_MEM
                     "01" when (DestREG_MEM_WB = Src1_signal) and (WBenable_MEM_WB = '1') and (WBenable_EX_MEM /= '1') and (WBsource_EX_MEM /= "01") else --forward from MEM_WB
                     "10" when (DestREG_EX_MEM = Src1_signal) and (WBenable_EX_MEM = '1') and (WBenable_MEM_WB = '1') and (WBsource_EX_MEM /= "01") else --forward from EX_MEM brdo (mashro7a fl note eli gamb el FU)
                     "11"; --no forwarding

    Selector_Mux2 <= "00" when (DestREG_EX_MEM = Src2_signal) and (WBenable_EX_MEM = '1') and (WBenable_MEM_WB /= '1') and (WBsource_EX_MEM /= "01") else --forward from EX_MEM
                     "01" when (DestREG_MEM_WB = Src2_signal) and (WBenable_MEM_WB = '1') and (WBenable_EX_MEM /= '1') and (WBsource_EX_MEM /= "01") else --forward from MEM_WB
                     "10" when (DestREG_EX_MEM = Src2_signal) and (WBenable_EX_MEM = '1') and (WBenable_MEM_WB = '1') and (WBsource_EX_MEM /= "01") else --forward from EX_MEM brdo
                     "11"; --no forwarding

    stall <= '1' when (WBsource_EX_MEM = "01" and  WBenable_EX_MEM = '1' and (Src1_signal = DestREG_EX_MEM or Src2_signal = DestREG_EX_MEM)) else '0';
    --end process;



end architecture FU_arch;