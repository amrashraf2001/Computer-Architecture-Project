LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY ProccessorFinal IS
GENERIC (N : INTEGER := 32);
PORT (
    clk : IN STD_LOGIC;
    en,rst : IN STD_LOGIC;
    InPort : IN std_logic_vector(31 downto 0);
    OutPort : OUT std_logic_vector(31 downto 0)
);
END ProccessorFinal;

ARCHITECTURE ProccessorFinal_Arch OF ProccessorFinal IS

--------------------------FETCH--------------------------
COMPONENT Fetch IS
GENERIC(n : integer :=32);
    PORT (
        clk : IN std_logic;
        branchingAddress: IN std_logic_vector(n-1 downto 0);
        en,rst,interrupt,branchingSel, exceptionSel, stall : IN std_logic;
        dataout: OUT std_logic_vector(15 DOWNTO 0);
        pcPlus: OUT std_logic_vector(n-1 downto 0);
        WrongAddress: OUT std_logic
    );
END COMPONENT ;

--------------------------DECODE--------------------------
COMPONENT Decode IS
    GENERIC(n : integer :=32);
    PORT(  
        Clk,Rst,writeBackEnable,PredictorEnable:in std_logic;
        Instruction: IN std_logic_vector(15 DOWNTO 0); 
        writeport1:in std_logic_vector(n-1 downto 0);
        writeport2:in std_logic_vector(n-1 downto 0);
        WriteAdd1: in  std_logic_vector (2 downto 0);
        WriteAdd2: in  std_logic_vector (2 downto 0);
        Flush: IN std_logic; -- selket el flush eli tal3a mn el execute stage
        Swaped: IN std_logic; -- gayaly mn el writeback stage
        ImmediateValue: IN std_logic_vector(15 DOWNTO 0);
        ReadData1:out std_logic_vector(n-1 downto 0);
        ReadData2:out std_logic_vector(n-1 downto 0);
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
        Swap: out std_logic; -- ana batal3ha lama bala2i el instruction Swap w bazabet el address w el data
        MemAddress: OUT std_logic_vector(2 DOWNTO 0);
        Ret: out std_logic_vector(1 downto 0);
        CallIntStore: OUT std_logic_vector(1 DOWNTO 0);
        FlushOut: OUT std_logic;
        OutEnable: OUT std_logic
    );
END COMPONENT;

