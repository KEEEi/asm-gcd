# Assembly GCD
The greatest common divisor alogrithm written by Linux elf64 assembly language.
The program perfoms the following tasks:
1. Prompts the user to enter a positive integer number (of value no more than 2^64-1.) 
2. Prompts the user to enter a second positive integer number (of value no more than 2^64-1.) 
3. Prints out the integer that is the greatest common divisor of the two entered numbers.  

## usage
```
$ nasm -f elf64 gcd.asm
$ ld -o gcd gcd.o
$ ./gcd
