global _start
section .data
    hello: db 'Hello my, friend. Guess my number from 1 to 9!', 10
    bye: db 'You guessed it, bye!', 10
    less: db 'Less', 10
    greater: db 'Greater', 10
    number: db 5
    input: db 0, 0
section .text
_start:
    ; let's first print the greeting
    mov r8, 0
    mov r9, 0
    mov r8b, [number]
    mov rax, 1
    mov rdi, 1
    mov rsi, hello
    mov rdx, 47
    syscall
.loop:
    mov rax, 0
    mov rdi, 0
    mov rsi, input
    mov rdx, 2
    syscall ; read
    mov r9w, [input]
    sub r9b, 48 ; char to int
    cmp r8b, r9b
    mov rax, 1
    mov rdi, 1
    je .end
    jl .less
    jg .greater
.greater:
    mov rsi, greater
    mov rdx, 8
    syscall
    jmp .loop
.less:
    mov rsi, less
    mov rdx, 5
    syscall
    jmp .loop
.end:
    mov rsi, bye
    mov rdx, 21
    syscall

    ; Don't forget to exit
    mov rax, 60
    xor rdi, rdi
    syscall
