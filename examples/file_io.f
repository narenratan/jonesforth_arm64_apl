/ Example file IO using syscalls /

/ Open a file read only with open ⍐ syscall /
0 H" input.txt" ↓ ⍐

/ Read one byte with read ⍇ syscall /
↑ 1 H ⌽ ⍇

/ Close file with close ⍗ syscall /
↓ ⍗
