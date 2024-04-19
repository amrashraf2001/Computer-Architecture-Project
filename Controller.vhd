LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

USE IEEE.numeric_std.all;

ENTITY Controller IS
    PORT(
        opcode: IN std_logic_vector(5 DOWNTO 0); 
        ZeroFlag: IN std_logic; -- Branching
        AluSelector: OUT std_logic_vector(3 DOWNTO 0); -- 3 bits subcode and extra bit
        Branching: OUT std_logic;
        alusource: OUT std_logic; -- ba4of ba5ud el second operand mn el register or immediate
        MWrite, MRead: OUT std_logic;
        WBdatasrc: OUT std_logic_vector(1 DOWNTO 0);
        RegWrite: OUT std_logic;
        SPPointer: OUT std_logic_vector(1 DOWNTO 0);
        MemWRsrc: OUT std_logic;
        interruptsignal:  out std_logic;
        rtisignal:  out std_logic;
        FreeProtectStore: OUT std_logic_vector(1 DOWNTO 0)
    );
END Controller;

ARCHITECTURE Controller_Arch OF Controller IS
BEGIN
    RegWrite <= '1' WHEN (opcode(5 downto 4) = "00" and opcode(3 downto 0) /= "1011") or 
                        opcode(5 downto 0) = "010001" or 
                        opcode(5 downto 0) = "010010" or
                        (opcode(5 downto 4) = "11" and 
                        (opcode(3 downto 1) /= "000" or 
                         opcode(3 downto 0) /= "0011" or 
                         opcode(3 downto 0) /= "0100" or 
                         opcode(3 downto 0) /= "1001"))
                ELSE '0';
                    

    WBdatasrc <= "01" WHEN opcode(5 DOWNTO 4) = "01"
                 ELSE "00" WHEN opcode = "110010" -- IN
                 ELSE "10";

    AluSelector <= "0000" WHEN opcode = "000000" -- NOT
                 ELSE "0001" WHEN opcode = "000001" -- NEG
                 ELSE "0010" WHEN opcode = "000010" -- INC
                 ELSE "0011" WHEN opcode = "000011" -- DEC
                 ELSE "0100" WHEN opcode = "000110" -- ADD
                 ELSE "0101" WHEN opcode = "000111" -- SUB
                 ELSE "0110" WHEN opcode = "001000" -- AND
                 ELSE "0111" WHEN opcode = "001001" -- XOR
                 ELSE "1000" WHEN opcode = "001010" -- OR
                 ELSE "1001" WHEN opcode = "001011" -- CMP
                 ELSE "1010" WHEN opcode = "010010" -- LDD
                 ELSE "1011" WHEN opcode = "010011" -- STD
                 ELSE "1100" WHEN opcode = "110101" -- ADDI
                 ELSE "1101" WHEN opcode = "110110" -- SUBI 
                 ELSE "1110"; -- Default value NOP

    Branching <= '1' WHEN opcode(5 downto 4) = "10" or opcode(5 downto 1) = "11100" -- Branching
                 ELSE '0';

    alusource <= '1' WHEN opcode = "110101" or opcode = "110110" or opcode = "110111" -- To include ADDI & LDM
                 ELSE '0';

    MWrite <= '1' WHEN opcode = "011111" or opcode = "010011" or opcode = "100010" -- PUSH STD , CALL
              ELSE '0';

    MRead <= '1' WHEN opcode = "010001" or opcode = "010010" or opcode = "100100" or opcode = "100011" -- LDM for ناوو
             ELSE '0';

    SPPointer <= "01" WHEN opcode = "010000" OR opcode = "100111" -- PUSH , CALL
               ELSE "10" WHEN opcode(5 DOWNTO 2) = "1000" OR opcode = "010110" -- RET, RTI, POP
               ELSE "00"; -- SP=SP

    MemWRsrc <= opcode(5);

END Controller_Arch;
