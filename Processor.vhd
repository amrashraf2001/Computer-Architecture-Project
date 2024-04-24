LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY Processor IS
PORT(
    clk : IN std_logic;
    branchingAddress: IN std_logic_vector(n-1 downto 0);
    en,rst,interrupt,branchingSel, exceptionSel, stall : IN std_logic;
);
END Processor;

ARCHITECTURE Processor_Arch OF Processor IS
--FETCH
COMPONENT Fetch IS
    PORT (
        clk : IN std_logic;
        --branchingAddress: IN std_logic_vector(31 downto 0);
        en,rst : IN std_logic;
        --,interrupt,branchingSel, exceptionSel, stall : IN std_logic;
        --dataout: OUT std_logic_vector(15 DOWNTO 0);
        --pcPlus: OUT std_logic_vector(31 downto 0);
        --WrongAddress: OUT std_logic
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
        writeport1:in std_logic_vector(31 downto 0);
        writeport2:in std_logic_vector(31 downto 0);
        WriteAdd1: in  std_logic_vector (2 downto 0);
        WriteAdd2: in  std_logic_vector (2 downto 0);
        Flush: IN std_logic;
        Swaped: IN std_logic; -- gayaly mn el writeback stage
        ImmediateValue: IN std_logic_vector(15 DOWNTO 0);
        ReadData1:out std_logic_vector(31 downto 0);
        ReadData2:out std_logic_vector(31 downto 0);
        AluSelector: OUT std_logic_vector(3 DOWNTO 0); 
        Branching: OUT std_logic;
        alusource: OUT std_logic; -- ba4of ba5ud el second operand mn el register or immediate
        MWrite, MRead: OUT std_logic;
        WBdatasrc: OUT std_logic_vector(1 DOWNTO 0);
        RegWrite: OUT std_logic;
        SPPointer: OUT std_logic_vector(2 DOWNTO 0);
        interruptsignal:  out std_logic;
        pcSource: OUT std_logic;
        rtisignal:  out std_logic;
        FreeProtectStore: OUT std_logic_vector(1 DOWNTO 0);
        swap: out std_logic           -- ana batal3ha lama bala2i el instruction swap w bazabet el address w el data
    );
END COMPONENT;

--DECODE -> EXECUTE BUFFER
COMPONENT DecodeExecute_Reg is
port (
    A: IN std_logic_vector(149 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(149 downto 0));
END COMPONENT;

-- EXECUTE
COMPONENT Execute is
    Port ( 
        clk : in STD_LOGIC;
        en,rst : IN std_logic;
        Reg1, Reg2 : IN std_logic_vector(31 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        ALUout : OUT std_logic_vector(31 downto 0);
        FlagReg_out : OUT std_logic_vector(3 downto 0)
    );
end COMPONENT;

-- EXECUTE -> MEMORY BUFFER
COMPONENT ExecuteMemory_Reg is
port (
    A: IN std_logic_vector(150 downto 0); 
    clk,en,rest: in std_logic ; 
    F: out STD_LOGIC_VECTOR(150 downto 0));

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
        MemoryWriteData : IN std_logic_vector(31 DOWNTO 0);
        CALL_STD: IN std_logic;
        ALUOut : IN std_logic_vector(31 DOWNTO 0);
        pcPlus: IN std_logic_vector(31 DOWNTO 0);
        SecondOperand : IN std_logic_vector(31 DOWNTO 0);
        SP: IN std_logic_vector(2 DOWNTO 0);
        FreeProtectedStore : IN std_logic_vector(1 DOWNTO 0);
        MemoryOut : OUT std_logic_vector(31 DOWNTO 0);
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
        ALUout : IN STD_LOGIC_VECTOR(31 downto 0);
        data_in : IN STD_LOGIC_VECTOR(31 downto 0); -- Input port
        MemoryOut : IN STD_LOGIC_VECTOR(31 downto 0);
        WriteBackSource : IN STD_LOGIC_VECTOR(1 downto 0);
        Mux_result : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end COMPONENT;
BEGIN
--FD INPUT SIGNALS
SIGNAL InPort_FDIN : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL Instruction_FDIN: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL PCPlus_FDIN: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL WrongAddress_FDIN: STD_LOGIC;
SIGNAL BranchSel, ExceptionSel, Stall,Interrupt: STD_LOGIC;
SIGNAL BranchingAddress_FIN: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL FDIN: STD_LOGIC_VECTOR(80 downto 0);
--FETCH PORT MAP
-- 3ayez azabar el branching address ama 23ml ba2i el port maps
--
Fetch1:Fetch PORT MAP (
    clk=>clk,
    branchingAddress=>BranchingAddress_FIN,
    en=>en,
    rst=>rst,
    interrupt=>Interrupt,
    branchingSel=>BranchSel,
    exceptionSel=>ExceptionSel,
    stall=>Stall,
    dataout=>Instruction_FDIN,
    pcPlus=>PCPlus_FDIN,
    WrongAddress=>WrongAddress_FDIN
    );

--FD BUFFER PORT MAP
FDIN<=InPort_FDIN & Instruction_FDIN & PCPlus_FDIN;
SIGNAL FDOUT: STD_LOGIC_VECTOR(80 downto 0);
SIGNAL FLUSH: STD_LOGIC;
FetchDecode_Reg1:FetchDecode_Reg PORT MAP (
    A=>FDIN,
    clk=>clk,
    en=>en,
    rest=>FLUSH,
    F=>FDOUT
    );
    SIGNAL writeBackEnable_DIN, PredictorEnable_DIN: STD_LOGIC;
    SIGNAL WritePort1_DIN, WritePort2_DIN: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL WriteAdd1_DIN, WriteAdd2_DIN: STD_LOGIC_VECTOR(2 downto 0);
    SIGNAL SwapedFromWriteBackToDecode: STD_LOGIC;
    SIGNAL ImmediateValue_DIN: STD_LOGIC_VECTOR(15 downto 0);
    SIGNAL ReadData1_DOUT, ReadData2_DOUT: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL ALUSelector_DOUT: STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL Branching_DOUT : STD_LOGIC;
    SIGNAL ALUSource_DOUT :STD_LOGIC;
    SIGNAL 
Decode1: Decode PORT MAP (
    Clk=>clk,
    Rst=>rst,
    writeBackEnable=>writeBackEnable_DIN,
    PredictorEnable=>PredictorEnable_DIN,
    Instruction=>FDOUT(48 downto 33),
    writeport1=>WritePort1_DIN,
    writeport2=>WritePort2_DIN,
    WriteAdd1=>WriteAdd1_DIN,
    WriteAdd2=>WriteAdd2_DIN,
    Flush=>FLUSH,
    Swaped=>SwapedFromWriteBackToDecode,
    ImmediateValue=>ImmediateValue_DIN,
    ReadData1=>ReadData1_DOUT,
    ReadData2=>ReadData2_DOUT,
    AluSelector=>AluSelector,
    Branching=>Branching,
    alusource=>AluSource,
    MWrite=>MWrite,
    MRead=>MRead,
    WBdatasrc=>WBdatasrc,
    RegWrite=>RegWrite,
    SPPointer=>SPPointer,
    interruptsignal=>InterruptSignal,
    pcSource=>PCSource,
    rtisignal=>RTISignal,
    FreeProtectStore=>FreeProtectStore,
    swap=>Swap
    );

END Processor_Arch;