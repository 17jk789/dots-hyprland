function disas
    objdump -drwC -M intel --visualize-jumps=color $argv[1]
end
