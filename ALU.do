vsim -gui work.alu
# vsim -gui work.alu 
# Start time: 22:29:49 on Apr 22,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.alu(struct)
# ** Error: (vsim-86) Argument value -1 is not in bounds of subtype NATURAL.
#    Time: 0 ps  Iteration: 0  Instance: /alu
add wave -position insertpoint sim:/alu/*
force -freeze sim:/alu/Reg1 11111111111111111111111111111111 0
force -freeze sim:/alu/ALU_selector 0000 0
run
force -freeze sim:/alu/ALU_selector 0001 0
force -freeze sim:/alu/ALU_selector 0001 0
run
force -freeze sim:/alu/ALU_selector 0010 0
run
force -freeze sim:/alu/ALU_selector 0011 0
run
force -freeze sim:/alu/Reg2 00000000000000000000000000000000 0
force -freeze sim:/alu/ALU_selector 0110 0
run
force -freeze sim:/alu/ALU_selector 0111 0
run
force -freeze sim:/alu/ALU_selector 1000 0
run
force -freeze sim:/alu/Reg2 00000000000000000000000000000001 0
force -freeze sim:/alu/ALU_selector 0100 0
run
force -freeze sim:/alu/ALU_selector 0101 0
run
force -freeze sim:/alu/Reg1 00000000000000000000000000000000 0
run


