#include <iostream>
#include <iostream>
#include <string>
#include <bitset>
#include <fstream>
#include <algorithm>
#include <bitset>
using namespace std;

// Function to convert decimal to binary
string decimalToBinary(char num)
{
    if (num == '0')
    {
        return "000";
    }
    else if (num == '1')
    {
        return "001";
    }
    else if (num == '2')
    {
        return "010";
    }
    else if (num == '3')
    {
        return "011";
    }
    else if (num == '4')
    {
        return "100";
    }
    else if (num == '5')
    {
        return "101";
    }
    else if (num == '6')
    {
        return "110";
    }
    else if (num == '7')
    {
        return "111";
    }
    else
    {
        return "XXX";
    }
}

// Function to convert hexadecimal to binary
string hextobinary(string hex)
{
    int num = stoi(hex, nullptr, 16);
    bitset<16> binary(num);
    return binary.to_string();
}

// Function to get the opcode of the instruction

string getOpcode(string instruction)
{
    if (instruction == "NOT")
        return "000000";
    else if (instruction == "NEG")
        return "000001";
    else if (instruction == "INC")
        return "000010";
    else if (instruction == "DEC")
        return "000011";
    else if (instruction == "MOV")
        return "000100";
    else if (instruction == "SWAP")
        return "000101";
    else if (instruction == "ADD")
        return "000110";
    else if (instruction == "SUB")
        return "000111";
    else if (instruction == "AND")
        return "001000";
    else if (instruction == "XOR")
        return "001001";
    else if (instruction == "OR")
        return "001010";
    else if (instruction == "CMP")
        return "001011";
    else if (instruction == "PUSH")
        return "010000";
    else if (instruction == "POP")
        return "010001";
    else if (instruction == "LDD")
        return "010010";
    else if (instruction == "STD")
        return "010011";
    else if (instruction == "JMP")
        return "100000";
    else if (instruction == "JZ")
        return "100001";
    else if (instruction == "CALL")
        return "100010";
    else if (instruction == "RET")
        return "100011";
    else if (instruction == "RTI")
        return "100100";
    else if (instruction == "NOP")
        return "110000";
    else if (instruction == "OUT")
        return "110001";
    else if (instruction == "IN")
        return "110010";
    else if (instruction == "FREE")
        return "110011";
    else if (instruction == "PROTECT")
        return "110100";
    else if (instruction == "ADDI")
        return "110101";
    else if (instruction == "SUBI")
        return "110110";
    else if (instruction == "LDM")
        return "110111";
    else if (instruction == "RESET")
        return "111000";
    else if (instruction == "INTERRUPT")
        return "111001";
    else
        return "110000"; // NOP
}

