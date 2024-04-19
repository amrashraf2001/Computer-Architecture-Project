
vsim -gui work.instruction_memory
# vsim -gui work.instruction_memory 
# Start time: 22:01:43 on Apr 17,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading ieee.math_real(body)
# Loading work.instruction_memory(instruction_memory_architecture)
mem load -i dataTest.mem /instruction_memory/ram
add wave -position insertpoint  \
sim:/instruction_memory/n \
sim:/instruction_memory/ReadAddress \
sim:/instruction_memory/ReadData \
sim:/instruction_memory/ram \
sim:/instruction_memory/temp
force -freeze sim:/instruction_memory/ReadAddress 111111111110 0
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /instruction_memory
force -freeze sim:/instruction_memory/ReadAddress 111111111111 0
run
force -freeze sim:/instruction_memory/ReadAddress 000000000011 0
run