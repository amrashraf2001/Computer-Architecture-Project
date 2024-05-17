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
        OutEnable: OUT std_logic;
        PredictorValue: OUT std_logic
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
        TakenWrongBranch : OUT std_logic; -- el and eli ta7t taken w kan el mafroud a not take it
        stalling : out std_logic
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
        WriteBackAddress1 : out STD_LOGIC_VECTOR(2 downto 0);
        WriteBackAddress2 : out STD_LOGIC_VECTOR(2 downto 0);
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
-- src1Add, src2Add 6 bit (202 downto 197)
-- predictor 1 bit (196)
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
        A: IN std_logic_vector(202 downto 0); 
        clk,en,rst: in std_logic ; 
        F: out STD_LOGIC_VECTOR(202 downto 0));
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
SIGNAL FetchStall : std_logic:='0';
SIGNAL FetchDataOut : std_logic_vector(15 downto 0);
SIGNAL FetchPCPlus : std_logic_vector(31 downto 0);
SIGNAL FetchWrongAddress : std_logic;

--------------------------DECODE--------------------------

SIGNAL DecodeExecuteBufferIN : std_logic_vector(202 downto 0);
SIGNAL DecodeExecuteBufferOUT : std_logic_vector(202 downto 0);
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
SIGNAL DecodePredictorValue : std_logic;
SIGNAL DecodeSrcAdd1: std_logic_vector(2 downto 0);
SIGNAL DecodeSrcAdd2: std_logic_vector(2 downto 0);

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
SIGNAl ExecuteStall : std_logic;

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
SIGNAL MemoryFreeProtectedStore : std_logic_vector(1 DOWNTO 0);
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
SIGNAL WriteBackAddress1 : std_logic_vector(2 downto 0);
SIGNAL WriteBackAddress2 : std_logic_vector(2 downto 0);

----------------------------VARIABLES----------------------------
SIGNAL FirstMuxResult : std_logic_vector(31 downto 0);
SIGNAL SecondMuxResult : std_logic_vector(31 downto 0);


BEGIN
--------------------------PIPELINE-BUFFERS--------------------------
------------------------------FETCH--------------------------------------
-- TODO: do not forget to handle the branching
FirstMuxResult <= DecodeReadData1 when ExecuteMemoryBufferOUT(157 downto 156) /= "01" and ExecuteMemoryBufferOUT(157 downto 156) /= "10"
else MemoryOut when ExecuteMemoryBufferOUT(157 downto 156) = "01" or ExecuteMemoryBufferOUT(157 downto 156) = "10"
else DecodeReadData1;
SecondMuxResult <= FirstMuxResult when ExecuteNotTakenWrongBranch = '0' and ExecuteTakenWrongBranch = '0'
else DecodeExecuteBufferOUT(31 downto 0) when ExecuteNotTakenWrongBranch = '0' and ExecuteTakenWrongBranch = '1'
else DecodeExecuteBufferOUT(133 downto 102) when ExecuteNotTakenWrongBranch = '1' and ExecuteTakenWrongBranch = '0'
else DecodeReadData1;
FetchBranchingAddress <= SecondMuxResult;
FetchBranchingSel <= '1' when ExecuteTakenWrongBranch = '1' or ExecuteNotTakenWrongBranch = '1' or DecodeFlushOut = '1' else '0';
FetchExceptionSel <= MemoryWrongAddress;
FetchStall <= ExecuteStall;
FetchINT <= '1' when MemoryINTDetected = '1' else '0'; -- not sure about that
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