void ReadFile(string fileinName)
{
	string instname;
	ifstream filein;
	ofstream  fileout;
	filein.open(fileinName);
	fileout.open("AssemblerOutput.mem");


	fileout << "// memory data file (do not edit the following line - required for mem load use)" << endl;
	fileout << "// instance=/processor/f1/m1/ram" << endl;
	fileout << "// format=mti addressradix=d dataradix=s version=1.0 wordsperline=1" << endl;
	string instcode;
	string Rdest;
	string Rsrc1;
	string Rsrc2;
	int destflag = 0;
	int src1flag = 0;
	int src2flag = 0;
	string temp;
	string comment;
	int counter = 0;
	string counterstring;
	string orgcount;
	string immediatevaluehex;
	string immediatevaluebin;
	int counttest = 0;

	while (1)
	{
		if (counter / 10 == 0)
		{
			counterstring = "  " + to_string(counter);
		}
		else if (counter / 100 == 0)
		{
			counterstring = " " + to_string(counter);
		}
		else
		{
			counterstring = to_string(counter);
		}

		filein >> instname;
		if (filein.eof() == true)
		{
			break;
		}

		if (instname[0] == '#') 
		{
			getline(filein, comment);
		}
		if (instname == ".org" || instname == ".ORG")
		{
			filein >> orgcount;
			counter = stoi(orgcount, nullptr, 16); 
		}

		if (instname == "ADD" || instname == "SUB" || instname == "AND" || instname == "OR" || instname == "XOR")
		{
			instcode = getOpcode(instname); 
			char readchar;
			while (1)
			{
				readchar = filein.get(); 
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (destflag == 0)
					{
						if (temp != "XXX")
						{
							Rdest = temp;
							destflag = 1;
						}
						else
						{
							Rdest = temp;
						}
					}
					else if (src1flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc1 = temp;
							src1flag = 1;
						}
						else
						{
							Rsrc1 = temp;
						}
					}
					else if (src2flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc2 = temp;
							src2flag = 1;
							break;
						}
						else
						{
							Rsrc2 = temp;
						}
					}


				}
			}
			instcode.append(Rdest);
			instcode.append(Rsrc1);
			instcode.append(Rsrc2);
			instcode.append("0");
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++; 
		}
		else if (instname == "CMP")
		{
			instcode = getOpcode(instname);
			char readchar;
			while (1)
			{
				readchar = filein.get();
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (src1flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc1 = temp;
							Rdest = temp;
							src1flag = 1;
							destflag = 1;
						}
						else
						{
							Rsrc1 = temp;
						}
					}
					else if (src2flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc2 = temp;
							src2flag = 1;
							break;
						}
						else
						{
							Rsrc2 = temp;
						}
					}


				}
			}
			instcode.append(Rdest);
			instcode.append(Rsrc1);
			instcode.append(Rsrc2);
			instcode.append("0");
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++;
		}
		else if (instname == "MOV" || instname == "SWAP")
		{
			instcode = getOpcode(instname); 
			char readchar;
			while (1)
			{
				readchar = filein.get(); 
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (destflag == 0)
					{
						if (temp != "XXX")
						{
							Rdest = temp;
							destflag = 1;
						}
						else
						{
							Rdest = temp;
						}
					}
					else if (src1flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc1 = temp;
							src1flag = 1;
							break;
						}
						else
						{
							Rsrc1 = temp;
						}
					}
				}
			}
			instcode.append(Rdest);
			instcode.append(Rsrc1);
			instcode.append("0000"); 
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++; 
		}
		else if (instname == "INC" || instname == "DEC" || instname == "NOT" || instname == "NEG")
		{
			instcode = getOpcode(instname);
			char readchar;
			while (1)
			{
				readchar = filein.get();
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (destflag == 0 && src1flag == 0)
					{
						if (temp != "XXX")
						{
							Rdest = temp;
							Rsrc1 = temp;
							destflag = 1;
							src1flag = 1;
							break;
						}
						else
						{
							Rdest = temp;
						}
					}
				}
			}
			instcode.append(Rdest);
			instcode.append(Rsrc1);
			instcode.append("0000");
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++;
		}
		else if (instname == "RET" || instname == "RTI" || instname == "RESET" || instname == "INTERRUPT" || instname == "NOP")
		{
			instcode = getOpcode(instname); 
			instcode.append("0000000000"); 
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++; 
		}
		else if (instname == "PUSH" || instname == "OUT" || instname == "POP" || instname == "IN" || instname == "JZ" || instname == "JMP" || instname == "CALL")
		{

			instcode = getOpcode(instname); 
			char readchar;
			while (1)
			{
				readchar = filein.get(); 
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (destflag == 0)
					{
						if (temp != "XXX")
						{
							Rdest = temp;
							destflag = 1;
							break;
						}
						else
						{
							Rdest = temp;
						}
					}
				}
			}
			instcode.append(Rdest);
			instcode.append("0000000");
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++;

		}
		else if (instname == "PROTECT" || instname == "FREE")
		{

			instcode = getOpcode(instname);
			char readchar;
			while (1)
			{
				readchar = filein.get();
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (src1flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc1 = temp;
							src1flag = 1;
							break;
						}
						else
						{
							Rsrc1 = temp;
						}
					}
				}
			}
			instcode.append("000");
			instcode.append(Rsrc1);
			instcode.append("0000");
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++;

		}
		else if (instname == "STD" || instname == "LDD")
		{
			instcode = getOpcode(instname); 
			char readchar;
			while (1)
			{
				readchar = filein.get();
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (destflag == 0)
					{
						if (temp != "XXX")
						{
							Rdest = temp;
							destflag = 1;
							break;
						}
						else
						{
							Rdest = temp;
						}
					}
					else if (src1flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc1 = temp;
							src1flag = 1;
						}
						else
						{
							Rsrc1 = temp;
						}
					}


				}
			}
			instcode.append(Rdest);
			instcode.append(Rsrc1);
			instcode.append("0000"); 
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++; 
		}
		else if (instname == "ADDI" || instname == "SUBI")
		{
			instcode = getOpcode(instname);
			char readchar;
			while (1)
			{
				readchar = filein.get(); 
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (destflag == 0)
					{
						if (temp != "XXX")
						{
							Rdest = temp;
							destflag = 1;
						}
						else
						{
							Rdest = temp;
						}
					}
					else if (src1flag == 0)
					{
						if (temp != "XXX")
						{
							Rsrc1 = temp;
							src1flag = 1;
						}
						else
						{
							Rsrc1 = temp;
						}
					}
				}
				else 
				{
					filein.unget(); 
					filein >> immediatevaluehex;
					immediatevaluebin = hextobinary(immediatevaluehex);
					break;
				}
			}
			instcode.append(Rdest);
			instcode.append(Rsrc1);
			instcode.append("0000"); 
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++; 
			if (counter / 10 == 0)
			{
				counterstring = "  " + to_string(counter);
			}
			else if (counter / 100 == 0)
			{
				counterstring = " " + to_string(counter);
			}
			else
			{
				counterstring = to_string(counter);
			}
			fileout << counterstring << ": ";
			fileout << immediatevaluebin << endl; //prints immediate value on a new line
			counter++; //prepares for coming instruction

		}
		else if (instname == "LDM")
		{
			instcode = getOpcode(instname);
			char readchar;
			while (1)
			{
				readchar = filein.get();
				if (readchar == ' ' || readchar == ',')
				{
					continue;
				}
				else if (readchar == 'R')
				{
					readchar = filein.get();
					temp = decimalToBinary(readchar);
					if (destflag == 0)
					{
						if (temp != "XXX")
						{
							Rdest = temp;
							destflag = 1;
						}
						else
						{
							Rdest = temp;
						}
					}
				}
				else
				{
					filein.unget();
					filein >> immediatevaluehex;
					immediatevaluebin = hextobinary(immediatevaluehex);
					break;
				}
			}
			instcode.append(Rdest);
			instcode.append("0000000");
			destflag = 0;
			src1flag = 0;
			src2flag = 0;
			fileout << counterstring << ": ";
			fileout << instcode << endl;
			counter++;
			if (counter / 10 == 0)
			{
				counterstring = "  " + to_string(counter);
			}
			else if (counter / 100 == 0)
			{
				counterstring = " " + to_string(counter);
			}
			else
			{
				counterstring = to_string(counter);
			}
			fileout << counterstring << ": ";
			fileout << immediatevaluebin << endl; //prints immediate value on a new line
			counter++; //prepares for coming instruction

			}
		else if (instname[0] != '#' && instname != ".org" && instname != ".ORG")
		{

			immediatevaluebin = hextobinary(instname);
			fileout << counterstring << ": ";
			fileout << immediatevaluebin << endl; //prints immediate value on a new line
			counter++; //prepares for coming instruction  
		}

	} 
	filein.close();
	fileout.close();
}

int main()
{
    string fileinName;
    cout << "Enter the name of the file: ";
    cin >> fileinName;
    ReadFile(fileinName);
    return 0;
}
