LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Memory IS
    GENERIC (n : INTEGER := 32);
    PORT (
        clk : IN std_logic;
        en,rst : IN std_logic;
        MemoryWrite1 : IN std_logic;
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

    SIGNAL ProtectedFlag : STD_LOGIC;
    SIGNAL Stack : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL DataMemoryReadData : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DataMemoryWrongAddress : STD_LOGIC;

    SIGNAL ProtectedFlagRegReadData : STD_LOGIC;
    SIGNAL ProtectedFlagRegWrongAddress : STD_LOGIC;

BEGIN
    DataMemoryInstance : Data_Memory
        GENERIC MAP (n => 32)
        PORT MAP (
            Clk => clk,
            Rst => rst,
            WriteEnable => MemoryWrite1,
            ReadAddress => MemoryAddress,
            WriteAddress => MemoryAddress,
            ReadData => DataMemoryReadData,
            WriteData => MemoryWriteData,
            WrongAddress => DataMemoryWrongAddress
        );

    StackRegInstance : StackReg
        GENERIC MAP (n => 32)
        PORT MAP (
            d => DataMemoryReadData,
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
            WriteEnable => MemoryWrite1,
            ReadAddress => MemoryAddress,
            WriteAddress => MemoryAddress,
            ReadData => ProtectedFlagRegReadData,
            WriteData => '1',  -- Assuming writing '1' means setting the protected flag
            WrongAddress => ProtectedFlagRegWrongAddress
        );

    WrongAddress <= DataMemoryWrongAddress OR ProtectedFlagRegWrongAddress;

    ProtectedFlag <= ProtectedFlagRegReadData;

    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            MemoryOut <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF MemoryEnable = '1' THEN
                CASE MemoryAddress IS
                    WHEN "00" =>
                        MemoryOut <= ALUOut;
                    WHEN "01" =>
                        MemoryOut <= Stack;
                    WHEN "10" =>
                        MemoryOut <= std_logic_vector(unsigned(Stack) + 1);
                    WHEN "11" =>
                        MemoryOut <= std_logic_vector(unsigned(Stack) + 2);
                    WHEN OTHERS =>
                        MemoryOut <= (OTHERS => '0');
                        WrongAddress <= '1';
                END CASE;

                CASE FreeProtectedStore IS
                    WHEN "00" =>
                        ProtectedFlag <= ProtectedFlag;
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
