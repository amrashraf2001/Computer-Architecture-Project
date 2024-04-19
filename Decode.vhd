LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY Decode IS
    PORT(  
        instructionCode : IN std_logic_vector(31 downto 0);
        ZeroFlag:  IN std_logic; -- Branching
        AluSelector: OUT std_logic_vector(3 DOWNTO 0); 
        Branching: OUT std_logic;
        alusource : OUT std_logic;
        MWrite, MRead: OUT std_logic;
        WBdatasrc: OUT std_logic_vector(1 downto 0);
        RegWrite: OUT std_logic;
        SPPointer: OUT std_logic_vector(1 downto 0);
        MemWRsrc:  OUT std_logic;
        clk, rst, WriteEnable: IN std_logic;
        writeport: IN std_logic_vector(15 downto 0);
        readport1: OUT std_logic_vector(15 downto 0);
        readport2: OUT std_logic_vector(15 downto 0);
        WriteAdd: IN std_logic_vector (2 downto 0);
        imm: OUT std_logic_vector(15 downto 0);
        dest: OUT std_logic_vector(2 downto 0)
    );
END ENTITY Decode;

ARCHITECTURE struct OF Decode IS
    COMPONENT RegFile IS
        PORT(
            clk, rst, WriteEnable: IN std_logic;
            writeport: IN std_logic_vector(15 downto 0);
            readport1, readport2: OUT std_logic_vector(15 downto 0);
            WriteAdd: IN std_logic_vector(2 downto 0);
            ReadAdd1, ReadAdd2: IN std_logic_vector(2 downto 0)
        );
    END COMPONENT;

    COMPONENT PController IS 
        PORT(
            opcode: IN std_logic_vector(5 DOWNTO 0); 
            ZeroFlag: IN std_logic; -- Branching
            AluSelector: OUT std_logic_vector(3 DOWNTO 0); 
            Branching: OUT std_logic;
            alusource: OUT std_logic; -- ba4of ba5ud el second operand mn el register or immediate
            MWrite, MRead: OUT std_logic;
            WBdatasrc: OUT std_logic_vector(1 DOWNTO 0);
            RegWrite: OUT std_logic;
            SPPointer: OUT std_logic_vector(1 DOWNTO 0);
            MemWRsrc: OUT std_logic
        );
    END COMPONENT;

    SIGNAL Reg1, Reg2: std_logic_vector(2 downto 0);
    SIGNAL opcode: std_logic_vector(5 downto 0);

BEGIN
    Reg1 <= instructionCode(26 downto 24);
    Reg2 <= instructionCode(20 downto 18);
    imm <= instructionCode(15 downto 0);
    opcode <= instructionCode(31 downto 27);

    regF1: RegFile PORT MAP (clk, rst, WriteEnable, writeport, readport1, readport2, WriteAdd, Reg1, Reg2);
    controller: PController PORT MAP (opcode, ZeroFlag, AluSelector, Branching, alusource, MWrite, MRead, WBdatasrc, RegWrite, SPPointer, MemWRsrc);

END struct;