DecodeWriteBackEnable <= MemoryWriteBackBufferOUT(169); -- not sure about that
DecodePredictorEnable <= '1';
DecodeInstruction <= FetchDecodeBufferOUT(48 downto 33);
DecodeWritePort1 <= WriteBackMux_result;
DecodeWritePort2 <= WriteBackSecond_operand;
DecodeWriteAdd1 <= WriteBackAddress1;
DecodeWriteAdd2 <= WriteBackAddress2;
DecodeFlush <= ExecuteFlushOut;
DecodeSwaped <= WriteBackSwap;
DecodeStage: Decode port map (Clk => clk, Rst => rst, writeBackEnable => DecodeWriteBackEnable, PredictorEnable => DecodePredictorEnable, Instruction => DecodeInstruction, writeport1 => DecodeWritePort1, writeport2 => DecodeWritePort2, WriteAdd1 => DecodeWriteAdd1, WriteAdd2 => DecodeWriteAdd2, Flush => DecodeFlush, Swaped => DecodeSwaped, ImmediateValue => FetchDataOut(15 downto 0), ReadData1 => DecodeReadData1, ReadData2 => DecodeReadData2, AluSelector => DecodeAluSelector, Branching => DecodeBranching, alusource => DecodeAluSource, MWrite => DecodeMWrite, MRead => DecodeMRead, WBdatasrc => DecodeWBdatasrc, RegWrite => DecodeRegWrite, SPPointer => DecodeSPPointer, interruptsignal => DecodeInterruptSignal, pcSource => DecodePcSource, rtisignal => DecodeRtiSignal, FreeProtectStore => DecodeFreeProtectStore, Swap => DecodeSwap, MemAddress => DecodeMemAddress, Ret => DecodeRet, CallIntStore => DecodeCallIntStore, FlushOut => DecodeFlushOut, OutEnable => DecodeOutEnable, PredictorValue => DecodePredictorValue);
DecodeExecuteBuffer: DecodeExecute_Reg port map (A => DecodeExecuteBufferIN, clk => clk, en => en, rst => rst, F => DecodeExecuteBufferOUT);
DecodeSrcAdd1 <= FetchDecodeBufferOUT(39 downto 37);
DecodeSrcAdd2 <= FetchDecodeBufferOUT(36 downto 34);
DecodeExecuteBufferIN(202 downto 197) <= DecodeSrcAdd1 & DecodeSrcAdd2;
DecodeExecuteBufferIN(196) <= DecodePredictorValue;
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
DecodeExecuteBufferIN(138 downto 136) <= DecodeMRead & DecodeMWrite & DecodeRegWrite;
DecodeExecuteBufferIN(135 downto 134) <= DecodeCallIntStore;
DecodeExecuteBufferIN(133 downto 102) <= DecodeReadData1;
DecodeExecuteBufferIN(101 downto 70) <= DecodeReadData2;
DecodeExecuteBufferIN(69 downto 38) <= FetchDecodeBufferOUT(80 downto 49);
DecodeExecuteBufferIN(37 downto 32) <= FetchDecodeBufferOUT(42 downto 40) & FetchDecodeBufferOUT(39 downto 37); -- add1 then add2
DecodeExecuteBufferIN(31 downto 0) <= FetchDecodeBufferOUT(32 downto 1);


------------------------------EXECUTE--------------------------------------

