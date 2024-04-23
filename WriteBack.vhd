LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


entity WriteBack is
    GENERIC(n : integer :=32);
    Port ( 
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ALUout : IN STD_LOGIC_VECTOR(n-1 downto 0);
        data_in : IN STD_LOGIC_VECTOR(n-1 downto 0); -- Input port
        MemoryOut : IN STD_LOGIC_VECTOR(n-1 downto 0);
        -- OutputPortEnable : IN STD_LOGIC;-- Output port enable
        WriteBackSource : IN STD_LOGIC_VECTOR(1 downto 0);
        -- OutPutPort : OUT STD_LOGIC_VECTOR(n-1 downto 0); -- Output port
        Mux_result : OUT STD_LOGIC_VECTOR(n-1 downto 0)
        -- write_enable : in STD_LOGIC;
        -- WriteBackAddress1 : out STD_LOGIC_VECTOR(4 downto 0);
        -- WriteBackAddress2 : out STD_LOGIC_VECTOR(4 downto 0);
        -- second_operand : out STD_LOGIC_VECTOR(31 downto 0)

    );
end WriteBack;


architecture WriteBack_arch of WriteBack is
    signal mux_output : std_logic_vector(n-1 downto 0); 

begin

    -- multiplexer process to select the input
    mux_output <= ALUout WHEN WriteBackSource = "00" else
              MemoryOut WHEN WriteBackSource = "01" else
              data_in WHEN WriteBackSource = "10" else
              (others => '0');

    -- -- Write to RegFile process
    -- process(clk, reset)
    -- begin
    --     if reset = '1' then
    --         -- Reset signals
    --         write_address_1 <= (others => '0');
    --         write_address_2 <= (others => '0');
    --         write_data1 <= (others => '0');
    --         write_data2 <= (others => '0');
    --     elsif rising_edge(clk) then
    --         -- Propagate signals
    --         write_address_1 <= WriteBackAddress1;
    --         write_enable_signal <= write_enable; 
    --         write_address_2 <= WriteBackAddress2;
    --         write_data1 <= mux_output;      -- Output of MUX
    --         write_data2 <= second_operand;  -- Second operand
    --     end if;
    -- end process;

    -- -- Output data to RegFile
    -- wb: RegFile PORT MAP(
    --     Clk => clk,
    --     Rst => reset,
    --     WriteEnable => write_enable_signal,
    --     ReadAddress1 => read_address_1,    
    --     ReadAddress2 => read_address_2,    
    --     WriteAddress1 => write_address_1,
    --     WriteAddress2 => write_address_2,
    --    -- ReadData1 => mux_output,            -- Data from MUX output
    --    -- ReadData2 => second_operand,        
    --     WriteData1 => mux_output,           -- Data from MUX output
    --     WriteData2 => second_operand       
    -- );
        Mux_result <= mux_output;
end WriteBack_arch;