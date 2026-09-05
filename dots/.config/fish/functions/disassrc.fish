function disassrc --description "Disassemble a binary with source code using objdump and Intel syntax"
    objdump -drwCS -M intel --visualize-jumps=color $argv[1]
end
