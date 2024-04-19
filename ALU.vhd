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
        ALUout : OUT std_logic_vector(n-1 downto 0)
    );
END ENTITY ALU;


ARCHITECTURE struct OF ALU IS
    SIGNAL ALUout_sig : std_logic_vector(n-1 downto 0);
    CONSTANT zero_vector : std_logic_vector(n-1 downto 0) := (others => '0');

BEGIN
    Process(Reg1, Reg2, ALU_selector,ALUout_sig)
    BEGIN
        CASE ALU_selector IS
            WHEN "0000" =>   -- NOT operation
                ALUout_sig <= NOT Reg1;  
            WHEN "0001" =>   -- NEG operation
                ALUout_sig <= std_logic_vector(to_unsigned(0, ALUout_sig'length) - unsigned(Reg1));  
            WHEN "0010" =>   -- INC operation
                ALUout_sig <= std_logic_vector(unsigned(Reg1) + 1);  
            WHEN "0011" =>   -- DEC operation
                ALUout_sig <= std_logic_vector(unsigned(Reg1) - 1); 
            WHEN "0100" =>   -- ADD operation
                ALUout_sig <= std_logic_vector(unsigned(Reg1) + unsigned(Reg2));  
            WHEN "0101" =>   -- SUB operation
                ALUout_sig <= std_logic_vector(unsigned(Reg1) - unsigned(Reg2));  
            WHEN "0110" =>   -- AND operation
                ALUout_sig <= Reg1 AND Reg2;  
            WHEN "0111" =>   -- XOR operation
                ALUout_sig <= Reg1 XOR Reg2;  
            WHEN "1000" =>   -- OR operation
                ALUout_sig <= Reg1 OR Reg2; 
            WHEN "1001" =>   --CMP Operation
                ALUout_sig <= std_logic_vector(unsigned(Reg1) - unsigned(Reg2));
            WHEN "1010" =>   -- LDD operation
                ALUout_sig <= std_logic_vector(unsigned(Reg1) + unsigned(Reg2));
            WHEN "1011" =>   -- STD operation
                ALUout_sig <= std_logic_vector(unsigned(Reg1) + unsigned(Reg2)); 
            WHEN "1100" =>   -- ADDI Operation
                ALUout_sig <=  std_logic_vector(unsigned(Reg1) + unsigned(Reg2));
            WHEN "1101" =>   -- SUBI Operation
                ALUout_sig <=  std_logic_vector(unsigned(Reg1) - unsigned(Reg2));

            WHEN OTHERS =>
                ALUout_sig <= Reg1;  -- Default case (NOP)
        END CASE;

        -- Check for zero flag
        IF ALUout_sig = zero_vector THEN
            zero_flag <= '1';
        ELSE
            zero_flag <= '0';
        END IF;
        -- Check for negative flag
	    neg_flag <= ALUout_sig(31);
        -- Check for carry flag
        IF ALU_selector = "0100" AND ALU_selector/="1001" AND ALU_selector/="1010" AND ALU_selector/="1011" AND (unsigned(Reg1) + unsigned(Reg2)) > to_unsigned(2**n-1, n) THEN
            carry_flag <= '1';
        ELSE
            carry_flag <= '0';
        END IF;
        -- Check for overflow flag
        IF ALU_selector = "0100"  AND ALU_selector/="1001" AND ALU_selector/="1010" AND ALU_selector/="1011" AND (Reg1(31) = Reg2(31)) AND (ALUout_sig(31) /= Reg1(31)) THEN
            overflow_flag <= '1';
        ELSE
            overflow_flag <= '0';
        END IF;
        ALUout<=ALUout_sig;  -- Assign ALU output
END PROCESS;
END ARCHITECTURE struct;