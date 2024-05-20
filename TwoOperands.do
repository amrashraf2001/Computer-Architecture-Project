vsim -gui work.processorfinal
# vsim -gui work.processorfinal 
# Start time: 16:52:57 on May 18,2024
# Loading std.standard
# Loading std.textio(body)
# Loading ieee.std_logic_1164(body)
# Loading ieee.numeric_std(body)
# Loading work.processorfinal(processorfinal_arch)
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
# Loading work.forwardingunit(fu_arch)
# Loading work.executememory_reg(executememory_reg)
# Loading work.memory(memory_architecture)
# Loading work.data_memory(data_memory_architecture)
# Loading work.stackreg(stackreg_arch)
# Loading work.protectedflagreg(protectedflags_architecture)
# Loading work.memorywriteback_reg(memorywriteback_reg)
# Loading work.writeback(writeback_arch)
# Loading work.my_dff(a_my_dff)
# ** Warning: (vsim-8683) Uninitialized out port /processorfinal/DecodeStage/rtisignal has no driver.
# This port will contribute value (U) to the signal network.
# ** Warning: (vsim-8683) Uninitialized out port /processorfinal/ExecuteStage/stalling has no driver.
# This port will contribute value (U) to the signal network.
mem load -i C:/Users/sarra/OneDrive/Documents/GitHub/Computer-Architecture-Project/Assembler/TwoOperand.mem /processorfinal/FetchStage/IM1/ram
add wave -position insertpoint  \
sim:/processorfinal/N \
sim:/processorfinal/clk \
sim:/processorfinal/en \
sim:/processorfinal/rst \
sim:/processorfinal/InPort \
sim:/processorfinal/OutPort \
sim:/processorfinal/FetchDecodeBufferIN \
sim:/processorfinal/FetchDecodeBufferOUT \
sim:/processorfinal/FetchBranchingAddress \
sim:/processorfinal/FetchINT \
sim:/processorfinal/FetchBranchingSel \
sim:/processorfinal/FetchExceptionSel \
sim:/processorfinal/FetchStall \
sim:/processorfinal/FetchDataOut \
sim:/processorfinal/FetchPCPlus \
sim:/processorfinal/FetchWrongAddress \
sim:/processorfinal/DecodeExecuteBufferIN \
sim:/processorfinal/DecodeExecuteBufferOUT \
sim:/processorfinal/DecodeWriteBackEnable \
sim:/processorfinal/DecodePredictorEnable \
sim:/processorfinal/DecodeInstruction \
sim:/processorfinal/DecodeWritePort1 \
sim:/processorfinal/DecodeWritePort2 \
sim:/processorfinal/DecodeWriteAdd1 \
sim:/processorfinal/DecodeWriteAdd2 \
sim:/processorfinal/DecodeFlush \
sim:/processorfinal/DecodeSwaped \
sim:/processorfinal/DecodeImmediateValue \
sim:/processorfinal/DecodeReadData1 \
sim:/processorfinal/DecodeReadData2 \
sim:/processorfinal/DecodeAluSelector \
sim:/processorfinal/DecodeBranching \
sim:/processorfinal/DecodeAluSource \
sim:/processorfinal/DecodeMWrite \
sim:/processorfinal/DecodeMRead \
sim:/processorfinal/DecodeWBdatasrc \
sim:/processorfinal/DecodeRegWrite \
sim:/processorfinal/DecodeSPPointer \
sim:/processorfinal/DecodeOutEnable \
sim:/processorfinal/DecodeInterruptSignal \
sim:/processorfinal/DecodePcSource \
sim:/processorfinal/DecodeRtiSignal \
sim:/processorfinal/DecodeFreeProtectStore \
sim:/processorfinal/DecodeSwap \
sim:/processorfinal/DecodeMemAddress \
sim:/processorfinal/DecodeRet \
sim:/processorfinal/DecodeCallIntStore \
sim:/processorfinal/DecodeFlushOut \
sim:/processorfinal/DecodePredictorValue \
sim:/processorfinal/DecodeSrcAdd1 \
sim:/processorfinal/DecodeSrcAdd2 \
sim:/processorfinal/ExecuteMemoryBufferIN \
sim:/processorfinal/ExecuteMemoryBufferOUT \
sim:/processorfinal/ExecuteOpcode \
sim:/processorfinal/ExecuteReg1 \
sim:/processorfinal/ExecuteReg2 \
sim:/processorfinal/ExecuteForwarded_Src_1_EX_MEM \
sim:/processorfinal/ExecuteForwarded_Src_1_MEM_WB \
sim:/processorfinal/ExecuteForwarded_Src_2_EX_MEM \
sim:/processorfinal/ExecuteForwarded_Src_2_MEM_WB \
sim:/processorfinal/ExecuteALU_selector \
sim:/processorfinal/ExecuteDestination_Reg_EX_MEM \
sim:/processorfinal/ExecuteDestination_Reg_MEM_WB \
sim:/processorfinal/ExecuteSrc1_From_ID_EX \
sim:/processorfinal/ExecuteSrc2_From_ID_EX \
sim:/processorfinal/ExecuteWBenable_EX_MEM \
sim:/processorfinal/ExecuteWBenable_MEM_WB \
sim:/processorfinal/ExecuteWBsource_EX_MEM \
sim:/processorfinal/ExecuteSwap \
sim:/processorfinal/ExecutePredictorIn \
sim:/processorfinal/ExecuteALUout \
sim:/processorfinal/ExecuteFlagReg_out \
sim:/processorfinal/ExecuteFlushOut \
sim:/processorfinal/ExecuteNotTakenWrongBranch \
sim:/processorfinal/ExecuteTakenWrongBranch \
sim:/processorfinal/ExecuteStall \
sim:/processorfinal/ExecuteSecondOperandOut \
sim:/processorfinal/MemoryWriteBackBufferIN \
sim:/processorfinal/MemoryWriteBackBufferOUT \
sim:/processorfinal/MemoryWrite \
sim:/processorfinal/MemoryRead \
sim:/processorfinal/MemoryEnable \
sim:/processorfinal/MemoryAddress \
sim:/processorfinal/MemoryCALLIntSTD \
sim:/processorfinal/MemoryRET \
sim:/processorfinal/MemoryALUOut \
sim:/processorfinal/MemoryPCPlus \
sim:/processorfinal/MemorySecondOperand \
sim:/processorfinal/MemorySP \
sim:/processorfinal/MemoryFlagReg \
sim:/processorfinal/MemoryFreeProtectedStore \
sim:/processorfinal/MemoryOut \
sim:/processorfinal/MemoryWrongAddress \
sim:/processorfinal/MemoryFlushAllBack \
sim:/processorfinal/MemoryFlushINT_RTI \
sim:/processorfinal/MemoryINTDetected \
sim:/processorfinal/MemoryFlagRegOut \
sim:/processorfinal/WriteBackALUout \
sim:/processorfinal/WriteBackData_in \
sim:/processorfinal/WriteBackMemoryOut \
sim:/processorfinal/WriteBackWriteBackSource \
sim:/processorfinal/WriteBackWrite_enable \
sim:/processorfinal/WriteBackMux_result \
sim:/processorfinal/WriteBackOutputPortEnable \
sim:/processorfinal/WriteBackSwap \
sim:/processorfinal/WriteBackSecond_operand \
sim:/processorfinal/WriteBackAddress1Value \
sim:/processorfinal/WriteBackAddress2Value \
sim:/processorfinal/FirstMuxResult \
sim:/processorfinal/SecondMuxResult \
sim:/processorfinal/FDFlush \
sim:/processorfinal/DEFlush \
sim:/processorfinal/EMFlush \
sim:/processorfinal/MWFlush \
sim:/processorfinal/InPortValue \
sim:/processorfinal/OutPortValue \
sim:/processorfinal/Memorysrc2AsItIs \
sim:/processorfinal/Executesrc2 \
sim:/processorfinal/Executesrc2O
force -freeze sim:/processorfinal/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/processorfinal/en 1 0
force -freeze sim:/processorfinal/rst 1 0
run
force -freeze sim:/processorfinal/rst 0 0
force -freeze sim:/processorfinal/InPort 00000000000000000000000000000101 0
run
force -freeze sim:/processorfinal/InPort 00000000000000000000000000011001 0
run
force -freeze sim:/processorfinal/InPort 11111111111111111111111111111111 0
run
force -freeze sim:/processorfinal/InPort 11111111111111111111001100100000 0
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