LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY Processor IS
PORT(
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out_valid : OUT STD_LOGIC;
    data_out_ready : IN STD_LOGIC;
    data_in_valid : IN STD_LOGIC;
    data_in_ready : OUT STD_LOGIC
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
--Fetch1: Fetch PORT MAP(clk,branchingAddress,en,rst,interrupt,branchingSel, exceptionSel, stall,dataout,pcPlus,WrongAddress);
END Processor_Arch;