ExecuteStage: Execute port map (clk => clk, en => en, rst => rst, opcode => ExecuteOpcode, Reg1 => ExecuteReg1, Reg2 => ExecuteReg2, Forwarded_Src_1_EX_MEM => ExecuteForwarded_Src_1_EX_MEM, Forwarded_Src_1_MEM_WB => ExecuteForwarded_Src_1_MEM_WB, Forwarded_Src_2_EX_MEM => ExecuteForwarded_Src_2_EX_MEM, Forwarded_Src_2_MEM_WB => ExecuteForwarded_Src_2_MEM_WB, ALU_selector => ExecuteALU_selector, Destination_Reg_EX_MEM => ExecuteDestination_Reg_EX_MEM, Destination_Reg_MEM_WB => ExecuteDestination_Reg_MEM_WB, Src1_From_ID_EX => ExecuteSrc1_From_ID_EX, Src2_From_ID_EX => ExecuteSrc2_From_ID_EX, WBenable_EX_MEM => ExecuteWBenable_EX_MEM, WBenable_MEM_WB => ExecuteWBenable_MEM_WB, WBsource_EX_MEM => ExecuteWBsource_EX_MEM, swap => ExecuteSwap, PredictorIn => ExecutePredictorIn, ALUout => ExecuteALUout, FlagReg_out => ExecuteFlagReg_out, FlushOut => ExecuteFlushOut, NotTakenWrongBranch => ExecuteNotTakenWrongBranch, TakenWrongBranch => ExecuteTakenWrongBranch, stalling => ExecuteStall);
ExecuteMemoryBuffer: ExecuteMemory_Reg port map (A => ExecuteMemoryBufferIN, clk => clk, en => en, rst => rst, F => ExecuteMemoryBufferOUT);
ExecuteOpcode <= DecodeExecuteBufferOUT(195 downto 190);
ExecuteReg1 <= DecodeReadData1;
ExecuteReg2 <= DecodeReadData2;
ExecuteForwarded_Src_1_EX_MEM <= ExecuteMemoryBufferIN(115 downto 84) when ExecuteMemoryBufferIN(3 downto 2) = "00"
else ExecuteMemoryBufferIN(77 downto 46);  --(ALU output or IN value from EX MEM buffer)
ExecuteForwarded_Src_1_MEM_WB <= MemoryWriteBackBufferIN(165 downto 134) when MemoryWriteBackBufferIN(168 downto 167) = "01"
else MemoryWriteBackBufferIN(133 downto 102) when MemoryWriteBackBufferIN(168 downto 167) = "10"
else MemoryWriteBackBufferIN(63 downto 32);-- (Memory or ALU or IN value output from MEM WB buffer)
ExecuteForwarded_Src_2_EX_MEM <= ExecuteMemoryBufferIN(115 downto 84) when ExecuteMemoryBufferIN(3 downto 2) = "00"
else ExecuteMemoryBufferIN(77 downto 46); --(ALU output or IN value from EX MEM buffer)
ExecuteForwarded_Src_2_MEM_WB <= MemoryWriteBackBufferIN(165 downto 134) when MemoryWriteBackBufferIN(168 downto 167) = "01"
else MemoryWriteBackBufferIN(133 downto 102) when MemoryWriteBackBufferIN(168 downto 167) = "10"
else MemoryWriteBackBufferIN(63 downto 32);-- (Memory or ALU or IN value output from MEM WB buffer)
ExecuteALU_selector <= DecodeExecuteBufferOUT(148 downto 145);
ExecuteDestination_Reg_EX_MEM <=ExecuteMemoryBufferIN(83 downto 81); --5odha mn el execute memory buffer
ExecuteDestination_Reg_MEM_WB <=MemoryWriteBackBufferIN (69 downto 67);--5odha mn el memory write back buffer
ExecuteSrc1_From_ID_EX <= DecodeExecuteBufferIN(202 downto 200);--5odha mn el decode execute buffer
ExecuteSrc2_From_ID_EX <= DecodeExecuteBufferIN(199 downto 197);--5odha mn el decode execute buffer
ExecuteWBenable_EX_MEM <= ExecuteMemoryBufferIN(8);--5odha mn el execute memory buffer
ExecuteWBenable_MEM_WB <= MemoryWriteBackBufferIN(169);--5odha mn el memory write back buffer
ExecuteWBsource_EX_MEM <= ExecuteMemoryBufferIN(3 downto 2); --5odha mn el execute memory buffer
--ExecuteForwarded_Src_1_EX_MEM <= 5odha mn el execute memory buffer
--ExecuteForwarded_Src_1_MEM_WB <= 5odha mn el memory write back buffer
--ExecuteForwarded_Src_2_EX_MEM <= 5odha mn el execute memory buffer
--ExecuteForwarded_Src_2_MEM_WB <= 5odha mn el memory write back buffer
--ExecuteALU_selector <= DecodeExecuteBufferOUT(148 downto 145); bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
--ExecuteDestination_Reg_EX_MEM <= 5odha mn el execute memory buffer
--ExecuteDestination_Reg_MEM_WB <= 5odha mn el memory write back buffer
--ExecuteSrc1_From_ID_EX <= 5odha mn el decode execute buffer
--ExecuteSrc2_From_ID_EX <= 5odha mn el decode execute buffer
--ExecuteWBenable_EX_MEM <= 5odha mn el execute memory buffer
--ExecuteWBenable_MEM_WB <= 5odha mn el memory write back buffer
--ExecuteWBsource_EX_MEM <= 5odha mn el execute memory buffer
ExecuteSwap <= DecodeExecuteBufferOUT(187);
ExecutePredictorIn <= DecodeExecuteBufferOUT(196);
ExecuteMemoryBufferIN(157 downto 156) <= DecodeExecuteBufferOUT(189 downto 188);
ExecuteMemoryBufferIN(155) <= DecodeExecuteBufferOUT(187);
ExecuteMemoryBufferIN(154 downto 152) <= DecodeExecuteBufferOUT(153 downto 151);
ExecuteMemoryBufferIN(151 downto 148) <= ExecuteFlagReg_out;
ExecuteMemoryBufferIN(147 downto 116) <= DecodeExecuteBufferOUT(31 downto 0);
ExecuteMemoryBufferIN(115 downto 84) <= FetchDecodeBufferOUT(69 downto 38);
ExecuteMemoryBufferIN(83 downto 78) <= DecodeExecuteBufferOUT(37 downto 32);
ExecuteMemoryBufferIN(77 downto 46) <= ExecuteALUout;
ExecuteMemoryBufferIN(45 downto 14) <= DecodeExecuteBufferOUT(101 downto 70);
ExecuteMemoryBufferIN(13 downto 12) <= DecodeExecuteBufferOUT(135 downto 134);
ExecuteMemoryBufferIN(11) <= DecodeExecuteBufferOUT(141);
ExecuteMemoryBufferIN(10 downto 8) <= DecodeExecuteBufferOUT(138 downto 136);
ExecuteMemoryBufferIN(7) <= DecodeExecuteBufferOUT(186);
ExecuteMemoryBufferIN(6 downto 4) <= DecodeExecuteBufferOUT(144 downto 142);
ExecuteMemoryBufferIN(3 downto 2) <= DecodeExecuteBufferOUT(140 downto 139);
ExecuteMemoryBufferIN(1 downto 0) <= DecodeExecuteBufferOUT(150 downto 149);

