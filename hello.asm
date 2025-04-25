global _start
section .data
message: db 'hello, world!', 10
section .text
_start:
    mov     rax, 1
    mov     rdi, 1
    mov     rsi, message
    mov     rdx, 14
    syscall
    mov     rax, 60       ; exit syscall
    xor     rdi, rdi      ; exit with 0
    syscall