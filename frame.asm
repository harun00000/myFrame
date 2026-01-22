global _start

section .bss
buffer resq 8       
height resq 1        ; reserve 8 bytes
width resq 1
sym resb 1
text resq 8
row resq 1
col resq 1
textLen resq 1
midRow resq 1        ; = height / 2
startPrintCol resq 1
canPrint resq 1      ; bool 
inWidth resq 1       ; bool

section .data
enterHeightMsg db "Enter height : ", 10
heightMsgLen equ $ - enterHeightMsg

enterWidthMsg db "Enter width : ", 10
widthMsgLen equ $ - enterWidthMsg

enterSymMsg db "Enter symbol : ", 10
symMsgLen equ $ - enterSymMsg

enterTextMsg db "Enter text : ", 10
textMsgLen equ $ - enterTextMsg

newline db 10
space db ' '

section .text
_start:
    ; print heightMsg
    mov rax, 1
    mov rdi, 1
    mov rsi, enterHeightMsg
    mov rdx, heightMsgLen
    syscall

    ; read height
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 8
    syscall

    ; sym -> num and save
    call atoi
    mov [height], rax    ; [] - save rax by address

    ; print widthMsg
    mov rax, 1
    mov rdi, 1
    mov rsi, enterWidthMsg
    mov rdx, widthMsgLen
    syscall

    ; read width
    mov rax, 0
    mov rdi, 0
    mov rsi, buffer
    mov rdx, 8
    syscall

    ; sym -> num and save
    call atoi
    mov [width], rax; [] - save rax by address

    ; print symMsg
    mov rax, 1
    mov rdi, 1
    mov rsi, enterSymMsg
    mov rdx, symMsgLen
    syscall

    ; read sym
    mov rax, 0
    mov rdi, 0
    mov rsi, sym
    mov rdx, 2      ; + '\n'
    syscall

    ; print textMsg
    mov rax, 1
    mov rdi, 1
    mov rsi, enterTextMsg
    mov rdx, textMsgLen
    syscall

    ; read text
    mov rax, 0
    mov rdi, 0
    mov rsi, text
    mov rdx, 64
    syscall

    dec rax         ; remove \n from len
    mov [textLen], rax

    ; midRow inic
    mov rax, [height]
    shr rax, 1
    mov [midRow], rax

    ; inWidth = width - 2
    mov rbx, [width]
    cmp rbx, 2
    jle widthTooSmall
    sub rbx, 2
    mov [inWidth], rbx
    jmp widthOk

widthTooSmall:
    mov qword [inWidth], 0  ; inWidth = 0 by address    
    mov qword [canPrint], 0 ; similar
    jmp afterInitText

widthOk:
    ; if textLen > innerWidth: canPrint = 0
    mov rax, [textLen]
    cmp rax, 0
    je noTextPrint
    cmp rax, rbx
    jg noTextPrint

    ; startPrintCol = 1 + (innerWidth - textLen) / 2
    sub rbx, rax            ; innerWidth - textLen
    shr rbx, 1              ; / 2
    inc rbx                 ; +1 (skip left frame)
    mov [startPrintCol], rbx

    mov qword [canPrint], 1
    jmp afterInitText
    
noTextPrint:
    mov qword [canPrint], 0

afterInitText:
    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; row = 0 (smth like define, qword = 8 bytes)
    mov qword [row], 0

drawRow:
    ; if row >= heigth: col = 0, end
    mov rax, [row]
    cmp rax, [height]
    jge endProg

    mov qword [col], 0

drawCol:
    ; if col >= width: endRow
    mov rax, [col]
    cmp rax, [width]
    jge endRow

    ; if row == 0: printSym
    mov rax, [row]
    cmp rax, 0
    je printSym

    ; if row == height - 1: printSym
    mov rax, [row]
    mov rbx, [height]
    dec rbx
    cmp rax, rbx
    je printSym

    ; if col == 0: printSym
    mov rax, [col]
    cmp rax, 0
    je printSym

    ; if col == width - 1: printSym
    mov rax, [col]
    mov rbx, [width]
    dec rbx
    cmp rax, rbx
    je printSym

    ; if can`t print -> print space
    cmp qword [canPrint], 1
    jne printSpace

    ; if row != mid row (row that we need) -> print space
    mov rax, [row]
    cmp rax, [midRow]
    jne printSpace

    ; similar with col
    mov rax, [col]
    cmp rax, [startPrintCol]
    jne printSpace

    jmp printText

printSpace:
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 1
    syscall

nextCol:
    ; col++ and repeat drawCol
    inc qword [col]
    jmp drawCol

printSym:
    mov rax, 1
    mov rdi, 1
    mov rsi, sym
    mov rdx, 1
    syscall

    jmp nextCol

printText:
    mov rax, 1
    mov rdi, 1
    mov rsi, text
    mov rdx, [textLen]
    syscall

    mov rax, [textLen]
    add qword [col], rax
    jmp drawCol

endRow:
    ; print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; row++ and repeat drawRow
    inc qword [row]
    jmp drawRow

endProg:
    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

atoi:
    xor rax, rax
    xor rcx, rcx    ; counter = 0
    mov rsi, buffer

atoiCycle:
    movzx r8, byte [rsi + rcx]  ; array logic

    cmp r8, 10      ; \n ?
    je atoiReady    ; jump if equal

    cmp r8, 0       ; 0-terminator
    je atoiReady

    cmp r8, '0'
    jl atoiReady    ; jump if less

    cmp r8, '9'
    jg atoiReady    ; jump if greater

    sub r8, '0'     ; sym -> num
    imul rax, 10    ; *10
    add rax, r8
    inc rcx         ; rcx++
    jmp atoiCycle

atoiReady:
    ret
