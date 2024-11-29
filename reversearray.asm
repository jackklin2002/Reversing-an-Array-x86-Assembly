includelib ucrt.lib
includelib legacy_stdio_definitions.lib

ExitProcess PROTO
EXTERN printf: PROC
EXTERN malloc: PROC

.data
    Message db "%lld ", 0      ; Define a null-terminated string format for printf
    x dq 0

.code
generateRandomNumbers PROC
    mov r15, rcx

    ; Multiply the length of the array by 8 to get the total number
    ; of bytes required for our 64-bit numbers
    shl rcx, 3

    sub rsp, 40
    call malloc

    ; This is the address of our new block in memory
    mov r14, rax

randomNumberLoop:
    ; NOTE: Could use rand() from C, but we choose to use rdrand instead, as it
    ; gives us "more random" numbers from the CPU's thermal noise.
    rdrand rax

    ; Move the random number into the array
    mov [r14 + r15 * 8], rax

    dec r15
    cmp r15, 0
    jge randomNumberLoop

    mov rax, r14
    add rsp, 40
    ret
generateRandomNumbers ENDP

ReverseArray PROC
    mov rdi, rdx               ; end = size - 1

reverseLoop:
    ; Swap elements pointed to by rsi and rdi
    mov r8, x
    mov rax, [r8 + rsi * 8]  ; Load element from the start pointer
    mov rbx, [r8 + rdi * 8]  ; Load element from the end pointer
    mov [r8 + rsi * 8], rbx  ; Store the end element at the start
    mov [r8 + rdi * 8], rax  ; Store the start element at the end

    inc rsi                  ; Move start pointer forward
    dec rdi                  ; Move end pointer backward

    cmp rsi, rdi
    jl reverseLoop

    ret
ReverseArray ENDP

mainCRTStartup PROC
    mov rcx, 1000000 ; Set the number of random numbers to generate (1 million)
    sub rsp, 40
    call generateRandomNumbers  ; Call the generateRandomNumbers function
    mov x, rax ; Store the size of the array

    mov rdx, 0                  ; Initialize rdx with 0 (no floating-point arguments)
    lea r8, [x]                  ; Load the address of the integer array into r8
    sub rsp, 40
    mov rcx, x
    call ReverseArray           ; Call the ReverseArray function

    ; Print the reversed array or generated random numbers
    mov r14, x               ; Load the address of the reversed array into r14
    mov r15, 1000000                ; Load the size of the array into r15 (1 million)

    ; Loop to print each element in the reversed array or random numbers
    mov rsi, 0                  ; Initialize index to 0

printLoop:
    mov rdx, [r14 + rsi * 8]  ; Load the current element from the reversed array or random numbers
    mov rcx, offset Message   ; Load the address of the format string into rcx
    sub rsp, 40
    call printf               ; Call printf for the current element
    add rsp, 40               ; Adjust the stack pointer to account for the printf call
    inc rsi                   ; Move to the next element
    cmp rsi, r15            ; Compare the index with the size of the array or random numbers
    jl printLoop

    ; Reset registers for printing reversed array
    mov rsi, 0
    mov rdi, 999999                 ; Adjust rdi to the size of the array - 1 (1 million - 1)

    mov ecx, 0                 ; Set the exit code to 0
    call ExitProcess           ; Call the ExitProcess function

mainCRTStartup ENDP

END                             ; End of the program
