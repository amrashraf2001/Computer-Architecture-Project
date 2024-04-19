library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU is
    GENERIC (
        n : integer := 32
    );
    PORT (
        Reg1, Reg2 ,Imm_value: IN std_logic_vector(n-1 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        carry_flag, neg_flag, zero_flag, overflow_flag : OUT std_logic;
        ALUout : OUT std_logic_vector(n-1 downto 0)
    );
END ENTITY ALU;


ARCHITECTURE struct OF ALU IS
    SIGNAL ALUout_sig : std_logic_vector(n-1 downto 0);
    CONSTANT zero_vector : std_logic_vector(n-1 downto 0) := (others => '0');

BEGIN
    Process(Reg1, Reg2, ALU_selector, Imm_value,ALUout_sig)
    BEGIN
        CASE ALU_selector IS
            WHEN "0000" =>
                ALUout_sig <= NOT Reg1;  -- NOT operation
            WHEN "0001" =>
                ALUout_sig <= std_logic_vector(to_unsigned(0, ALUout_sig'length) - unsigned(Reg1));  -- NEG operation
            WHEN "0010" =>
                ALUout_sig <= std_logic_vector(unsigned(Reg1) + 1);  -- INC operation
            WHEN "0011" =>
                ALUout_sig <= std_logic_vector(unsigned(Reg1) - 1);  -- DEC operation
            WHEN "0100" =>
                ALUout_sig <= std_logic_vector(unsigned(Reg1) + unsigned(Reg2));  -- ADD operation
            WHEN "0101" =>
                ALUout_sig <= std_logic_vector(unsigned(Reg1) - unsigned(Reg2));  -- SUB operation
            WHEN "0110" =>
                ALUout_sig <= Reg1 AND Reg2;  -- AND operation
            WHEN "0111" =>
                ALUout_sig <= Reg1 XOR Reg2;  -- XOR operation
            WHEN "1000" =>
                ALUout_sig <= Reg1 OR Reg2;  -- OR operation
            WHEN OTHERS =>
                ALUout_sig <= Reg1;  -- Default case (NOP)
        END CASE;

        -- Check for zero flag
        IF ALUout_sig = zero_vector THEN
            zero_flag <= '1';
        ELSE
            zero_flag <= '0';
        END IF;
	    neg_flag <= ALUout_sig(31);
        -- Check for carry flag
        IF ALU_selector = "0100" AND (unsigned(Reg1) + unsigned(Reg2)) > to_unsigned(2**n-1, n) THEN
            carry_flag <= '1';
        ELSE
            carry_flag <= '0';
        END IF;
        ALUout<=ALUout_sig;  -- Assign ALU outputPROCESS
END PROCESS;
END ARCHITECTURE struct;