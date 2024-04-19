
vsim -gui work.pc
# vsim -gui work.pc 
# Start time: 21:19:38 on Apr 17,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.pc(pc_arch)
add wave -position insertpoint  \
sim:/pc/n \
sim:/pc/clk \
sim:/pc/branchingAddress \
sim:/pc/en \
sim:/pc/rst \
sim:/pc/branchingSel \
sim:/pc/imSel \
sim:/pc/PCOut \
sim:/pc/s \
sim:/pc/sReg \
sim:/pc/adder
force -freeze sim:/pc/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pc/en 1 0
force -freeze sim:/pc/rst 0 0
force -freeze sim:/pc/branchingSel 0 0
force -freeze sim:/pc/imSel 0 0
run
force -freeze sim:/pc/rst 1 0
run
force -freeze sim:/pc/rst 0 0
run
force -freeze sim:/pc/en 0 0
run
force -freeze sim:/pc/en 1 0
run
force -freeze sim:/pc/branchingSel 1 0
force -freeze sim:/pc/branchingAddress 111111111110 0
run
force -freeze sim:/pc/branchingSel 0 0
run
run
force -freeze sim:/pc/imSel 1 0
run