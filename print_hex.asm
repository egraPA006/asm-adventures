section .data
codes db '01234567890ABCDEF'
section .text
global _start
_start:
    mov rax, 15

    mov rdi, 1    ; filedescriptor
    ; rsi is buffer pointer
    mov rdx, 1     ; number of bytes, we will print by one byte
    mov rcx, 64
.loop: 
    push rax
    sub rcx, 4
    sar rax, cl
    and rax, 0xf
    lea rsi, [codes + rax]
    mov rax, 1
    push rcx
    syscall
    pop rcx
    pop rax
    test rcx, rcx
    jnz .loop
    ; And now we can exit
    mov     rax, 60       ; exit syscall
    xor     rdi, rdi      ; exit with 0
    syscall
