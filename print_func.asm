global _start
section .data
hello: db 'Hello world!', 10

section .text

; rdi - pointer to printing data
; rsi - length of printing data
print_func:
    mov rax, 0
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 0
    syscall
    ret

_start:
    mov rdi, hello
    mov rsi, 13
    call print_func

    mov rax, 60
    xor rdi, rdi
    syscall ; exit
