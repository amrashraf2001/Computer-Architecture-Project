LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Memory is
    GENERIC(n : integer :=32);
    port (
        clk : in std_logic;
        en,rst : IN std_logic;
        MemoryWrite1 : IN std_logic;
        MemoryWrite2 : IN std_logic;
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
end entity Memory;

architecture Memory_Arch of Memory is
    -- Component Declaration
    --Data_Memory Component
    component Data_Memory IS
    PORT(
        Clk, Rst, WriteEnable1, WriteEnable2 : IN STD_LOGIC;
        ReadAddress, WriteAddress1, WriteAddress2 : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        ReadData : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        WriteData1, WriteData2 : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        WrongAddress : OUT STD_LOGIC
    );
    END component;
    --ProtectedFlagReg Component
    component ProtectedFlagReg IS
    PORT(
        Clk, Rst, WriteEnable : IN STD_LOGIC;
        ReadAddress, WriteAddress : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        ReadData : OUT STD_LOGIC;
        WriteData : IN STD_LOGIC;
		WrongAddress : OUT STD_LOGIC
    );
    END component;
    --StackReg Component
    component StackReg IS
    PORT( 
        d : IN std_logic_vector (n-1 downto 0);
        q : OUT std_logic_vector (n-1 downto 0);
        clk,rst,en : IN std_logic );
    END component;
    signal ProtectedFlagsInput : std_logic_vector(n-1 DOWNTO 0);
    signal ProtectedFlagsOutput : std_logic;
    signal StackPointerInput : std_logic_vector(n-1 DOWNTO 0);
    signal StackPointerOutput: std_logic_vector(n-1 DOWNTO 0);
    signal DataMemoryOutput: std_logic_vector(n-1 DOWNTO 0);
    signal WriteAddress1_sig: std_logic_vector(n-1 DOWNTO 0);
    signal WriteAddress2_sig: std_logic_vector(n-1 DOWNTO 0);
    signal WriteData1: std_logic_vector(n-1 DOWNTO 0);

    begin
    Data_Memory1 : Data_Memory
    PORT MAP (
        Clk => Clk,
        Rst => Rst, 
        WriteEnable1 =>MemoryWrite1 , -- replace with your actual write enable 1 signal
        WriteEnable2 => MemoryWrite2, -- replace with your actual write enable 2 signal
        ReadAddress => WriteAddress1_sig, -- replace with your actual read address signal
        WriteAddress1 => WriteAddress1_sig, -- replace with your actual write address 1 signal
        WriteAddress2 =>WriteAddress2_sig , -- replace with your actual write address 2 signal
        ReadData => DataMemoryOutput,
        WriteData1 => SecondOperand, -- replace with your actual write data 1 signal
        WriteData2 => SecondOperand, -- replace with your actual write data 2 signal
        WrongAddress => WrongAddress -- replace with your actual wrong address signal
    );
	StackReg1:StackReg 
    port map (
        d => StackPointerInput,
        q => StackPointerOutput,
        clk => clk,
        rst => rst,
        en => MemoryEnable
    );
    WriteAddress1_sig <= ALUOut WHEN MemoryAddress ="00"
    ELSE  StackPointerOutput WHEN MemoryAddress ="01"
    ELSE  std_logic_vector(unsigned(StackPointerOutput) + 1) WHEN MemoryAddress ="10"
    ELSE std_logic_vector(unsigned(StackPointerOutput) + 2);

    WriteAddress2_sig <= std_logic_vector(unsigned(StackPointerOutput) - 2);
    StackPointerInput <= std_logic_vector(unsigned(StackPointerOutput) + 1) WHEN SP="000"
    ELSE std_logic_vector(unsigned(StackPointerOutput) + 2) WHEN SP = "001"
    ELSE std_logic_vector(unsigned(StackPointerOutput) - 1) WHEN SP="010"
    ELSE std_logic_vector(unsigned(StackPointerOutput) - 2) WHEN SP="011"
    ELSE std_logic_vector(unsigned(StackPointerOutput) - 4) WHEN SP="100"
    ELSE StackPointerOutput WHEN SP="101"
    ELSE (others=>'0');

    --TODO: THINK OF MUX INPUTS CALL/STD
    WriteData1<= SecondOperand;

    MemoryOut <= DataMemoryOutput; 
end architecture Memory_Arch;