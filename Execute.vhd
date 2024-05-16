LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Execute is
    GENERIC(n : integer :=32);
    Port ( 
        clk : in STD_LOGIC;
        en,rst : IN std_logic;
        opcode : IN std_logic_vector(5 downto 0);
        Reg1, Reg2 : IN std_logic_vector(n-1 downto 0);
        Forwarded_Src_1_EX_MEM, Forwarded_Src_1_MEM_WB : IN std_logic_vector(n-1 downto 0);
        Forwarded_Src_2_EX_MEM, Forwarded_Src_2_MEM_WB : IN std_logic_vector(n-1 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        Destination_Reg_EX_MEM, Destination_Reg_MEM_WB: IN std_logic_vector(2 downto 0);
        Src1_From_ID_EX, Src2_From_ID_EX : IN std_logic_vector(2 downto 0);
        WBenable_EX_MEM, WBenable_MEM_WB : IN std_logic;
        WBsource_EX_MEM : IN std_logic_vector(1 downto 0);
        swap : IN std_logic;
        PredictorIn : IN std_logic; -- gayaly mn el decode stage
        ALUout : OUT std_logic_vector(n-1 downto 0);
        FlagReg_out : OUT std_logic_vector(3 downto 0);
        FlushOut : OUT std_logic;
        NotTakenWrongBranch : OUT std_logic; -- el and eli fo2 not taken w kan el mafroud a take it
        TakenWrongBranch : OUT std_logic -- el and eli ta7t taken w kan el mafroud a not take it
    );
end Execute;
architecture Execute_Arch of Execute is
    --Adding the components of the Execute stage
    --The ALU component
    component ALU is
        PORT (
            Reg1, Reg2: IN std_logic_vector(n-1 downto 0);
            ALU_selector : IN std_logic_vector(3 downto 0);
            carry_flag, neg_flag, zero_flag, overflow_flag : OUT std_logic;
            FlagFeedbackCarry,FlagFeedbackNeg,FlagFeedbackZero,FlagFeedbackOverflow : IN std_logic; 
            ALUout : OUT std_logic_vector(n-1 downto 0)
        );
    END component;
    --The FlagReg component
    component FlagReg IS
        PORT( 
            clk,rst,en : IN std_logic;
            d : IN std_logic_vector(3 DOWNTO 0);
            q : OUT std_logic_vector(3 DOWNTO 0));
            --q_internal : OUT std_logic_vector(3 DOWNTO 0)); 
    END COMPONENT;
    COMPONENT ForwardingUnit is
        port (
            clk : in std_logic;
            rst : in std_logic;
            swap: in std_logic;
            WBenable_EX_MEM , WBenable_MEM_WB : in std_logic; --enables for the write back stage
            WBsource_EX_MEM : in std_logic_vector(1 downto 0);  -- for load use case
            DestREG_EX_MEM , DestREG_MEM_WB : in std_logic_vector(2 downto 0); --destination register for the write back stage
            Src1_From_ID_EX , Src2_From_ID_EX : in std_logic_vector(2 downto 0); --source registers from the execute stage
            Selector_Mux1 , Selector_Mux2 : out std_logic_vector (1 downto 0); --selecting the source for the mux
            stall : out std_logic
        );
    END COMPONENT;
    
    --The signals used in the Execute stage
    --signal zero_flag_sig, neg_flag_sig, carry_flag_sig, overflow_flag_sig : STD_LOGIC;
    signal flags : STD_LOGIC_VECTOR(3 downto 0):="0000";
    signal FlagReg_out_internal : std_logic_vector(3 downto 0);
    Signal Coutcombtemp,Negcombtemp,Zerocombtemp,Overflowcombtemp: std_logic;
    signal Selector_Mux1, Selector_Mux2 : std_logic_vector(1 downto 0);
    signal stall : std_logic;
    signal Mux1_Output, Mux2_Output : std_logic_vector(n-1 downto 0); -- MUX outputs from FU selectors and forwarded values

