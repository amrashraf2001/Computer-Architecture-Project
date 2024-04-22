vsim -gui work.execute
# End time: 01:16:16 on Apr 23,2024, Elapsed time: 0:27:52
# Errors: 0, Warnings: 0
# vsim -gui work.execute 
# Start time: 01:16:16 on Apr 23,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.execute(execute_arch)
# Loading work.alu(struct)
# Loading work.flagreg(flagreg_arch)
add wave -position insertpoint sim:/execute/*
force -freeze sim:/execute/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/execute/en 1 0
force -freeze sim:/execute/rst 0 0
force -freeze sim:/execute/Reg1 11111111111111111111111111111111 0
force -freeze sim:/execute/Reg2 00000000000000000000000000000000 0
force -freeze sim:/execute/ALU_selector 0011 0
run
force -freeze sim:/execute/ALU_selector 0100 0
run
force -freeze sim:/execute/ALU_selector 0110 0
run
run