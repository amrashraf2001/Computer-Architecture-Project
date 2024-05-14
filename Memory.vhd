LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Memory IS
    GENERIC (n : INTEGER := 32);
    PORT (
        clk : IN std_logic;
        en,rst : IN std_logic;
        MemoryWrite : IN std_logic;
        MemoryRead : IN std_logic;
        MemoryEnable : IN std_logic;
        MemoryAddress : IN std_logic_vector(2 DOWNTO 0);
        --MemoryWriteData : IN std_logic_vector(n-1 DOWNTO 0);
        CALLIntSTD: IN std_logic_vector(1 DOWNTO 0);
        RET: IN std_logic_vector(1 DOWNTO 0);
        ALUOut : IN std_logic_vector(n-1 DOWNTO 0);
        pcPlus: IN std_logic_vector(n-1 DOWNTO 0);
        SecondOperand : IN std_logic_vector(n-1 DOWNTO 0);
        SP: IN std_logic_vector(2 DOWNTO 0);
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

    SIGNAL ProtectedFlag : STD_LOGIC:= '0';
    SIGNAL Stack : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL stackIn : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL stackEn : STD_LOGIC;

    SIGNAL DataMemoryReadData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ReadDataAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WriteDataAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL MemoryWriteData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DataMemoryWrongAddress : STD_LOGIC;

    SIGNAL ProtectedFlagRegReadData : STD_LOGIC;
    SIGNAL ProtectedFlagRegWrongAddress : STD_LOGIC;

BEGIN
    DataMemoryInstance : Data_Memory
        GENERIC MAP (n => 32)
        PORT MAP (
            Clk => clk,
            Rst => rst,
            WriteEnable => MemoryWrite,
            ReadAddress => ReadDataAddress,
            WriteAddress => WriteDataAddress,
            ReadData => DataMemoryReadData,
            WriteData => MemoryWriteData,
            WrongAddress => DataMemoryWrongAddress
        );

    stackIn <= stack WHEN SP = "000" ELSE
                std_logic_vector(unsigned(Stack) + 1) WHEN SP = "001" ELSE
                std_logic_vector(unsigned(Stack) + 2) WHEN SP = "010" ELSE
                std_logic_vector(unsigned(Stack) - 1) WHEN SP = "011" ELSE
                std_logic_vector(unsigned(Stack) - 2) WHEN SP = "100" ELSE
                std_logic_vector(unsigned(Stack) - 4) WHEN SP = "101" ELSE
               stack;

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

    WrongAddress <= DataMemoryWrongAddress OR ProtectedFlagRegWrongAddress;

    --ProtectedFlag <= ProtectedFlagRegReadData;

    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            MemoryOut <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF MemoryEnable = '1' THEN
                CASE MemoryAddress IS
                    WHEN "000" =>
                        ReadDataAddress <= ALUOut;
                        WriteDataAddress <= ALUOut;
                    WHEN "001" =>
                        ReadDataAddress <= Stack;
                        WriteDataAddress <= Stack;
                    WHEN "010" =>
                        ReadDataAddress <= std_logic_vector(unsigned(Stack) + 1);
                        WriteDataAddress <= std_logic_vector(unsigned(Stack) + 1);
                    WHEN "011" =>
                        ReadDataAddress <= std_logic_vector(unsigned(Stack) + 2);
                        WriteDataAddress <= std_logic_vector(unsigned(Stack) + 2);
                    WHEN "100" =>
                        ReadDataAddress <= std_logic_vector(unsigned(Stack) - 2);
                        WriteDataAddress <= std_logic_vector(unsigned(Stack) - 2);
                    WHEN OTHERS =>
                        MemoryOut <= (OTHERS => '0');
                        WrongAddress <= '1';
            END CASE;

            IF MemoryWrite = '1' THEN
                CASE CALLIntSTD IS
                    WHEN "00" =>
                        MemoryWriteData <= pcPlus;
                    WHEN "01" =>
                        MemoryWriteData <= std_logic_vector(unsigned(pcPlus) - 1);
                    WHEN "10" =>
                        MemoryWriteData <= secondOperand;
                    WHEN OTHERS =>
                        MemoryWriteData <= secondOperand;
                        WrongAddress <= '1';
                END CASE;   
            END IF;

            IF MemoryRead = '1' THEN
                MemoryOut <= DataMemoryReadData;
            END IF;


            CASE FreeProtectedStore IS
                WHEN "00" =>
                    ProtectedFlag <= ProtectedFlagRegReadData;
                WHEN "01" =>
                    ProtectedFlag <= '0';
                WHEN "10" =>
                    ProtectedFlag <= '1';
                WHEN "11" =>
                    -- Store operation, check if address is protected
                    IF ProtectedFlag = '1' THEN
                        WrongAddress <= '1';
                    END IF;
                WHEN OTHERS =>
                    ProtectedFlag <= ProtectedFlag;
            END CASE;
            END IF;
        END IF;
    END PROCESS;

END Memory_Architecture;
