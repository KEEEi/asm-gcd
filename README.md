# asm-gcd
The greatest common divisor alogrithm written by Linux elf64 assembly language

## usage
```
$ nasm -f elf64 gcd.asm
$ ld -o gcd gcd.o
$ ./gcd
