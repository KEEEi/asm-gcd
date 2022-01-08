SECTION .data

prompt1:    DB  "Enter first number: "
prompt1len: EQU ($ - prompt1)
prompt2:    DB  "Enter second number: "
prompt2len: EQU ($ - prompt2)

result1:    DB  "The GCD of "
result1len: EQU ($ - result1)
result2:    DB  " and "
result2len: EQU ($ - result2)
result3:    DB  " is "
result3len: EQU ($ - result3)

invnum:     DB  "Invalid number!", 10
invnumlen:  EQU ($ - invnum)

newline:    DB  10

SECTION .text

GLOBAL _start
_start:
        sub rsp, 32                 ; allocate space for saving 32 digits in stack

        ; Prompt to enter first number
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, prompt1            ; address of string to write
        mov rdx, prompt1len         ; length of string to write
        syscall                     ; call system to print the string

        ; Read first number
        mov rax, 0                  ; function number to read a string
        mov rdi, 0                  ; read from stdin
        mov rsi, rsp                ; address of string to read
        mov rdx, 32                 ; length of string to read
        syscall                     ; call system to read the string

        mov BYTE[rsp + rax - 1], 0  ; save a zero at end of string

        mov rdi, rsp                ; load address of read string
        call str_to_num             ; convert string to a number
        mov r12, rax                ; save converted number in r12
        cmp rax, 0                  ; check if there were errors
        jl  num_error               ; if so, exit with error

        ; Prompt to enter second number
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, prompt2            ; address of string to write
        mov rdx, prompt2len         ; length of string to write
        syscall                     ; call system to print the string

        ; Read second number
        mov rax, 0                  ; function number to read a string
        mov rdi, 0                  ; read from stdin
        mov rsi, rsp                ; address of string to read
        mov rdx, 32                 ; length of string to read
        syscall                     ; call system to read the string

        mov BYTE[rsp + rax - 1], 0  ; save a zero at end of string

        mov rdi, rsp                ; load address of read string
        call str_to_num             ; convert string to a number
        mov r13, rax                ; save converted number in r13
        cmp rax, 0                  ; check if there were errors
        jl  num_error               ; if so, exit with error

        mov rdi, r12                ; pass first number to subroutine
        mov rsi, r13                ; pass second number to subroutine
        call GCD                    ; Calculate the GCD(a,b)
        mov r14, rax                ; save result in r14

        ; Print first part of result message
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, result1            ; address of string to write
        mov rdx, result1len         ; length of string to write
        syscall                     ; call system to print the string

        mov rdi, r12                ; load first number
        call print_num              ; print the number

        ; Print second part of result message
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, result2            ; address of string to write
        mov rdx, result2len         ; length of string to write
        syscall                     ; call system to print the string

        mov rdi, r13                ; load second number
        call print_num              ; print the number

        ; Print third part of result message
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, result3            ; address of string to write
        mov rdx, result3len         ; length of string to write
        syscall                     ; call system to print the string

        mov rdi, r14                ; load gcd result
        call print_num              ; print the number

        ; Print newline
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, newline            ; address of string to write
        mov rdx, 1                  ; length of string to write
        syscall                     ; call system to print the string

        jmp prog_end                ; go to end of program
num_error:
        ; Print error message
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, invnum             ; address of string to write
        mov rdx, invnumlen          ; length of string to write
        syscall                     ; call system to print the string
prog_end:
        add rsp, 32                 ; restore stack pointer

        mov rax, 60                 ; function number to exit program
        mov rdi, 0                  ; exit successfully
        syscall                     ; call system to terminate program

; Function to calculate the GCD
; Receives: RDI = number a, RSI = number b
; Returns: RAX = GCD(a,b)
GCD:    cmp rsi, 0                  ; if b==0
        jne else1                   ; if not, go to else
        mov rax, rdi                ; return a
        ret
else1:  cmp rdi, rsi                ; if a < b
        jge else2                   ; if not, go to else
        ; swap a and b
        mov rax, rsi                ; save b in rax
        mov rsi, rdi                ; use a instead of b
        mov rdi, rax                ; use b instead of a
        call GCD                    ; return GCD(b, a)
        ret
else2:  mov rax, rdi                ; load a in rax for division
        mov rdx, 0                  ; clear rdx before division
        div rsi                     ; divide a/b
        mov rdi, rsi                ; use b instead of a
        mov rsi, rdx                ; use remainder (mod) for b
        call GCD                    ; return GCD(b, a % b)
        ret

; Function to print non-negative numbers
; Receives: RDI = number to print
print_num:
        mov  r9, rsp                ; copy current stack pointer
        sub  rsp, 16                ; allocate space in stack for 16 digits
        mov  r10, 10                ; load 10 for divisions
        mov  r11, 0                 ; length = 0
        mov  rax, rdi               ; copy number to print in rax
conv_loop:
        mov rdx, 0                  ; clear rdx before division
        div r10                     ; divide number by 10
        add rdx, '0'                ; convert remainder to ascii
        dec r9                      ; decrement r9
        mov [r9], dl                ; save digit
        inc r11                     ; increment length of digit string
        cmp rax, 0                  ; if quotient was not zero
        jne conv_loop               ; divide again

        ; Print conversion result
        mov rax, 1                  ; function number to write a string
        mov rdi, 1                  ; write to stdout
        mov rsi, r9                 ; address of string to write
        mov rdx, r11                ; length of string to write
        syscall                     ; call system to print the string
        add rsp, 16                 ; restore stack pointer
        ret

; Function to convert string to a number
; Receives: RDI = address of string to convert
; Returns: RAX = converted number or -1 if invalid
str_to_num:
        cmp BYTE[rdi], 0            ; if empty string
        je  stn_error               ; it's an error
        mov rax, 0                  ; start with number in 0
stn_loop:
        mov rcx, 0                  ; clear rcx
        mov cl, [rdi]               ; load character from string
        inc rdi                     ; advance to next char in string
        cmp cl, 0                   ; if end of string
        je  stn_end                 ; terminate conversion
        imul rax, 10                ; multiply old number by 10
        sub cl, '0'                 ; convert ascii to a digit
        jl  stn_error               ; if < 0, it's an invalid digit
        cmp cl, 9
        jg  stn_error               ; if > 9, it's an invalid digit
        add rax, rcx                ; add digit to converted number
        jmp stn_loop                ; continue conversion
stn_error:
        mov rax, -1                 ; return -1
stn_end:
        ret
