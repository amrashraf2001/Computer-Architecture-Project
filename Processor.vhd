LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY Processor IS
GENERIC(n : integer :=32);
PORT(
    clk : IN std_logic;
    en,rst : IN std_logic;
    InPort : IN std_logic_vector(31 downto 0);
    OutPort : OUT std_logic_vector(31 downto 0)
);
END Processor;

ARCHITECTURE Processor_Arch OF Processor IS
--FETCH
COMPONENT Fetch IS
    PORT (
        clk : IN std_logic;
        branchingAddress: IN std_logic_vector(31 downto 0);
        en,rst,interrupt,branchingSel, exceptionSel, stall : IN std_logic;
        dataout: OUT std_logic_vector(15 DOWNTO 0);
        pcPlus: OUT std_logic_vector(31 downto 0);
        WrongAddress: OUT std_logic
    );
END COMPONENT;

-- FETCH -> DECODE BUFFER
COMPONENT FetchDecode_Reg is
port (
    A: IN std_logic_vector(80 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out std_logic_vector(80 downto 0));

end COMPONENT;

--DECODE
COMPONENT Decode IS
PORT(  
    Clk,Rst,writeBackEnable,PredictorEnable:in std_logic;
    Instruction: IN std_logic_vector(15 DOWNTO 0); 
    writeport1:in std_logic_vector(n-1 downto 0);
    writeport2:in std_logic_vector(n-1 downto 0);
    WriteAdd1: in  std_logic_vector (2 downto 0);
    WriteAdd2: in  std_logic_vector (2 downto 0);
    Flush: IN std_logic;
    Swaped: IN std_logic; -- gayaly mn el writeback stage
    ImmediateValue: IN std_logic_vector(15 DOWNTO 0);
    ReadData1:out std_logic_vector(n-1 downto 0);
    ReadData2:out std_logic_vector(n-1 downto 0);
    AluSelector: OUT std_logic_vector(3 DOWNTO 0); 
    Branching: OUT std_logic;
    alusource: OUT std_logic; -- ba4of ba5ud el second operand mn el register or immediate
    MWrite1,MWrite2, MRead: OUT std_logic;
    WBdatasrc: OUT std_logic_vector(1 DOWNTO 0);
    RegWrite: OUT std_logic;
    SPPointer: OUT std_logic_vector(2 DOWNTO 0);
    interruptsignal:  out std_logic;
    pcSource: OUT std_logic;
    rtisignal:  out std_logic;
    FreeProtectStore: OUT std_logic_vector(1 DOWNTO 0);
    swap: out std_logic; -- ana batal3ha lama bala2i el instruction swap w bazabet el address w el data
    MemAddress: OUT std_logic_vector(1 DOWNTO 0)
);
END COMPONENT;

--DECODE -> EXECUTE BUFFER
COMPONENT DecodeExecute_Reg is
    port (
        A: IN std_logic_vector(185 downto 0); 
        clk,en,rest: in std_logic ; 
        F: out STD_LOGIC_VECTOR(185 downto 0));
END COMPONENT;

-- EXECUTE
COMPONENT Execute is
    Port ( 
        clk : in STD_LOGIC;
        en,rst : IN std_logic;
        Reg1, Reg2 : IN std_logic_vector(n-1 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        ALUout : OUT std_logic_vector(n-1 downto 0);
        FlagReg_out : OUT std_logic_vector(3 downto 0)
    );
end COMPONENT;

-- EXECUTE -> MEMORY BUFFER
COMPONENT ExecuteMemory_Reg is
    port (
        A: IN std_logic_vector(153 downto 0); 
        clk,en,rest: in std_logic ; 
        F: out STD_LOGIC_VECTOR(153 downto 0));

end COMPONENT;

COMPONENT Memory is
    port (
        clk : in std_logic;
        en,rst : IN std_logic;
        MemoryWrite1 : IN std_logic;
        MemoryWrite2 : IN std_logic;
        MemoryRead : IN std_logic;
        MemoryEnable : IN std_logic;
        MemoryAddress : IN std_logic_vector(1 DOWNTO 0);
        MemoryWriteData : IN std_logic_vector(n-1 DOWNTO 0);
        CALL_STD: IN std_logic;
        ALUOut : IN std_logic_vector(n-1 DOWNTO 0);
        pcPlus: IN std_logic_vector(n-1 DOWNTO 0);
        SecondOperand : IN std_logic_vector(n-1 DOWNTO 0);
        SP: IN std_logic_vector(2 DOWNTO 0);
        FreeProtectedStore : IN std_logic_vector(1 DOWNTO 0);
        MemoryOut : OUT std_logic_vector(n-1 DOWNTO 0);
        WrongAddress : OUT std_logic        
    );
end COMPONENT;

-- MEMORY -> WRITEBACK BUFFER
COMPONENT MemoryWriteBack_Reg is
    port (
        A: IN std_logic_vector(169 downto 0); 
        clk,en,rest: in std_logic ; 
        F: out STD_LOGIC_VECTOR(169 downto 0));
end COMPONENT;

--WRITEBACK
COMPONENT WriteBack is
    Port ( 
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ALUout : IN STD_LOGIC_VECTOR(n-1 downto 0);
        data_in : IN STD_LOGIC_VECTOR(n-1 downto 0); -- Input port
        MemoryOut : IN STD_LOGIC_VECTOR(n-1 downto 0);
        WriteBackSource : IN STD_LOGIC_VECTOR(1 downto 0);
        Mux_result : OUT STD_LOGIC_VECTOR(n-1 downto 0)

    );
end COMPONENT;
--FD INPUT SIGNALS

SIGNAL PCPlus_FDIN: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL WrongAddress_FDIN: STD_LOGIC;
SIGNAL BranchSel, ExceptionSel, Stall,Interrupt: STD_LOGIC;
SIGNAL BranchingAddress_FIN: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL Instruction_FDIN: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL Flush: STD_LOGIC:='0';
SIGNAL FDIN: STD_LOGIC_VECTOR(80 downto 0);
SIGNAL FDOUT: STD_LOGIC_VECTOR(80 downto 0);
SIGNAL Inport_FDIN: STD_LOGIC_VECTOR(31 downto 0);
-- DECODE INPUT SIGNALS
SIGNAL WriteBackEnable_DIN, PredictorEnable_DIN: STD_LOGIC; -- mn el write back
SIGNAL WritePort1_DIN, WritePort2_DIN: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL WriteAdd1_DIN, WriteAdd2_DIN: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL Flush_DIN,Swaped_DIN: STD_LOGIC;
SIGNAL ImmediateValue_DIN: STD_LOGIC_VECTOR(31 downto 0); -- mn el fetch eli ablya m4 el buffer
SIGNAL ReadData1_DOUT, ReadData2_DOUT: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL AluSelector_DOUT: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL Branching_DOUT: STD_LOGIC;
SIGNAL AluSource_DOUT: STD_LOGIC;
SIGNAL MWrite1_DOUT, MWrite2_DOUT, MRead_DOUT: STD_LOGIC;
SIGNAL WBDataSrc_DOUT: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL RegWrite_DOUT: STD_LOGIC;
SIGNAL SPPointer_DOUT: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL InterruptSignal_DOUT: STD_LOGIC;
SIGNAL PcSource_DOUT: STD_LOGIC;
SIGNAL RtiSignal_DOUT: STD_LOGIC;
SIGNAL FreeProtectedStore_DOUT: STD_LOGIC_VECTOR(1 downto 0);
SIGNAL Swap_DOUT: STD_LOGIC;
SIGNAL MemAddress_DOUT: STD_LOGIC_VECTOR(1 downto 0);
--DECODE -> EXECUTE BUFFER
SIGNAL DOUT: STD_LOGIC_VECTOR(185 downto 0);
--DecodeExecute_Reg PORT MAP
SIGNAL DEOUT: STD_LOGIC_VECTOR(185 downto 0);
-- EXECUTE INPUT SIGNALS
SIGNAL Reg1_EIN, Reg2_EIN: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL ALU_selector_EIN: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL ALUout_EOUT: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL FlagReg_out_EOUT: STD_LOGIC_VECTOR(3 downto 0);
-- ExecuteMemory_Reg PORT MAP
SIGNAL EOUT: STD_LOGIC_VECTOR(153 downto 0);
SIGNAL EMOUT: STD_LOGIC_VECTOR(153 downto 0);
-- MEMORY INPUT SIGNALS
SIGNAL MemoryWrite1_MIN, MemoryWrite2_MIN, MemoryRead_MIN, MemoryEnable_MIN: STD_LOGIC;
SIGNAL MemoryAddress_MIN :STD_LOGIC_VECTOR(1 downto 0); 
SIGNAL MemoryWriteData_MIN: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL CALL_STD_MIN: STD_LOGIC;
SIGNAL ALUOut_MIN: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL pcPlus_MIN: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL SecondOperand_MIN : STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL SP_MIN: STD_LOGIC_VECTOR(2 downto 0);
SIGNAL FreeProtectedStore_MIN: STD_LOGIC_VECTOR(1 downto 0);
--MemorywriteBack_Reg PORT MAP
SIGNAL MWIN: STD_LOGIC_VECTOR(169 downto 0);
SIGNAL MWOUT: STD_LOGIC_VECTOR(169 downto 0);
SIGNAL MemoryOut_MOut: STD_LOGIC_VECTOR(n-1 downto 0);
SIGNAL WrongAddress_MOut: STD_LOGIC;
-- WRITEBACK INPUT SIGNALS
SIGNAL WriteBackDataOut: STD_LOGIC_VECTOR(31 downto 0);

BEGIN

--FETCH PORT MAP
Fetch1: Fetch PORT MAP(
    clk => clk,
    branchingAddress => (OTHERS=>'0'),
    en => en,
    rst => rst,
    interrupt => '0',
    branchingSel => '0',
    exceptionSel => '0',
    stall => '0',
    dataout => Instruction_FDIN,
    pcPlus => PCPlus_FDIN,
    WrongAddress => WrongAddress_FDIN
); 

Inport_FDIN<=InPort;
FDIN<=InPort_FDIN & Instruction_FDIN & PCPlus_FDIN & WrongAddress_FDIN;
--ImmediateValue_DIN <= Instruction_FDIN(15 downto 0) & (OTHERS=>'0');
process(Instruction_FDIN)
    begin
        for i in 31 downto 16 loop
          ImmediateValue_DIN(i) <= Instruction_FDIN(15);
        end loop;
        ImmediateValue_DIN(15 downto 0) <= Instruction_FDIN(15 downto 0);
    end process;
-- FetchDecode_Reg PORT MAP
FetchDecode_Reg1: FetchDecode_Reg PORT MAP(
    A => FDIN,
    clk => clk,
    en => en,
    rest => rst,
    F => FDOUT
);

-- Decode PORT MAP
Decode1: Decode PORT MAP(
    Clk => clk,
    Rst => rst,
    WriteBackEnable => MWOUT(169),
    PredictorEnable => '0',
    Instruction => FDOUT(48 downto 33),
    WritePort1 => WriteBackDataOut, -- l7ad mawsal lel write back
    WritePort2 => WritePort2_DIN,
    WriteAdd1 => MWOUT(69 downto 67),
    WriteAdd2 => MWOUT(66 downto 64),
    Flush => '0',
    Swaped => Swaped_DIN,
    ImmediateValue => Instruction_FDIN(15 downto 0),
    ReadData1 => ReadData1_DOUT,
    ReadData2 => ReadData2_DOUT,
    AluSelector => AluSelector_DOUT,
    Branching => Branching_DOUT,
    AluSource => AluSource_DOUT,
    MWrite1 => MWrite1_DOUT,
    MWrite2 => MWrite2_DOUT,
    MRead => MRead_DOUT,
    WBDataSrc => WBDataSrc_DOUT,
    RegWrite => RegWrite_DOUT,
    SPPointer => SPPointer_DOUT,
    InterruptSignal => InterruptSignal_DOUT,
    PcSource => PcSource_DOUT,
    RtiSignal => RtiSignal_DOUT,
    FreeProtectStore => FreeProtectedStore_MIN,
    Swap => Swap_DOUT,
    MemAddress => MemAddress_DOUT
);
WriteAdd1_DIN <= FDOUT(42 downto 40);

DOUT<= AluSource_DOUT & ImmediateValue_DIN & MemAddress_DOUT & FreeProtectedStore_DOUT & AluSelector_DOUT & SPPointer_DOUT & '1' & WBDataSrc_DOUT & MRead_DOUT & Mwrite1_DOUT & MWrite2_DOUT & RegWrite_DOUT & '0' & ReadData1_DOUT & ReadData2_DOUT & FDOUT(80 downto 49) & WriteAdd1_DIN & WriteAdd2_DIN & FDOUT(32 downto 1);

DecodeExecute_Reg1: DecodeExecute_Reg PORT MAP(
    A => DOUT,
    clk => clk,
    en => en,
    rest => rst,
    F => DEOUT
);


Reg1_EIN <= DEOUT(133 downto 102);
Reg2_EIN <= DEOUT(101 downto 70) when DEOUT(185)='0' else DEOUT(184 downto 153);
ALU_selector_EIN <= DEOUT(148 downto 145);
-- Execute PORT MAP
Execute1: Execute PORT MAP(
    clk => clk,
    en => en,
    rst => rst,
    Reg1 => Reg1_EIN,
    Reg2 => Reg2_EIN,
    ALU_selector => ALU_selector_EIN,
    ALUout => ALUout_EOUT,
    FlagReg_out => FlagReg_out_EOUT
);

EOUT<= DEOUT(152 downto 151) & FlagReg_out_EOUT & DEOUT(31 downto 0) & DEOUT(69 downto 38) & DEOUT(37 downto 32) & ALUout_EOUT & Reg2_EIN & '0' & '1' & DEOUT(138 downto 135) & DEOUT(185) & DEOUT(144 downto 142) & DEOUT(140 downto 139) & DEOUT(150 downto 149);
ExecuteMemory_Reg1: ExecuteMemory_Reg PORT MAP(
    A => EOUT,
    clk => clk,
    en => en,
    rest => rst,
    F => EMOUT
);


MemoryRead_MIN <= EMOUT(11);
MemoryWrite1_MIN <= EMOUT(10);
MemoryWrite2_MIN <= EMOUT(9);
MemoryEnable_MIN <= EMOUT(8);
MemoryAddress_MIN <= EMOUT(153 downto 152);
MemoryWriteData_MIN <= EMOUT(45 downto 14) when EMOUT(13)='0' 
else EMOUT(147 downto 116);
CALL_STD_MIN <= EMOUT(13);
ALUOut_MIN <= EMOUT(77 downto 46);
pcPlus_MIN <= EMOUT(147 downto 116);
SecondOperand_MIN <= EMOUT(45 downto 14);
SP_MIN <= EMOUT(6 downto 4);
FreeProtectedStore_MIN <= EMOUT(1 downto 0);



-- Memory PORT MAP
Memory1: Memory PORT MAP(
    clk => clk,
    en => en,
    rst => rst,
    MemoryWrite1 => MemoryWrite1_MIN,
    MemoryWrite2 => MemoryWrite2_MIN,
    MemoryRead => MemoryRead_MIN,
    MemoryEnable => MemoryEnable_MIN,
    MemoryAddress => MemoryAddress_MIN,
    MemoryWriteData => MemoryWriteData_MIN,
    CALL_STD => CALL_STD_MIN,
    ALUOut => ALUOut_MIN,
    pcPlus => pcPlus_MIN,
    SecondOperand => SecondOperand_MIN,
    SP => SP_MIN,
    FreeProtectedStore => FreeProtectedStore_MIN,
    MemoryOut => MemoryOut_MOut,
    WrongAddress => WrongAddress_MOut
);


MWIN <= EMOUT(8) & EMOUT(3 downto 2) & EMOUT(12) & MemoryOut_MOut & EMOUT(77 downto 46) & EMOUT(45 downto 14) & EMOUT(83 downto 78) & EMOUT(115 downto 84) & EMOUT(147 downto 116);

MemoryWriteBack_Reg1: MemoryWriteBack_Reg PORT MAP(
    A => MWIN,
    clk => clk,
    en => en,
    rest => rst,
    F => MWOUT
);

-- WRITEBACK PORT MAP
WriteBack1: WriteBack PORT MAP(
    clk => clk,
    reset => rst,
    ALUout => MWOUT(133 downto 102),
    data_in => MWOUT(63 downto 32),
    MemoryOut => MWOUT(165 downto 134),
    WriteBackSource => MWOUT(168 downto 167),
    Mux_result => WriteBackDataOut
);





END Processor_Arch;