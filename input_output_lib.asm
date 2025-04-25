global _start
section .data
test: db '-23', 0
test1: db '-24', 0
section .text

; rdi is a exit code
exit:
    mov rax, 60
    syscall
    ; no need to return from exit)

; rdi is pointer to the string
string_length:
    mov rax, 0 ; we start with zero
.loop:
    cmp byte [rdi + rax], 0 ; check if it is null character
    je .end
    inc rax
    jmp .loop
.end:
    ; the line is over
    ret
    ; rax should return the answer

print_newline:
    mov rdi, 0xA
; rdi is the character to print
print_char:
    push rdi
    mov rax, 1
    mov rdi, 1
    lea rsi, [rsp]
    mov rdx, 1
    syscall
    pop rdi
    ret


; rdi is pointer to beginning of string
print_string:
    push rdi
    call string_length
    mov rdx, rax
    mov rax, 1
    pop rsi
    mov rdi, 1
    syscall
    ret

; rdi - integer to output
print_int:
    cmp rdi, 0
    jge print_uint
    push rdi
    mov rdi, 45
    call print_char
    pop rdi
    neg rdi
print_uint:
    push r15
    push r12
    push r13
    push r14
    mov r14, rsp
    mov r15, 10 ; just constant
    xor r12, r12 ; register to push on stack
    mov r13, 1 ; counter of shifts
    mov rax, rdi
.loop:  ; first we create a buffer
    xor rdx, rdx
    div r15
    add rdx, 48
    sal r12, 8
    mov r12b, dl
    inc r13
    cmp rax, 0
    je .end
    cmp r13, 8
    jne .loop
    push r12
    xor r13, r13
    xor r12, r12
    jmp .loop
.end:
    xor r15, r15
    cmp r13, 0
    je .fend
.floop:
    cmp r13, 8
    je .fend
    sal r12, 8
    inc r13
    inc r15
    jmp .floop
.fend:
    push r12
    mov rdi, rsp
    add rdi, r15
    call print_string
    mov rsp, r14
    pop r14
    pop r13
    pop r12
    pop r15
    ret
; 0x7fffffffe0d8

; read char, if ctrl+D then return 0
read_char:
    push byte 0
    mov rax, 0 
    mov rdi, 0
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rax
    cmp rax, 4
    jne .end
    mov rax, 0
.end:
    ret

; rdi is buffer addres; rsi is size
read_word:
    push r12
    mov r12, rdi
    push r13
    mov r13, rsi
.loop:
    call read_char
    cmp rax, 0
    je .end
    cmp rax, 32
    je .end
    cmp rax, 10
    je .end
    cmp rax, 4
    je .end
    mov byte [r12], al
    dec r13
    inc r12
    cmp r13, 0
    mov rax, 0
    je .end
    jmp .loop
.end:
    pop r13
    pop r12
    ret

; parse a string for int starting at rdi (should be null terminated)
parse_uint:
    push r15  ; just constant
    push r14 ; store current char
    push r12
    push rdi
    call string_length
    pop rdi
    mov rcx, rax ; length of stringrdi
    call exit
    mov r15, 10
    xor r14, r14
    xor r12, r12
    xor rax, rax
    mov rdx, rcx
.loop:
    cmp rcx, 0
    je .end
    mov r14b, byte [rdi + r12]
    cmp r14, 48 ; 0 is 48
    jl .error
    cmp r14, 57
    jg .error
    mul r15
    add r14b, -48
    add rax, r14
    dec rcx
    inc r12
    jmp .loop
.error:
    mov rax, -1
.end:
    pop r12
    pop r14
    pop r15
    ret

; parse a string for int starting at rdi (should be null terminated)
parse_int:
    push r12  ; just constant
    push r14 ; store current char
    push r13
    push r15
    push rdi
    call string_length
    pop rdi
    mov rcx, rax ; length of string
    mov r12, 10
    xor r14, r14
    xor r13, r13
    xor rax, rax
    xor r15, r15 ; a flag if need to negate
    mov r14b, byte [rdi]
    cmp r14, 45
    jne .loop
    inc r13
    dec rcx
    mov rdx, rcx
    mov r15, 1
.loop:
    cmp rcx, 0
    je .cont
    mov r14b, byte [rdi + r13]
    cmp r14, 48 ; 0 is 48
    jl .error
    cmp r14, 57
    jg .error
    mul r12
    add r14b, -48
    add rax, r14
    dec rcx
    inc r13
    jmp .loop
.cont:
    cmp r15, 0
    je .end
    neg rax
    jmp .end
.error:
    mov rax, -1
.end:
    pop r15
    pop r13
    pop r14
    pop r12
    ret

; rdi and rsi are pointers to zero terminated strings
; rax 0 - not equal
; rax 1 - equal
string_equals:
    push r14
    push r13
    push r12
    push rdi
    push rsi
    call string_length
    pop rdi
    mov r14, rax
    call string_length
    pop rsi
    cmp r14, rax
    jne .error
    mov rcx, rax
    xor r14, r14
    xor r13, r13
    xor r12, r12
    mov rax, 1
.loop:
    cmp rcx, 0
    je .end
    mov r12b, byte [rdi + r14]
    mov r13b, byte [rsi + r14]
    cmp r12, r13
    jne .error
    inc r14
    dec rcx
    jmp .loop
.error:
    xor rax, rax
.end:
    pop r12
    pop r13
    pop r14
    ret
; rdi pointer to string, rsi - pointer to buffer, rdx - length of buffer
string_copy:
    push r14
    push rdi
    push rsi
    push rdx
    call string_length
    pop rdx
    pop rsi
    pop rdi
    mov rcx, rax
    inc rcx
    cmp rcx, rdx
    jg .error
    xor r14, r14
    mov rax, rsi
.loop:
    cmp rcx, 0
    je .end
    mov dl, byte [rdi+r14]
    mov byte [rsi+r14], dl
    inc r14
    dec rcx
    jmp .loop
.error:
    xor rax, rax
.end:
    pop r14
    ret

_start:
    mov rdi, -25
    call print_int
    xor rdi, rdi
    call exit
    