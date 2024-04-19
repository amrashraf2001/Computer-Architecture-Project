library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY ALU is
    GENERIC (
        n : integer := 32
    );
    PORT (
        Reg1, Reg2 : IN std_logic_vector(n-1 downto 0);
        ALU_selector : IN std_logic_vector(3 downto 0);
        carry_flag, neg_flag, zero_flag, overflow_flag : OUT std_logic;
        ALUout : OUT std_logic_vector(n-1 downto 0)
    );
END ENTITY ALU;

ARCHITECTURE struct OF ALU IS
    SIGNAL carry_flag_sig, neg_flag_sig, zero_flag_sig, overflow_flag_sig : std_logic;
    SIGNAL ALUout_sig : std_logic_vector(n-1 downto 0);
BEGIN
PROCESS (ALU_selector, Reg1, Reg2)
BEGIN
    CASE ALU_selector IS
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0000" => -- NOT
            ALUout_sig <= NOT Reg1;
        IF ALUout_sig = "00000000000000000000000000000000" THEN
            zero_flag_sig <= '1';
        ELSE
            zero_flag_sig <= '0';
        END IF;
        IF ALUout_sig(n-1) = '1' THEN
            neg_flag_sig <= '1';
        ELSE
            neg_flag_sig <= '0';
        END IF;
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0001" => --  NEG
            std_logic_vector(unsigned("00000000000000000000000000000000") - unsigned(Reg1))
            IF ALUout_sig = "00000000000000000000000000000000" THEN
            zero_flag_sig <= '1';
        ELSE
            zero_flag_sig <= '0';
        END IF;        
        IF ALUout_sig(n-1) = '1' THEN
            neg_flag_sig <= '1';
        ELSE
            neg_flag_sig <= '0';
        END IF;
        IF Reg1 = X"80000000" THEN
            overflow_flag_sig <= '1';
        ELSE
            overflow_flag_sig <= '0';
        END IF;
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0010" => -- INC
            ALUout_sig <= Reg1 + "00000000000000000000000000000001" ;
            IF ALUout_sig < Reg1 THEN
                overflow_flag_sig <= '1';
            ELSE
                overflow_flag_sig <= '0';
            END IF;
            IF ALUout_sig = "00000000000000000000000000000000" THEN
                zero_flag_sig <= '1';
            ELSE
                zero_flag_sig <= '0';
            END IF;
            IF ALUout_sig(n-1) = '1' THEN
                neg_flag_sig <= '1';
            ELSE
                neg_flag_sig <= '0';
            END IF;
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0011" => -- DEC
            ALUout_sig <= Reg1 - "00000000000000000000000000000001";
            IF ALUout_sig > Reg1 THEN
                overflow_flag_sig <= '1';
            ELSE
                overflow_flag_sig <= '0';
            END IF;
            IF ALUout_sig = "00000000000000000000000000000000" THEN
                zero_flag_sig <= '1';
            ELSE
                zero_flag_sig <= '0';
            END IF;
            IF ALUout_sig(n-1) = '1' THEN
                neg_flag_sig <= '1';
            ELSE
                neg_flag_sig <= '0';
            END IF;
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0100" => -- ADD
            ALUout_sig <= Reg1 + Reg2;
            IF ALUout_sig < Reg1 THEN
            overflow_flag_sig <= '1';
            ELSE
                overflow_flag_sig <= '0';
            END IF;
            IF ALUout_sig = "00000000000000000000000000000000" THEN
                zero_flag_sig <= '1';
            ELSE
                zero_flag_sig <= '0';
            END IF;
            IF ALUout_sig(n-1) = '1' THEN
                neg_flag_sig <= '1';
            ELSE
                neg_flag_sig <= '0';
            END IF;
            IF unsigned(Reg1) + unsigned(Reg2) > unsigned(ALUout_sig) THEN
                carry_flag_sig <= '1';
            ELSE
                carry_flag_sig <= '0';
            END IF;
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0101" => -- SUB
            ALUout_sig <= Reg1 OR Reg2;
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0110" => -- AND
            ALUout_sig <= Reg1 AND Reg2;
            IF ALUout_sig = "00000000000000000000000000000000" THEN
                zero_flag_sig <= '1';
            ELSE
                zero_flag_sig <= '0';
            END IF;
            IF ALUout_sig(n-1) = '1' THEN
                neg_flag_sig <= '1';
            ELSE
                neg_flag_sig <= '0';
            END IF;
    --------------------------------------------------------------------------------------------------------------------
        WHEN "0111" => -- XOR
            ALUout_sig <= NOT Reg1;
        WHEN "1000" => -- OR
            ALUout_sig <= Reg1 sll to_integer(unsigned(Reg2));
    END CASE;
    carry_flag <= carry_flag_sig;
    neg_flag <= neg_flag_sig;
    zero_flag <= zero_flag_sig;
    overflow_flag <= overflow_flag_sig;
    ALUout <= ALUout_sig;
    
END PROCESS;

END ARCHITECTURE struct;