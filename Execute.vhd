LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Execute is
    GENERIC(n : integer :=32);
    Port ( 
        clk : in STD_LOGIC;
        en,rst : IN std_logic;
        Reg1, Reg2 : IN std_logic_vector(n-1 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        ALUout : OUT std_logic_vector(n-1 downto 0);
        FlagReg_out : OUT std_logic_vector(3 downto 0)
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
    --The signals used in the Execute stage
    --signal zero_flag_sig, neg_flag_sig, carry_flag_sig, overflow_flag_sig : STD_LOGIC;
    signal flags : STD_LOGIC_VECTOR(3 downto 0):="0000";
    signal FlagReg_out_internal : std_logic_vector(3 downto 0);
    Signal Coutcombtemp,Negcombtemp,Zerocombtemp,Overflowcombtemp: std_logic; 
begin
    --The ALU Mapping
    ALU1: ALU PORT MAP(
        Reg1 => Reg1,
        Reg2 => Reg2,
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
    -- flags <= zero_flag_sig & neg_flag_sig & FlagReg_out_internal(1 downto 0) WHEN ALU_selector ="1100" -- IN CMP case ZERO & NEGATIVE flags only
    -- ELSE flags WHEN ALU_selector="1010" OR ALU_selector="1011" or ALU_selector = "1110" --IN LDD & STD & MOV cases
    -- ELSE zero_flag_sig & neg_flag_sig & carry_flag_sig & overflow_flag_sig;    --Conctetaing the flags for thr flag register input  
    flags <= Zerocombtemp & Negcombtemp & Coutcombtemp & Overflowcombtemp;
    FlagReg_out <= FlagReg_out_internal; --TODO: zabat 7ewarat el branching w probagation w kalam keber kda

end Execute_Arch;