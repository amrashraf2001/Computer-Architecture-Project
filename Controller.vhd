LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

USE IEEE.numeric_std.all;

ENTITY Controller IS
    PORT(
        opcode: IN std_logic_vector(5 DOWNTO 0); 
        ZeroFlag: IN std_logic; -- Branching
        AluSelector: OUT std_logic_vector(4 DOWNTO 0); -- 3 bits subcode and extra bit
        Branching: OUT std_logic;
        alusource: OUT std_logic; -- ba4of ba5ud el second operand mn el register or immediate
        MWrite, MRead: OUT std_logic;
        WBdatasrc: OUT std_logic_vector(1 DOWNTO 0);
        RegWrite: OUT std_logic;
        SPPointer: OUT std_logic_vector(1 DOWNTO 0);
        MemWRsrc: OUT std_logic;
        interruptsignal:  out std_logic;
        rtisignal:  out std_logic
        FreeProtectStore: OUT std_logic_vector(1 DOWNTO 0)
    );
END Controller;

ARCHITECTURE Controller_Arch OF Controller IS
BEGIN
    RegWrite <= '1' WHEN opcode(5 DOWNTO 4) = "00" or opcode = "000000" or opcode = "000011" or opcode = "000100" or opcode = "001010" or opcode = "110111" 
               ELSE '0';


    WBdatasrc <= "01" WHEN opcode(5 DOWNTO 4) = "01"
                 ELSE "00" WHEN opcode = "110010" -- IN
                 ELSE "10";

    AluSelector <= "0000" WHEN opcode = "000000" -- NOT
                 ELSE "0011" WHEN opcode = "000011" -- DEC
                 ELSE "0100" WHEN opcode = "000100" -- MOV
                 ELSE "1010" WHEN opcode = "001010" -- OR
                 ELSE "1011" WHEN opcode = "001011" -- CMP
                 ELSE "1101" WHEN opcode = "110111" -- LDM
                 ELSE "0000"; -- Default value

    Branching <= '1' WHEN opcode(5 DOWNTO 0) = "100000" -- JMP
                 ELSE ZeroFlag WHEN opcode = "100001" -- JZ
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