------------------------------MEMORY--------------------------------------
MemoryStage: Memory port map (clk => clk, en => en, rst => rst, MemoryWrite => MemoryWrite, MemoryRead => MemoryRead, MemoryEnable => MemoryEnable, MemoryAddress => MemoryAddress, CALLIntSTD => MemoryCALLIntSTD, RET => MemoryRET, ALUOut => MemoryALUOut, pcPlus => MemoryPCPlus, SecondOperand => MemorySecondOperand, SP => MemorySP, FlagReg => MemoryFlagReg,FreeProtectedStore => MemoryFreeProtectedStore , MemoryOut => MemoryOut, WrongAddress => MemoryWrongAddress, FlushAllBack => MemoryFlushAllBack, FlushINT_RTI => MemoryFlushINT_RTI, INTDetected => MemoryINTDetected, FlagRegOut => MemoryFlagRegOut);
MemoryWriteBackBuffer: MemoryWriteBack_Reg port map (A => MemoryWriteBackBufferIN, clk => clk, en => en, rst => rst, F => MemoryWriteBackBufferOUT);
MemoryWrite <= ExecuteMemoryBufferOUT(9);
MemoryRead <= ExecuteMemoryBufferOUT(10);
MemoryEnable <= '1';
MemoryAddress <= ExecuteMemoryBufferOUT(154 downto 152);
MemoryCALLIntSTD <= ExecuteMemoryBufferOUT(13 downto 12);
MemoryRET <= ExecuteMemoryBufferOUT(157 downto 156);
MemoryALUOut <= ExecuteMemoryBufferOUT(77 downto 46);
MemoryPCPlus <= ExecuteMemoryBufferOUT(147 downto 116);
MemorySecondOperand <= ExecuteMemoryBufferOUT(45 downto 14);
MemorySP <= ExecuteMemoryBufferOUT(6 downto 4);
MemoryFlagReg <= ExecuteMemoryBufferOUT(151 downto 148);
MemoryWriteBackBufferIN(172 downto 171) <= ExecuteMemoryBufferOUT(157 downto 156);
MemoryWriteBackBufferIN(170) <= ExecuteMemoryBufferOUT(155);
MemoryWriteBackBufferIN(169) <= ExecuteMemoryBufferOUT(8);
MemoryWriteBackBufferIN(168 downto 167) <= ExecuteMemoryBufferOUT(3 downto 2);
MemoryWriteBackBufferIN(166) <= ExecuteMemoryBufferOUT(11);
MemoryWriteBackBufferIN(165 downto 134) <= MemoryOut;
MemoryWriteBackBufferIN(133 downto 102) <= ExecuteMemoryBufferOUT(77 downto 46);
MemoryWriteBackBufferIN(101 downto 70) <= ExecuteMemoryBufferOUT(45 downto 14);
MemoryWriteBackBufferIN(69 downto 64) <= ExecuteMemoryBufferOUT(83 downto 78);
MemoryWriteBackBufferIN(63 downto 32) <= ExecuteMemoryBufferOUT(115 downto 84);
MemoryWriteBackBufferIN(31 downto 0) <= ExecuteMemoryBufferOUT(147 downto 116);

------------------------------WRITEBACK--------------------------------------
WriteBackStage: WriteBack port map (clk => clk, reset => rst, ALUout => WriteBackALUout, data_in => WriteBackData_in, MemoryOut => WriteBackMemoryOut, WriteBackSource => WriteBackWriteBackSource, write_enable => WriteBackWrite_enable, WriteBackAddress1 => WriteBackAddress1, WriteBackAddress2 => WriteBackAddress2, Mux_result => WriteBackMux_result, OutputPortEnable => WriteBackOutputPortEnable, swap => WriteBackSwap, second_operand => WriteBackSecond_operand);
WriteBackALUout <= MemoryWriteBackBufferOUT(133 downto 102);
WriteBackData_in <= MemoryWriteBackBufferOUT(63 downto 32);
WriteBackMemoryOut <= MemoryWriteBackBufferOUT(165 downto 134);
WriteBackWriteBackSource <= MemoryWriteBackBufferOUT(168 downto 167);
WriteBackWrite_enable <= MemoryWriteBackBufferOUT(169);
WriteBackAddress1 <= MemoryWriteBackBufferOUT(69 downto 67);
WriteBackAddress2 <= MemoryWriteBackBufferOUT(66 downto 64);


------------------------------OUTPORT--------------------------------------
OutPort <= WriteBackMux_result when MemoryWriteBackBufferOUT(166) = '1' else (Others => '0');



END ProccessorFinal_Arch;

