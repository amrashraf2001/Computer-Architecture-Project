LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Decode IS
GENERIC(n : integer :=32);
    PORT(  
        clk,rst,writeEnable:in std_logic;
        Instruction: IN std_logic_vector(15 DOWNTO 0); 
        writeport1:in std_logic_vector(n-1 downto 0);
        writeport2:in std_logic_vector(n-1 downto 0);
        ReadData1:out std_logic_vector(n-1 downto 0);
        ReadData2:out std_logic_vector(n-1 downto 0);
        WriteAdd1: in  std_logic_vector (2 downto 0);
        WriteAdd2: in  std_logic_vector (2 downto 0);
        -- ReadAdd1: in  std_logic_vector (2 downto 0);
        -- ReadAdd2: in  std_logic_vector (2 downto 0);
        AluSelector: OUT std_logic_vector(3 DOWNTO 0); -- 3 bits subcode and extra bit
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
        Flush: IN std_logic;
        ImmediateValue: IN std_logic_vector(15 DOWNTO 0)
    );
END ENTITY Decode;

ARCHITECTURE Decode_Arch OF Decode IS
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
            interruptsignal:  OUT std_logic;
            pcSource: OUT std_logic;
            rtisignal:  OUT std_logic;
            FreeProtectStore: OUT std_logic_vector(1 DOWNTO 0)
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
            clk, rst, en : IN std_logic 
        );
    END component;

    signal regOneAddress, regTwoAddress, regAddressDist1, regAddressDist2 : std_logic_vector(2 downto 0);
    signal opcode : std_logic_vector(5 downto 0);
    signal ExtendedImmediate : std_logic_vector(31 downto 0);
    signal PredictorInput : std_logic := '0';
    signal PredictorOutput : std_logic;
    signal swapcheck : std_logic;
    signal writeData1, writeData2 : std_logic_vector(31 downto 0);

begin
    process(ImmediateValue)
    begin
        for i in 0 to 15 loop
            ExtendedImmediate(i) <= ImmediateValue(15);
        end loop;
        ExtendedImmediate(31 downto 16) <= ImmediateValue(15 downto 0);
    end process;

    swapcheck <= '1' when Instruction(15 downto 10) = "000101" else '0';
    regAddressDist1 <= Instruction(3 downto 1) when swapcheck = '1' else Instruction(9 downto 7);
    regAddressDist2 <= Instruction(6 downto 4) when swapcheck = '1' else Instruction(9 downto 7);
    writeData1 <= writeport1;
    writeData2 <= writeport2 when swapcheck = '1' else writeport1;
    opcode <= Instruction(15 downto 10);
    regOneAddress <= Instruction(6 downto 4);
    regTwoAddress <= Instruction(3 downto 1);

    Controller1: Controller PORT MAP(opcode, AluSelector, Branching, alusource, MWrite, MRead, WBdatasrc, RegWrite, SPPointer, interruptsignal, pcSource, rtisignal, FreeProtectStore);

    RegFile1: RegFile port map (
        Clk => clk,
        Rst => rst,
        WriteEnable => writeEnable,
        ReadAddress1 => regOneAddress,
        ReadAddress2 => regTwoAddress,
        WriteAddress1 => regAddressDist1,
        WriteAddress2 => regAddressDist2,
        ReadData1 => ReadData1,
        ReadData2 => ReadData2,
        WriteData1 => writeData1,
        WriteData2 => writeData2
    );

    PredictorReg1: PredictorReg PORT MAP(PredictorInput, PredictorOutput, clk, rst, writeEnable);

    PredictorInput <= PredictorOutput when (Flush = '0') else not PredictorOutput when (Flush = '1') else '0';

    ReadData2 <= ReadData2 when alusource = '0' else ExtendedImmediate;

END Decode_Arch;
