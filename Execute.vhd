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
        FlagFeedbackCarry,FlagFeedbackNeg,FlagFeedbackZero : IN std_logic;
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
            FlagFeedbackCarry,FlagFeedbackNeg,FlagFeedbackZero : IN std_logic; 
            ALUout : OUT std_logic_vector(n-1 downto 0)
        );
    END component;
    --The FlagReg component
    component FlagReg IS
    PORT( 
        clk,rst,en : IN std_logic;
        d : IN std_logic_vector(3 DOWNTO 0);
        q : OUT std_logic_vector(3 DOWNTO 0));
    END component; 
    --The signals used in the Execute stage
    signal zero_flag_sig, neg_flag_sig, carry_flag_sig, overflow_flag_sig : std_logic;
    signal flags : std_logic_vector(3 downto 0);
begin
    flags <= zero_flag_sig & neg_flag_sig & carry_flag_sig & overflow_flag_sig;
    --The ALU Mapping
    ALU1: ALU PORT MAP(
        Reg1 => Reg1,
        Reg2 => Reg2,
        ALU_selector => ALU_selector,
        carry_flag => carry_flag_sig,
        neg_flag => neg_flag_sig,
        zero_flag => zero_flag_sig,
        overflow_flag => overflow_flag_sig,
        FlagFeedbackCarry => FlagFeedbackCarry,
        FlagFeedbackNeg => FlagFeedbackNeg,
        FlagFeedbackZero => FlagFeedbackZero,
        ALUout => ALUout
    );
    --The FlagReg Mapping
    FlagReg1: FlagReg PORT MAP(
        clk => clk,
        rst => rst,
        en => en,
        d => flags,
        q => FlagReg_out
    );
  
  
end Execute_Arch;