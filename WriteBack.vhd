LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


entity WriteBack is
    GENERIC(n : integer :=32);
    Port ( 
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        ALUout : IN STD_LOGIC_VECTOR(n-1 downto 0);
        data_in : IN STD_LOGIC_VECTOR(n-1 downto 0); -- Input port
        MemoryOut : IN STD_LOGIC_VECTOR(n-1 downto 0);
        WriteBackSource : IN STD_LOGIC_VECTOR(1 downto 0);
        Mux_result : OUT STD_LOGIC_VECTOR(n-1 downto 0)

    );
end WriteBack;


architecture WriteBack_arch of WriteBack is
    signal mux_output : std_logic_vector(n-1 downto 0); 

begin

    -- multiplexer process to select the input
    mux_output <= ALUout WHEN WriteBackSource = "10" else
              MemoryOut WHEN WriteBackSource = "01" else
              data_in WHEN WriteBackSource = "00" else
              (others => '0');
    Mux_result <= mux_output;
end WriteBack_arch;