--------------------------EXECUTE--------------------------
COMPONENT Execute is
    GENERIC(n : integer :=32);
    Port ( 
        clk : in STD_LOGIC;
        en,rst : IN std_logic;
        opcode : IN std_logic_vector(5 downto 0);
        Reg1, Reg2 : IN std_logic_vector(n-1 downto 0);
        Forwarded_Src_1_EX_MEM, Forwarded_Src_1_MEM_WB : IN std_logic_vector(n-1 downto 0);
        Forwarded_Src_2_EX_MEM, Forwarded_Src_2_MEM_WB : IN std_logic_vector(n-1 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        Destination_Reg_EX_MEM, Destination_Reg_MEM_WB: IN std_logic_vector(2 downto 0);
        Src1_From_ID_EX, Src2_From_ID_EX : IN std_logic_vector(2 downto 0);
        WBenable_EX_MEM, WBenable_MEM_WB : IN std_logic;
        WBsource_EX_MEM : IN std_logic_vector(1 downto 0);
        swap : IN std_logic;
        PredictorIn : IN std_logic; -- gayaly mn el decode stage
        ALUout : OUT std_logic_vector(n-1 downto 0);
        FlagReg_out : OUT std_logic_vector(3 downto 0);
        FlushOut : OUT std_logic;
        NotTakenWrongBranch : OUT std_logic; -- el and eli fo2 not taken w kan el mafroud a take it
        TakenWrongBranch : OUT std_logic -- el and eli ta7t taken w kan el mafroud a not take it
    );
end COMPONENT;

--------------------------MEMORY--------------------------

COMPONENT Memory IS
    GENERIC (n : INTEGER := 32);
    PORT (
        clk : IN std_logic;
        en, rst : IN std_logic;
        MemoryWrite : IN std_logic;
        MemoryRead : IN std_logic;
        MemoryEnable : IN std_logic;
        MemoryAddress : IN std_logic_vector(2 DOWNTO 0);
        CALLIntSTD : IN std_logic_vector(1 DOWNTO 0);
        RET : IN std_logic_vector(1 DOWNTO 0);
        ALUOut : IN std_logic_vector(n-1 DOWNTO 0);
        pcPlus : IN std_logic_vector(n-1 DOWNTO 0);
        SecondOperand : IN std_logic_vector(n-1 DOWNTO 0);
        SP : IN std_logic_vector(2 DOWNTO 0);
        FlagReg: IN std_logic_vector(3 DOWNTO 0); -- da5el mn el buffer 3ady
        FreeProtectedStore : IN std_logic_vector(1 DOWNTO 0);
        MemoryOut : OUT std_logic_vector(n-1 DOWNTO 0);
        WrongAddress : OUT std_logic;
        FlushAllBack : OUT std_logic;
        FlushINT_RTI: OUT std_logic;
        INTDetected: OUT std_logic;
        FlagRegOut: OUT std_logic_vector(3 DOWNTO 0) -- ha4edo lel execute f 7alet el RTI
    );
END COMPONENT;

--------------------------WRITEBACK--------------------------

COMPONENT WriteBack is
    GENERIC(n : integer :=32);
    Port ( 
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ALUout : IN STD_LOGIC_VECTOR(n-1 downto 0);
        data_in : IN STD_LOGIC_VECTOR(n-1 downto 0); -- Input port
        MemoryOut : IN STD_LOGIC_VECTOR(n-1 downto 0);
        WriteBackSource : IN STD_LOGIC_VECTOR(1 downto 0);
        -- OutPutPort : OUT STD_LOGIC_VECTOR(n-1 downto 0); -- Output port
        write_enable : in STD_LOGIC;
        WriteBackAddress1 : out STD_LOGIC_VECTOR(4 downto 0);
        WriteBackAddress2 : out STD_LOGIC_VECTOR(4 downto 0);
        Mux_result : OUT STD_LOGIC_VECTOR(n-1 downto 0);
        OutputPortEnable : OUT STD_LOGIC;-- Output port enable
        swap : out STD_LOGIC;
        second_operand : out STD_LOGIC_VECTOR(31 downto 0)

    );
end COMPONENT;

--------------------------PIPELINE-BUFFERS--------------------------
--------------------------FETCH-DECODE--------------------------
-- in port -> 32 bit (80 downto 49)
-- instruction -> 16 bit  (48 downto 33)
-- pcPlus -> 32 bit (32 downto 1)
-- exception -> 1 bit (0)

COMPONENT FetchDecode_Reg is
    port (
        A: IN std_logic_vector(80 downto 0); 
        clk,en,rst: in std_logic ; 
        F: out std_logic_vector(80 downto 0);
        Flush: in std_logic
        );
    
end COMPONENT;

--------------------------DECODE-EXECUTE--------------------------
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


COMPONENT DecodeExecute_Reg is
    port (
        A: IN std_logic_vector(195 downto 0); 
        clk,en,rst: in std_logic ; 
        F: out STD_LOGIC_VECTOR(195 downto 0));
end COMPONENT;
    
--------------------------EXECUTE-MEMORY--------------------------
-- RET 2 bits (157 downto 156)
-- swap 1 bit (155)
-- Mem Address → 3 Bit (154 downto 152)
-- Flag value -> 4 bit (151 downto 148)
-- PC + 1 → 32 Bit (147 downto 116)
-- IN Port → 32 Bit (115 downto 84)
-- Write Back Addresses → 6 Bit (83 downto 78)
-- ALU Output → 32 Bit (77 downto 46)
-- Second Operand → 32 Bit (45 downto 14)
-- CALL/int/STD → 2 Bit (13 downto 12) 
-- OUT Enable → 1 Bit (11)
-- MR-MW-RW → 3 Bit (10 downto 8)
-- ALU_src → 1 Bit (7)
-- SP → 3 Bit (6 downto 4)
-- Write Back Source → 2 Bit (3 downto 2)
-- F/P/S → 2 Bit (1 downto 0)

COMPONENT ExecuteMemory_Reg is
    port (
        A: IN std_logic_vector(157 downto 0); 
        clk,en,rst: in std_logic ; 
        F: out STD_LOGIC_VECTOR(157 downto 0));
    
end COMPONENT;

--------------------------MEMORY-WRITEBACK--------------------------
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

COMPONENT MemoryWriteBack_Reg is
    port (
        A: IN std_logic_vector(172 downto 0); 
        clk,en,rst: in std_logic ; 
        F: out STD_LOGIC_VECTOR(172 downto 0)
        );
    
end COMPONENT;

--------------------------SIGNAL-INITIALIZATION--------------------------
--------------------------FETCH--------------------------

SIGNAL FetchDecodeBufferIN : std_logic_vector(80 downto 0);
SIGNAL FetchDecodeBufferOUT : std_logic_vector(80 downto 0);
SIGNAL FetchBranchingAddress : std_logic_vector(31 downto 0);
SIGNAL FetchINT : std_logic;
SIGNAL FetchBranchingSel : std_logic;
SIGNAL FetchExceptionSel : std_logic;
SIGNAL FetchStall : std_logic;
SIGNAL FetchDataOut : std_logic_vector(15 downto 0);
SIGNAL FetchPCPlus : std_logic_vector(31 downto 0);
SIGNAL FetchWrongAddress : std_logic;

--------------------------DECODE--------------------------

SIGNAL DecodeExecuteBufferIN : std_logic_vector(195 downto 0);
SIGNAL DecodeExecuteBufferOUT : std_logic_vector(195 downto 0);
SIGNAL DecodeWriteBackEnable : std_logic;
SIGNAL DecodePredictorEnable : std_logic;
SIGNAL DecodeInstruction : std_logic_vector(15 downto 0);
SIGNAL DecodeWritePort1 : std_logic_vector(31 downto 0);
SIGNAL DecodeWritePort2 : std_logic_vector(31 downto 0);
SIGNAL DecodeWriteAdd1 : std_logic_vector(2 downto 0);
SIGNAL DecodeWriteAdd2 : std_logic_vector(2 downto 0);
SIGNAL DecodeFlush : std_logic;
SIGNAL DecodeSwaped : std_logic;
SIGNAL DecodeImmediateValue : std_logic_vector(31 downto 0);
SIGNAL DecodeReadData1 : std_logic_vector(31 downto 0);
SIGNAL DecodeReadData2 : std_logic_vector(31 downto 0);
SIGNAL DecodeAluSelector : std_logic_vector(3 downto 0);
SIGNAL DecodeBranching : std_logic;
SIGNAL DecodeAluSource : std_logic;
SIGNAL DecodeMWrite : std_logic;
SIGNAL DecodeMRead : std_logic;
SIGNAL DecodeWBdatasrc : std_logic_vector(1 downto 0);
SIGNAL DecodeRegWrite : std_logic;
SIGNAL DecodeSPPointer : std_logic_vector(2 downto 0);
SIGNAL DecodeOutEnable : std_logic;
SIGNAL DecodeInterruptSignal : std_logic;
SIGNAL DecodePcSource : std_logic;
SIGNAL DecodeRtiSignal : std_logic;
SIGNAL DecodeFreeProtectStore : std_logic_vector(1 downto 0);
SIGNAL DecodeSwap : std_logic;
SIGNAL DecodeMemAddress : std_logic_vector(2 downto 0);
SIGNAL DecodeRet : std_logic_vector(1 downto 0);
SIGNAL DecodeCallIntStore : std_logic_vector(1 downto 0);
SIGNAL DecodeFlushOut : std_logic;

--------------------------EXECUTE--------------------------
SIGNAL ExecuteMemoryBufferIN : std_logic_vector(157 downto 0);
SIGNAL ExecuteMemoryBufferOUT : std_logic_vector(157 downto 0);
SIGNAL ExecuteOpcode : std_logic_vector(5 downto 0);
SIGNAL ExecuteReg1 : std_logic_vector(31 downto 0);
SIGNAL ExecuteReg2 : std_logic_vector(31 downto 0);
SIGNAL ExecuteForwarded_Src_1_EX_MEM : std_logic_vector(31 downto 0);
SIGNAL ExecuteForwarded_Src_1_MEM_WB : std_logic_vector(31 downto 0);
SIGNAL ExecuteForwarded_Src_2_EX_MEM : std_logic_vector(31 downto 0);
SIGNAL ExecuteForwarded_Src_2_MEM_WB : std_logic_vector(31 downto 0);
SIGNAL ExecuteALU_selector : std_logic_vector(3 downto 0);
SIGNAL ExecuteDestination_Reg_EX_MEM : std_logic_vector(2 downto 0);
SIGNAL ExecuteDestination_Reg_MEM_WB : std_logic_vector(2 downto 0);
SIGNAL ExecuteSrc1_From_ID_EX : std_logic_vector(2 downto 0);
SIGNAL ExecuteSrc2_From_ID_EX : std_logic_vector(2 downto 0);
SIGNAL ExecuteWBenable_EX_MEM : std_logic;
SIGNAL ExecuteWBenable_MEM_WB : std_logic;
SIGNAL ExecuteWBsource_EX_MEM : std_logic_vector(1 downto 0);
SIGNAL ExecuteSwap : std_logic;
SIGNAL ExecutePredictorIn : std_logic;
SIGNAL ExecuteALUout : std_logic_vector(31 downto 0);
SIGNAL ExecuteFlagReg_out : std_logic_vector(3 downto 0);
SIGNAL ExecuteFlushOut : std_logic;
SIGNAL ExecuteNotTakenWrongBranch : std_logic;
SIGNAL ExecuteTakenWrongBranch : std_logic;

--------------------------MEMORY--------------------------
SIGNAL MemoryWriteBackBufferIN : std_logic_vector(172 downto 0);
SIGNAL MemoryWriteBackBufferOUT : std_logic_vector(172 downto 0);
SIGNAL MemoryWrite : std_logic;
SIGNAL MemoryRead : std_logic;
SIGNAL MemoryEnable : std_logic;
SIGNAL MemoryAddress : std_logic_vector(2 DOWNTO 0);
SIGNAL MemoryCALLIntSTD : std_logic_vector(1 DOWNTO 0);
SIGNAL MemoryRET : std_logic_vector(1 DOWNTO 0);
SIGNAL MemoryALUOut : std_logic_vector(31 DOWNTO 0);
SIGNAL MemoryPCPlus : std_logic_vector(31 DOWNTO 0);
SIGNAL MemorySecondOperand : std_logic_vector(31 DOWNTO 0);
SIGNAL MemorySP : std_logic_vector(2 DOWNTO 0);
SIGNAL MemoryFlagReg : std_logic_vector(3 DOWNTO 0);
SIGNAL MemoryOut : std_logic_vector(31 DOWNTO 0);
SIGNAL MemoryWrongAddress : std_logic;
SIGNAL MemoryFlushAllBack : std_logic;
SIGNAL MemoryFlushINT_RTI: std_logic;
SIGNAL MemoryINTDetected: std_logic;
SIGNAL MemoryFlagRegOut: std_logic_vector(3 DOWNTO 0);

--------------------------WRITEBACK--------------------------
SIGNAL WriteBackALUout : std_logic_vector(31 downto 0);
SIGNAL WriteBackData_in : std_logic_vector(31 downto 0);
SIGNAL WriteBackMemoryOut : std_logic_vector(31 downto 0);
SIGNAL WriteBackWriteBackSource : std_logic_vector(1 downto 0);
SIGNAL WriteBackWrite_enable : std_logic;
SIGNAL WriteBackMux_result : std_logic_vector(31 downto 0);
SIGNAL WriteBackOutputPortEnable : std_logic;
SIGNAL WriteBackSwap : std_logic;
SIGNAL WriteBackSecond_operand : std_logic_vector(31 downto 0);


BEGIN
--------------------------PIPELINE-BUFFERS--------------------------
------------------------------FETCH--------------------------------------
-- TODO: do not forget to handle the branching
--FetchBranchingAddress <= bla bla blaa
--FetchBranchingSel <= bla bla blaa
--FetchExceptionSel <= bla bla blaa
--FetchStall <= bla bla blaa
--FetchINT <= bla bla blaa
FetchStage: Fetch port map (clk => clk, branchingAddress => FetchBranchingAddress, en => en, rst => rst, interrupt => FetchINT, branchingSel => FetchBranchingSel, exceptionSel => FetchExceptionSel, stall => FetchStall, dataout => FetchDataOut, pcPlus => FetchPCPlus, WrongAddress => FetchWrongAddress);
FetchDecodeBuffer: FetchDecode_Reg port map (A => FetchDecodeBufferIN, clk => clk, en => en, rst => rst, F => FetchDecodeBufferOUT, Flush => FetchStall);
FetchDecodeBufferIN(80 downto 49) <= InPort;
FetchDecodeBufferIN(48 downto 33) <= FetchDataOut;
FetchDecodeBufferIN(32 downto 1) <= FetchPCPlus;
FetchDecodeBufferIN(0) <= FetchWrongAddress;

process(FetchDataOut)
    begin
        for i in 31 downto 16 loop
          --ImmediateValue_DIN(i) <= Instruction_FDIN(15);
          if DecodeAluSelector = "1111" then
            DecodeImmediateValue(i) <= '0';
          else
            DecodeImmediateValue(i) <= FetchDataOut(15);
          end if;
        end loop;
        DecodeImmediateValue(15 downto 0) <= FetchDataOut(15 downto 0);
    end process;
------------------------------DECODE--------------------------------------

--DecodeWriteBackEnable <= bla blaa 5odha mn el write back
DecodePredictorEnable <= '1';
DecodeInstruction <= FetchDecodeBufferOUT(48 downto 33);
-- DecodeWritePort1 <= 5odha mn el write back;
-- DecodeWritePort2 <= 5odha mn el write back;
-- DecodeWriteAdd1 <= 5odha mn el write back;
-- DecodeWriteAdd2 <= 5odha mn el write back;
-- DecodeFlush <= 5odha mn el execution;
-- DecodeSwaped <= 5odha mn el write back;
--DecodeImmediateValue <= FetchDataOut(15 downto 0);
DecodeStage: Decode port map (Clk => clk, Rst => rst, writeBackEnable => DecodeWriteBackEnable, PredictorEnable => DecodePredictorEnable, Instruction => DecodeInstruction, writeport1 => DecodeWritePort1, writeport2 => DecodeWritePort2, WriteAdd1 => DecodeWriteAdd1, WriteAdd2 => DecodeWriteAdd2, Flush => DecodeFlush, Swaped => DecodeSwaped, ImmediateValue => FetchDataOut(15 downto 0), ReadData1 => DecodeReadData1, ReadData2 => DecodeReadData2, AluSelector => DecodeAluSelector, Branching => DecodeBranching, alusource => DecodeAluSource, MWrite => DecodeMWrite, MRead => DecodeMRead, WBdatasrc => DecodeWBdatasrc, RegWrite => DecodeRegWrite, SPPointer => DecodeSPPointer, interruptsignal => DecodeInterruptSignal, pcSource => DecodePcSource, rtisignal => DecodeRtiSignal, FreeProtectStore => DecodeFreeProtectStore, Swap => DecodeSwap, MemAddress => DecodeMemAddress, Ret => DecodeRet, CallIntStore => DecodeCallIntStore, FlushOut => DecodeFlushOut, OutEnable => DecodeOutEnable);
DecodeExecuteBuffer: DecodeExecute_Reg port map (A => DecodeExecuteBufferIN, clk => clk, en => en, rst => rst, F => DecodeExecuteBufferOUT);
DecodeExecuteBufferIN(195 downto 190) <= FetchDecodeBufferOUT(48 downto 43);
DecodeExecuteBufferIN(189 downto 188) <= DecodeRet;
DecodeExecuteBufferIN(187) <= DecodeSwap;
DecodeExecuteBufferIN(186) <= DecodeAluSource;
DecodeExecuteBufferIN(185 downto 154) <= DecodeImmediateValue;
DecodeExecuteBufferIN(153 downto 151) <= DecodeMemAddress;
DecodeExecuteBufferIN(150 downto 149) <= DecodeFreeProtectStore;
DecodeExecuteBufferIN(148 downto 145) <= DecodeAluSelector;
DecodeExecuteBufferIN(144 downto 142) <= DecodeSPPointer;
DecodeExecuteBufferIN(141) <= DecodeOutEnable;
DecodeExecuteBufferIN(140 downto 139) <= DecodeWBdatasrc;
DecodeExecuteBufferIN(138 downto 136) <= DecodeMWrite & DecodeMRead & DecodeRegWrite;
DecodeExecuteBufferIN(135 downto 134) <= DecodeCallIntStore;
DecodeExecuteBufferIN(133 downto 102) <= DecodeReadData1;
DecodeExecuteBufferIN(101 downto 70) <= DecodeReadData2;
DecodeExecuteBufferIN(69 downto 38) <= FetchDecodeBufferOUT(80 downto 49);
DecodeExecuteBufferIN(37 downto 32) <= DecodeWriteAdd1 & DecodeWriteAdd2;
DecodeExecuteBufferIN(31 downto 0) <= FetchDecodeBufferOUT(32 downto 1);





END ProccessorFinal_Arch;

