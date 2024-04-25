vsim -gui work.processor
# vsim -gui work.processor 
# Start time: 06:46:34 on Apr 25,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.processor(processor_arch)
# Loading work.fetch(fetch_arch)
# Loading work.pc(pc_arch)
# Loading ieee.math_real(body)
# Loading work.instruction_memory(instruction_memory_architecture)
# Loading work.fetchdecode_reg(fetchdecode_reg)
# Loading work.decode(decode_arch)
# Loading work.controller(controller_arch)
# Loading work.regfile(regfile_architecture)
# Loading work.predictorreg(predictorreg_arch)
# Loading work.decodeexecute_reg(decodeexecute_reg)
# Loading work.execute(execute_arch)
# Loading work.alu(struct)
# Loading work.flagreg(flagreg_arch)
# Loading work.executememory_reg(executememory_reg)
# Loading work.memory(memory_arch)
# Loading work.data_memory(data_memory_architecture)
# Loading work.stackreg(stackreg_arch)
# Loading work.memorywriteback_reg(memorywriteback_reg)
# Loading work.writeback(writeback_arch)
# vsim -gui work.processor 
# Start time: 06:02:26 on Apr 25,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.processor(processor_arch)
# Loading work.fetch(fetch_arch)
# Loading work.pc(pc_arch)
# Loading ieee.math_real(body)
# Loading work.instruction_memory(instruction_memory_architecture)
# Loading work.fetchdecode_reg(fetchdecode_reg)
# Loading work.decode(decode_arch)
# Loading work.controller(controller_arch)
# Loading work.regfile(regfile_architecture)
# Loading work.predictorreg(predictorreg_arch)
# Loading work.decodeexecute_reg(decodeexecute_reg)
# Loading work.execute(execute_arch)
# Loading work.alu(struct)
# Loading work.flagreg(flagreg_arch)
# Loading work.executememory_reg(executememory_reg)
# Loading work.memory(memory_arch)
# Loading work.data_memory(data_memory_architecture)
# Loading work.stackreg(stackreg_arch)
# Loading work.memorywriteback_reg(memorywriteback_reg)
# Loading work.writeback(writeback_arch)
# vsim -gui work.processor 
# Start time: 05:14:43 on Apr 25,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.processor(processor_arch)
# Loading work.fetch(fetch_arch)
# Loading work.pc(pc_arch)
# Loading ieee.math_real(body)
# Loading work.instruction_memory(instruction_memory_architecture)
# Loading work.fetchdecode_reg(fetchdecode_reg)
# Loading work.decode(decode_arch)
# Loading work.controller(controller_arch)
# Loading work.regfile(regfile_architecture)
# Loading work.predictorreg(predictorreg_arch)
# Loading work.decodeexecute_reg(decodeexecute_reg)
# Loading work.execute(execute_arch)
# Loading work.alu(struct)
# Loading work.flagreg(flagreg_arch)
# Loading work.executememory_reg(executememory_reg)
# Loading work.memory(memory_arch)
# Loading work.data_memory(data_memory_architecture)
# Loading work.stackreg(stackreg_arch)
# Loading work.memorywriteback_reg(memorywriteback_reg)
# Loading work.writeback(writeback_arch)
mem load -i {D:/gam3a/spring 2024/CMPN301 Computer Architecture/my project/Computer-Architecture-Project/TestCase.mem} /processor/Fetch1/IM1/ram
add wave -position insertpoint  \
sim:/processor/clk \
sim:/processor/en \
sim:/processor/rst \
sim:/processor/InPort \
sim:/processor/OutPort \
sim:/processor/Instruction_FDIN \
sim:/processor/MemoryOut_MOut \
sim:/processor/PCPlus_FDIN \
sim:/processor/FlagReg_out_EOUT
force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/processor/en 1 0
force -freeze sim:/processor/rst 1 0
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/Memory1/Data_Memory1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/Fetch1/IM1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 1  Instance: /processor/Memory1/Data_Memory1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/Memory1/Data_Memory1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/Fetch1/IM1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 1  Instance: /processor/Memory1/Data_Memory1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/Memory1/Data_Memory1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /processor/Fetch1/IM1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 1  Instance: /processor/Memory1/Data_Memory1
force -freeze sim:/processor/rst 0 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 6800 ps  Iteration: 0  Instance: /processor/Decode1/RegFile1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 6800 ps  Iteration: 0  Instance: /processor/Decode1/RegFile1
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 6900 ps  Iteration: 0  Instance: /processor/Decode1/RegFile1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 6900 ps  Iteration: 0  Instance: /processor/Decode1/RegFile1
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 7 ns  Iteration: 0  Instance: /processor/Decode1/RegFile1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 7 ns  Iteration: 0  Instance: /processor/Decode1/RegFile1
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 7100 ps  Iteration: 0  Instance: /processor/Decode1/RegFile1
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 7100 ps  Iteration: 0  Instance: /processor/Decode1/RegFile1