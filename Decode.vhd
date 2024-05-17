LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Decode IS
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
END ENTITY Decode;

architecture Decode_Arch of Decode is
    component Controller IS
        PORT(
            opcode: IN std_logic_vector(5 DOWNTO 0); 
            AluSelector: OUT std_logic_vector(3 DOWNTO 0); -- 3 bits subcode and extra bit
            Branching: OUT std_logic;
            alusource: OUT std_logic; -- ba4of ba5ud el second operand mn el register or immediate
            MWrite, MRead: OUT std_logic;
            WBdatasrc: OUT std_logic_vector(1 DOWNTO 0);
            RegWrite: OUT std_logic;
            SPPointer: OUT std_logic_vector(2 DOWNTO 0);
            interruptsignal:  out std_logic;
            pcSource: OUT std_logic;
            FreeProtectStore: OUT std_logic_vector(1 DOWNTO 0);
            MemAddress: OUT std_logic_vector(2 DOWNTO 0);
            CallIntStore: OUT std_logic_vector(1 DOWNTO 0);
            Ret: out std_logic_vector(1 downto 0);
            Swap: out std_logic;
            OutEnable: OUT std_logic
        );
    END component;
    
    component RegFile IS
        PORT(
            Clk, Rst, WriteEnable : IN STD_LOGIC;
            ReadAddress1, ReadAddress2, WriteAddress1, WriteAddress2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            ReadData1, ReadData2 : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
            WriteData1, WriteData2 : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0)
        );
    END component;
    
    component PredictorReg IS
        PORT( 
            d : IN std_logic;
            q : OUT std_logic;
            Clk, Rst, en : IN std_logic 
        );
    END component;
    
    signal opcode: std_logic_vector(5 DOWNTO 0);
    signal RAdd1, RAdd2: std_logic_vector(2 DOWNTO 0);
    signal WAdd1, WAdd2: std_logic_vector(2 DOWNTO 0);
    signal ExtendedImmediate: std_logic_vector(31 DOWNTO 0);
    --signal Swap: std_logic;
    signal WData1, WData2: std_logic_vector(31 DOWNTO 0);
    signal PredictorInput: std_logic := '0';
    signal PredictorOutput: std_logic;
    SIGNAL tempFlush: std_logic;

begin
    process(ImmediateValue)
    begin
        for i in 31 downto 16 loop
            ExtendedImmediate(i) <= ImmediateValue(15);
        end loop;
        ExtendedImmediate(15 downto 0) <= ImmediateValue(15 downto 0);
    end process;
    
    --Swapcheck <= '1' when Instruction(15 downto 10) = "000101" else '0';
    --Swap <= Swapcheck;
    opcode <= Instruction(15 downto 10);
    RAdd1 <= Instruction(6 downto 4);
    RAdd2 <= Instruction(3 downto 1) when Swap ='0' else Instruction(9 downto 7);
    WAdd1 <= WriteAdd1;
    WAdd2 <= WriteAdd2 when Swaped = '1' else WriteAdd1;
    WData1 <= writeport1;
    WData2 <= writeport2 when Swaped = '1' else writeport1;
    PredictorInput <= PredictorOutput when flush = '0'
    else not PredictorOutput when flush = '1'
    else PredictorOutput;
    
    Controller1: Controller PORT MAP(opcode, AluSelector, Branching, alusource, MWrite, MRead, WBdatasrc, RegWrite, SPPointer, interruptsignal, pcSource, FreeProtectStore, MemAddress,CallIntStore ,Ret, Swap);
    
    RegFile1: RegFile PORT MAP(
        Clk => Clk,
        Rst => Rst,
        WriteEnable => writeBackEnable,
        ReadAddress1 => RAdd1,
        ReadAddress2 => RAdd2,
        WriteAddress1 => WAdd1,
        WriteAddress2 => WAdd2,
        ReadData1 => ReadData1,
        ReadData2 => ReadData2,
        WriteData1 => WData1,
        WriteData2 => WData2
    );
    
    PredictorReg1: PredictorReg PORT MAP(PredictorInput, PredictorOutput, Clk, Rst, PredictorEnable);
    tempFlush <= '1' when (Instruction(15 downto 10) = "100001") else '0';
    FlushOut <= ((PredictorOutput)AND (tempFlush)) or ((tempFlush) AND (Branching));
    PredictorValue <= PredictorOutput;
end architecture Decode_Arch;