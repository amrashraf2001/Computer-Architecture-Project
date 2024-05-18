LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Memory IS
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
END Memory;

ARCHITECTURE Memory_Architecture OF Memory IS
    COMPONENT Data_Memory IS
        GENERIC (n : INTEGER := 32);
        PORT (
            Clk, Rst, WriteEnable,ReadEnable : IN STD_LOGIC;
            ReadAddress, WriteAddress : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            ReadData : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            WriteData : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            WrongAddress : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT StackReg IS
        GENERIC (n : INTEGER := 32);
        PORT (
            d : IN std_logic_vector(n - 1 DOWNTO 0);
            q : OUT std_logic_vector(n - 1 DOWNTO 0);
            clk, rst, en : IN std_logic
        );
    END COMPONENT;

    COMPONENT ProtectedFlagReg IS
        GENERIC (n : INTEGER := 32);
        PORT (
            Clk, Rst, WriteEnable, ReadEnable : IN STD_LOGIC;
            ReadAddress, WriteAddress : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            ReadData : OUT STD_LOGIC;
            WriteData : IN STD_LOGIC;
            WrongAddress : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL ProtectedFlag : STD_LOGIC := '0';
    SIGNAL Stack : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL stackIn : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL stackEn : STD_LOGIC;

    SIGNAL DataMemoryReadData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ReadDataAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WriteDataAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MemoryWriteData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL TempWriteData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL TempReadData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL counter : STD_LOGIC := '0';
    SIGNAL DataMemoryWrongAddress : STD_LOGIC;
    SIGNAL MemoryEn: STD_LOGIC;
    SIGNAL TempEn: STD_LOGIC;
    SIGNAL Temp: STD_LOGIC;

    SIGNAL ProtectedFlagRegReadData : STD_LOGIC;
    SIGNAL ProtectedFlagRegWrongAddress : STD_LOGIC;

BEGIN
    TempEn <= MemoryEnable AND NOT ProtectedFlagRegReadData AND MemoryWrite;

    DataMemoryInstance : Data_Memory
        GENERIC MAP (n => 32)
        PORT MAP (
            Clk => clk,
            Rst => rst,
            WriteEnable => MemoryWrite,
            ReadEnable => MemoryRead,
            ReadAddress => ReadDataAddress,
            WriteAddress => WriteDataAddress,
            ReadData => DataMemoryReadData,
            WriteData => MemoryWriteData,
            WrongAddress => DataMemoryWrongAddress
        );


    StackRegInstance : StackReg
        GENERIC MAP (n => 32)
        PORT MAP (
            d => stackIn,
            q => Stack,
            clk => clk,
            rst => rst,
            en => en
        );

        stackIn <= Stack WHEN SP = "000" ELSE
                std_logic_vector(unsigned(Stack) + 1) WHEN SP = "001" AND rst = '0' ELSE
                std_logic_vector(unsigned(Stack) + 2) WHEN SP = "010" AND rst = '0' ELSE
                std_logic_vector(unsigned(Stack) - 1) WHEN SP = "011" AND rst = '0' ELSE
                std_logic_vector(unsigned(Stack) - 2) WHEN SP = "100" AND rst = '0' ELSE
                std_logic_vector(unsigned(Stack) - 4) WHEN SP = "101" AND rst = '0' ELSE
                Stack;

    ProtectedFlagRegInstance : ProtectedFlagReg
        GENERIC MAP (n => 32)
        PORT MAP (
            Clk => clk,
            Rst => rst,
            WriteEnable => MemoryWrite,
            ReadEnable => MemoryRead,
            ReadAddress => ReadDataAddress,
            WriteAddress => WriteDataAddress,
            ReadData => ProtectedFlagRegReadData,
            WriteData => ProtectedFlag, 
            WrongAddress => ProtectedFlagRegWrongAddress
        );

    WrongAddress <= DataMemoryWrongAddress OR ProtectedFlagRegWrongAddress OR ProtectedFlagRegReadData;

    MemoryOut <= (OTHERS => '0') WHEN rst = '1' ELSE
                 DataMemoryReadData WHEN MemoryRead = '1' AND rst = '0';

    -- TempReadData <= std_logic_vector(unsigned(pcPlus) - 1) WHEN counter = '0' ELSE
    --                  "0000000000000000000000000000" & FlagReg;

    ReadDataAddress <= ALUOut WHEN MemoryEnable = '1' AND MemoryAddress = "000" ELSE
                       Stack WHEN MemoryEnable = '1' AND MemoryAddress = "001" ELSE
                       std_logic_vector(unsigned(Stack) + 1) WHEN MemoryEnable = '1' AND MemoryAddress = "010" ELSE
                       std_logic_vector(unsigned(Stack) + 2) WHEN MemoryEnable = '1' AND MemoryAddress = "011" ELSE
                       std_logic_vector(unsigned(Stack) - 2) WHEN MemoryEnable = '1' AND MemoryAddress = "100" ELSE
                       (OTHERS => '0');

    WriteDataAddress <= ALUOut WHEN MemoryEnable = '1' AND MemoryAddress = "000" ELSE
                        Stack WHEN MemoryEnable = '1' AND MemoryAddress = "001" ELSE
                        std_logic_vector(unsigned(Stack) + 1) WHEN MemoryEnable = '1' AND MemoryAddress = "010" ELSE
                        std_logic_vector(unsigned(Stack) + 2) WHEN MemoryEnable = '1' AND MemoryAddress = "011" ELSE
                        std_logic_vector(unsigned(Stack) - 2) WHEN MemoryEnable = '1' AND MemoryAddress = "100" ELSE
                        (OTHERS => '0');

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            counter <= '0';
        ELSIF rising_edge(clk) THEN
            IF CALLIntSTD = "01" OR RET = "10" THEN
                counter <= NOT counter;
                INTDetected <= NOT counter;
            END IF;
        END IF;
    END PROCESS;
     
    TempWriteData <= std_logic_vector(unsigned(pcPlus) - 1) WHEN counter = '0' ELSE
                     "0000000000000000000000000000" & FlagReg;

    MemoryWriteData <= pcPlus WHEN MemoryWrite = '1' AND CALLIntSTD = "00" ELSE
                       TempWriteData WHEN MemoryWrite = '1' AND CALLIntSTD = "01" ELSE
                       SecondOperand WHEN MemoryWrite = '1' AND CALLIntSTD = "10" ELSE
                       SecondOperand WHEN MemoryWrite = '1' AND CALLIntSTD = "11" ELSE
                       (OTHERS => '0');

    ProtectedFlag <= ProtectedFlagRegReadData WHEN FreeProtectedStore = "00" ELSE
                    '0' WHEN FreeProtectedStore = "01" ELSE
                    '1' WHEN FreeProtectedStore = "10" ELSE
                    ProtectedFlagRegReadData WHEN FreeProtectedStore = "11" ELSE
                    ProtectedFlagRegReadData;

    FlushAllBack <= '1' WHEN RET = "01" ELSE '0';
    FlushINT_RTI <= '1' WHEN CALLIntSTD = "01" OR RET = "10" ELSE '0';
    FlagRegOut <= DataMemoryReadData(3 downto 0) WHEN (CALLIntSTD = "01" OR RET = "10") and counter = '0';

END Memory_Architecture;
