LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

USE IEEE.numeric_std.all;

ENTITY Controller IS
    PORT(
        opcode: IN std_logic_vector(5 DOWNTO 0); 
        AluSelector: OUT std_logic_vector(3 DOWNTO 0); -- 3 bits subcode and extra bit
        Branching: OUT std_logic;
        alusource: OUT std_logic; -- ba4of ba5ud el second operand mn el register or immediate
        MWrite, MRead: OUT std_logic;
        WBdatasrc: OUT std_logic_vector(1 DOWNTO 0);
        RegWrite: OUT std_logic;
        SPPointer: OUT std_logic_vector(2 DOWNTO 0);
        interruptsignal:  out std_logic;
        pcSource: OUT std_logic;
        FreeProtectStore: OUT std_logic_vector(1 DOWNTO 0);
        MemAddress: OUT std_logic_vector(2 DOWNTO 0);
        CallIntStore: OUT std_logic_vector(1 DOWNTO 0);
        Ret: out std_logic_vector(1 downto 0);
        Swap: out std_logic;
        OutEnable: OUT std_logic
    );
END Controller;

ARCHITECTURE Controller_Arch OF Controller IS
BEGIN

    OutEnable <= '1' when opcode = "110001" else '0';
    RegWrite <= '1' WHEN opcode = "000100" or
                        (opcode(5 downto 4) = "00" and opcode(3 downto 0) /= "1011") or 
                        opcode(5 downto 0) = "010001" or 
                        opcode(5 downto 0) = "010010" or
                        opcode(5 downto 0) = "110101" or
                        opcode(5 downto 0) = "110110" or
                        opcode(5 downto 0) = "111000" or
                        opcode(5 downto 0) = "110111" or
                        opcode(5 downto 0) = "110010"

                ELSE '0';
                    

    WBdatasrc <= "10" WHEN opcode(5 downto 4) = "00" or opcode = "110101" or opcode = "110110" or opcode = "110111"
                 ELSE "00" WHEN opcode = "110010" -- IN
                 ELSE "01" WHEN opcode = "010001" or opcode = "010010" 
                 ELSE "11";

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
                 ELSE "1110" WHEN opcode = "000100" --MOV
                 ELSE "1111" When opcode = "110111" -- LDM
                 ELSE "1110";


    Branching <= '1' WHEN opcode(5 downto 4) = "10" or opcode(5 downto 1) = "11100" -- Branching
                 ELSE '0';

    alusource <= '1' WHEN opcode = "110101" or opcode = "110110" or opcode = "110111" -- ADDI, SUBI, LDM
                 ELSE '0';

    MWrite <= '1' WHEN opcode = "010000" or opcode = "010011" or opcode = "100010" or opcode = "111001" -- PUSH, STD , CALL, INT
              ELSE '0';


    MRead <= '1' WHEN opcode = "010001" or opcode = "100011" or opcode = "100100" or opcode = "010010" -- LDD RTI,RET,POP
             ELSE '0';

    SPPointer <= "010" WHEN opcode = "010001" or opcode = "100100" or opcode = "100011" -- POP,RTI,RET
               ELSE "000" WHEN opcode = "010011" or opcode = "010010" -- STD,LDD
               --ELSE "001" WHEN opcode = "100100" or opcode = "100011" -- 
               --ELSE "010" WHEN opcode = "100100" or opcode = "100011" -- RTI,RET
               --ELSE "011" WHEN opcode = "100010" -- 
               ELSE "100" WHEN opcode = "111001" or opcode = "100010" or opcode = "010000" -- INT,CALL,PUSH
               ELSE "101";

    MemAddress <= "000" WHEN opcode(5 downto 1) = "01001" -- LDD,STD
                ELSE "001" WHEN opcode = "111001" or opcode = "100010" or opcode = "010000" -- INT,CALL,PUSH,CALL
                --ELSE "010" WHEN opcode = "010001" -- POP
                ELSE "011" WHEN opcode = "100011" or opcode = "100100" or opcode = "010001" -- RTI,RET,POP
                --ELSE "100" WHEN  -- INT
                ELSE "000";

    interruptsignal <= '1' WHEN opcode = "111001" -- INT
                     ELSE '0';
    

    FreeProtectStore <= "11" WHEN opcode = "010011" --STD
                      ELSE "01" WHEN opcode = "110011" -- FREE
                      ELSE "10" WHEN opcode = "110100" -- PROTECT
                      ELSE "00"; -- Default value STD

    pcSource <= '1' WHEN opcode(5 downto 4) = "10" or opcode(5 downto 1) = "11100"
                ELSE '0';

    CallIntStore <= "00" WHEN opcode = "100010" -- CALL
                  ELSE "01" WHEN opcode = "111001" -- INT
                  ELSE "10" WHEN opcode = "010011" or opcode = "010000" -- STD, PUSH
                  ELSE "10";

    Ret <= "00" WHEN opcode = "110000" or opcode = "010011" or opcode = "010010" or opcode = "010000" or opcode = "010001" -- NOP,STD,LDD,PUSH,POP
         ELSE "01" WHEN opcode = "100011" -- RET
         ELSE "10" WHEN opcode = "100100" -- RTI
         ELSE "00";

    Swap <= '1' when opcode(5 downto 0) = "000101" else '0';

END Controller_Arch;

