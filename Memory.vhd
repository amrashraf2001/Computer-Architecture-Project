LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Memory is
    GENERIC(n : integer :=32);
    port (
        clk : in std_logic;
        en,rst : IN std_logic;
        MemoryWrite : IN std_logic;
        MemoryRead : IN std_logic;
        MemoryEnable : IN std_logic;
        MemoryAddress : IN std_logic_vector(n-1 DOWNTO 0);
        MemoryWriteData : IN std_logic_vector(n-1 DOWNTO 0);
        ALUOut : IN std_logic_vector(n-1 DOWNTO 0);
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
        Clk, Rst, WriteEnable : IN STD_LOGIC;
        ReadAddress, WriteAddress : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        ReadData : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
        WriteData : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
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
    signal StackPointer : std_logic_vector(n-1 DOWNTO 0);
    

end architecture Memory_Arch;