begin
    --The ALU Mapping
    ALU1: ALU PORT MAP(
        Reg1 => Mux1_Output,
        Reg2 => Mux2_Output,
        ALU_selector => ALU_selector,
        carry_flag => Coutcombtemp,
        neg_flag => Negcombtemp,
        zero_flag => Zerocombtemp,
        overflow_flag => Overflowcombtemp,
        FlagFeedbackCarry => FlagReg_out_internal(1),
        FlagFeedbackNeg => FlagReg_out_internal(2),
        FlagFeedbackZero => FlagReg_out_internal(3),
        FlagFeedbackOverflow => FlagReg_out_internal(0),
        ALUout => ALUout
    );

   
    --The FlagReg Mapping
    FlagReg1: FlagReg PORT MAP(
        clk => clk,
        rst => rst,
        en => en,
        d => flags,
        --zero_flag => zero_flag_sig,
        --neg_flag => neg_flag_sig,
        --carry_flag => carry_flag_sig,
        --overflow_flag => overflow_flag_sig,
        q => FlagReg_out_internal
        --q_internal => FlagReg_out_internal 

    );
    ForwardingUnit1: ForwardingUnit PORT MAP(
    clk => clk,
    rst => rst,
    swap => swap, 
    WBenable_EX_MEM => WBenable_EX_MEM,
    WBenable_MEM_WB => WBenable_MEM_WB, 
    WBsource_EX_MEM => WBsource_EX_MEM, 
    DestREG_EX_MEM => Destination_Reg_EX_MEM, 
    DestREG_MEM_WB => Destination_Reg_MEM_WB, 
    Src1_From_ID_EX => Src1_From_ID_EX,
    Src2_From_ID_EX => Src2_From_ID_EX,
    Selector_Mux1 => Selector_Mux1,
    Selector_Mux2 => Selector_Mux2,
    stall => stall
    );
    -- flags <= zero_flag_sig & neg_flag_sig & FlagReg_out_internal(1 downto 0) WHEN ALU_selector ="1100" -- IN CMP case ZERO & NEGATIVE flags only
    -- ELSE flags WHEN ALU_selector="1010" OR ALU_selector="1011" or ALU_selector = "1110" --IN LDD & STD & MOV cases
    -- ELSE zero_flag_sig & neg_flag_sig & carry_flag_sig & overflow_flag_sig;    --Conctetaing the flags for thr flag register input  
    flags <= Zerocombtemp & Negcombtemp & Coutcombtemp & Overflowcombtemp;
    FlagReg_out <= FlagReg_out_internal; --TODO: zabat 7ewarat el branching w propagation w kalam keber kda
    --Forwarding unit Mux results
    Mux1_Output <= Forwarded_Src_1_EX_MEM WHEN Selector_Mux1 = "00" ELSE
                   Forwarded_Src_1_MEM_WB WHEN Selector_Mux1 = "01" ELSE
                   Forwarded_Src_1_EX_MEM WHEN Selector_Mux1 = "10" ELSE
                     Reg1;

    Mux2_Output <= Forwarded_Src_2_EX_MEM WHEN Selector_Mux2 = "00" ELSE
                     Forwarded_Src_2_MEM_WB WHEN Selector_Mux2 = "01" ELSE
                     Forwarded_Src_2_EX_MEM WHEN Selector_Mux2 = "10" ELSE
                        Reg2;

    NotTakenWrongBranch <= '1' when Zerocombtemp = '1' and PredictorIn = '1' and opcode = "100001" else '0';
    TakenWrongBranch <= '1' when Zerocombtemp = '0' and PredictorIn = '1' and opcode = "100001" else '0';
    FlushOut <= '1' when (Zerocombtemp = '1' and PredictorIn = '1' and opcode = "100001") or (Zerocombtemp = '0' and PredictorIn = '1' and opcode = "100001") else '0';


end Execute_Arch;