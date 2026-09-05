function disas --description "Disassemble a binary with objdump using Intel syntax and colored jump visualization"
    objdump -drwC -M intel --visualize-jumps=color $argv[1]
end
