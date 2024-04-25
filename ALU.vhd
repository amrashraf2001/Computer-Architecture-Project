library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU is
    GENERIC (
        n : integer := 32
    );
    PORT (
        Reg1, Reg2: IN std_logic_vector(n-1 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        carry_flag, neg_flag, zero_flag, overflow_flag : OUT std_logic;
        FlagFeedbackCarry,FlagFeedbackNeg,FlagFeedbackZero,FlagFeedbackOverflow : IN std_logic; 
        ALUout : OUT std_logic_vector(n-1 downto 0)
    );
END ENTITY ALU;


ARCHITECTURE struct OF ALU IS
    SIGNAL ALUout_sig : std_logic_vector(32 downto 0);
    CONSTANT zero_vector : std_logic_vector(n-1 downto 0) := (others => '0');
    signal extendedA,extendedB:std_logic_vector(32 downto 0);
BEGIN
    extendedA <='0' & Reg1(31 DOWNTO 0);
    extendedB <='0' & Reg2(31 DOWNTO 0);
    Process(extendedA, extendedB, ALU_selector,ALUout_sig)
   
    BEGIN
        CASE ALU_selector IS
            WHEN "0000" =>   -- NOT operation
                ALUout_sig <= NOT extendedA;  
            WHEN "0001" =>   -- NEG operation
                ALUout_sig <= std_logic_vector(to_unsigned(0, ALUout_sig'length) - unsigned(extendedA));  
            WHEN "0010" =>   -- INC operation
                ALUout_sig <= std_logic_vector(unsigned(extendedA) + 1);  
            WHEN "0011" =>   -- DEC operation
                ALUout_sig <= std_logic_vector(unsigned(extendedA) - 1); 
            WHEN "0100" =>   -- ADD operation
                ALUout_sig <= std_logic_vector(unsigned(extendedA) + unsigned(extendedB));  
            WHEN "0101" =>   -- SUB operation
                ALUout_sig <= std_logic_vector(unsigned(extendedA) - unsigned(extendedB));  
            WHEN "0110" =>   -- AND operation
                ALUout_sig <= extendedA AND extendedB;  
            WHEN "0111" =>   -- XOR operation
                ALUout_sig <= extendedA XOR extendedB;  
            WHEN "1000" =>   -- OR operation
                ALUout_sig <= extendedA OR extendedB; 
            WHEN "1001" =>   --CMP Operation
                ALUout_sig <= std_logic_vector(unsigned(extendedA) - unsigned(extendedB));
            WHEN "1010" =>   -- LDD operation
                ALUout_sig <= std_logic_vector(unsigned(extendedA) + unsigned(extendedB));
            WHEN "1011" =>   -- STD operation
                ALUout_sig <= std_logic_vector(unsigned(extendedA) + unsigned(extendedB)); 
            WHEN "1100" =>   -- ADDI Operation
                ALUout_sig <=  std_logic_vector(unsigned(extendedA) + unsigned(extendedB));
            WHEN "1101" =>   -- SUBI Operation
                ALUout_sig <=  std_logic_vector(unsigned(extendedA) - unsigned(extendedB));
            WHEN "1110" =>   -- MOV operation
                ALUout_sig <= extendedA;
            WHEN "1111" =>   -- LDM operation
                ALUout_sig <= extendedB;
            WHEN OTHERS =>
                ALUout_sig <= extendedA;  -- Default case (NOP)
        END CASE;

        -- -- Check for overflow flag
        -- IF (ALU_selector = "0100"  or ALU_selector ="0101" or ALU_selector ="1100" or ALU_selector ="1101" or ALU_selector = "0010" or ALU_selector = "0011") AND (extendedA(31) = extendedB(31)) AND (ALUout_sig(31) /= extendedA(31)) THEN
        --     overflow_flag <= '1';
        -- ELSE
        --     overflow_flag <= '0';
        -- END IF;
        ALUout<=ALUout_sig(31 downto 0);  -- Assign ALU output
END PROCESS;
        -- Check for Overflow flag
        overflow_flag <= '1' when (ALU_selector = "0100"  or ALU_selector ="0101" or ALU_selector ="1100" or ALU_selector ="1101" or ALU_selector = "0010" or ALU_selector = "0011") AND (extendedA(31) = extendedB(31)) AND (ALUout_sig(31) /= extendedA(31))
        else '0' when (ALU_selector = "0100"  or ALU_selector ="0101" or ALU_selector ="1100" or ALU_selector ="1101" or ALU_selector = "0010" or ALU_selector = "0011") AND (extendedA(31) = extendedB(31)) AND (ALUout_sig(31) = extendedA(31))
        else FlagFeedbackOverflow;
        -- Check for zero flag
        zero_flag <= '1' when ALUout_sig(31 downto 0) = zero_vector and ALU_selector /= "1010" and ALU_selector /= "1011" and ALU_selector /= "1110" and ALU_selector /= "1111"
        else '0' when ALUout_sig(31 downto 0) /= zero_vector and ALU_selector /= "1010" and ALU_selector /= "1011" and ALU_selector /= "1110" and ALU_selector /= "1111"
        else FlagFeedbackZero;
        -- Check for negative flag
	    --neg_flag <= ALUout_sig(31);
        neg_flag <= '1' when ALUout_sig(31) = '1' and ALU_selector /= "1010" and ALU_selector /= "1011" AND ALU_selector /= "1111" AND ALU_selector /= "1110"
        else '0' when ALUout_sig(31) = '0' and ALU_selector /= "1010" and ALU_selector /= "1011" AND ALU_selector /= "1111" AND ALU_selector /= "1110"
        else FlagFeedbackNeg;
        -- neg_flag <= '1' when ALU_selector /= "1010" and ALU_selector /= "1011" AND ALU_selector /= "1111" AND ALU_selector /= "1110" AND (to_integer(signed(ALUout_sig(31 downto 0))) < 0)
        --     else '0' when ALU_selector /= "1010" and ALU_selector /= "1011" AND ALU_selector /= "1111" AND ALU_selector /= "1110" AND (to_integer(signed(ALUout_sig(31 downto 0))) >= 0)
        --     else FlagFeedbackNeg;
        -- Check for carry flag
        -- Check for carry flag during CMP operation
        carry_flag <= '1' when (ALU_selector = "1001" or ALU_selector = "1101" or ALU_selector = "0101" or ALU_selector = "0011") and (ALUout_sig(31) = '1')
        else ALUout_sig(32) when ALU_selector = "0100"  or ALU_selector = "1100"  or ALU_selector = "0010" 
        else '0' when (ALU_selector = "1001" or ALU_selector = "1101" or ALU_selector = "0101" or ALU_selector = "0011") and (ALUout_sig(31) = '0')
        else FlagFeedbackCarry;
END ARCHITECTURE struct;