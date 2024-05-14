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
        FreeProtectedStore : IN std_logic_vector(1 DOWNTO 0);
        MemoryOut : OUT std_logic_vector(n-1 DOWNTO 0);
        WrongAddress : OUT std_logic
    );
END Memory;

ARCHITECTURE Memory_Architecture OF Memory IS
    COMPONENT Data_Memory IS
        GENERIC (n : INTEGER := 32);
        PORT (
            Clk, Rst, WriteEnable : IN STD_LOGIC;
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
            Clk, Rst, WriteEnable : IN STD_LOGIC;
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
    SIGNAL DataMemoryWrongAddress : STD_LOGIC;
    SIGNAL MemoryEn: STD_LOGIC;
    SIGNAL TempEn: STD_LOGIC;

    SIGNAL ProtectedFlagRegReadData : STD_LOGIC;
    SIGNAL ProtectedFlagRegWrongAddress : STD_LOGIC;

BEGIN
    --TempEn <= MemoryEnable AND MemoryWrite AND NOT ProtectedFlagRegReadData AND NOT DataMemoryWrongAddress AND NOT ProtectedFlagRegWrongAddress;
    --MemoryEn <= '1' when TempEn = '1' AND FreeProtectedStore = "11"
    --else '0';
    --MemoryEn <= MemoryEnable AND NOT (DataMemoryWrongAddress OR ProtectedFlagRegWrongAddress OR ProtectedFlagRegReadData);
    TempEn <= MemoryEnable AND NOT ProtectedFlagRegReadData;
    DataMemoryInstance : Data_Memory
        GENERIC MAP (n => 32)
        PORT MAP (
            Clk => clk,
            Rst => rst,
            WriteEnable => TempEn,
            ReadAddress => ReadDataAddress,
            WriteAddress => WriteDataAddress,
            ReadData => DataMemoryReadData,
            WriteData => MemoryWriteData,
            WrongAddress => DataMemoryWrongAddress
        );

    stackIn <= Stack WHEN SP = "000" ELSE
                std_logic_vector(unsigned(Stack) + 1) WHEN SP = "001" ELSE
                std_logic_vector(unsigned(Stack) + 2) WHEN SP = "010" ELSE
                std_logic_vector(unsigned(Stack) - 1) WHEN SP = "011" ELSE
                std_logic_vector(unsigned(Stack) - 2) WHEN SP = "100" ELSE
                std_logic_vector(unsigned(Stack) - 4) WHEN SP = "101" ELSE
                Stack;

    StackRegInstance : StackReg
        GENERIC MAP (n => 32)
        PORT MAP (
            d => stackIn,
            q => Stack,
            clk => clk,
            rst => rst,
            en => '1'
        );

    ProtectedFlagRegInstance : ProtectedFlagReg
        GENERIC MAP (n => 32)
        PORT MAP (
            Clk => clk,
            Rst => rst,
            WriteEnable => MemoryWrite,
            ReadAddress => ReadDataAddress,
            WriteAddress => WriteDataAddress,
            ReadData => ProtectedFlagRegReadData,
            WriteData => ProtectedFlag, 
            WrongAddress => ProtectedFlagRegWrongAddress
        );

    WrongAddress <= DataMemoryWrongAddress OR ProtectedFlagRegWrongAddress OR ProtectedFlagRegReadData;

    MemoryOut <= (OTHERS => '0') WHEN rst = '1' ELSE
                 DataMemoryReadData WHEN MemoryRead = '1' AND rst = '0';

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

    MemoryWriteData <= pcPlus WHEN MemoryWrite = '1' AND CALLIntSTD = "00" ELSE
                       std_logic_vector(unsigned(pcPlus) - 1) WHEN MemoryWrite = '1' AND CALLIntSTD = "01" ELSE
                       SecondOperand WHEN MemoryWrite = '1' AND CALLIntSTD = "10" ELSE
                       SecondOperand WHEN MemoryWrite = '1' AND CALLIntSTD = "11" ELSE
                       (OTHERS => '0');

    ProtectedFlag <= ProtectedFlagRegReadData WHEN FreeProtectedStore = "00" ELSE
                    '0' WHEN FreeProtectedStore = "01" ELSE
                    '1' WHEN FreeProtectedStore = "10" ELSE
                    ProtectedFlagRegReadData WHEN FreeProtectedStore = "11" ELSE
                    ProtectedFlagRegReadData;

END Memory_Architecture;
