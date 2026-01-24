DEFAULT REL
; --- Macros ---
%define AF_INET 2
%define SOCK_STREAM 1
%define PROTOCOL 0
; --------------

; -------------
; Note
; In this program RBX is
; treated as debug reference
; store to track errors
;
; Start of subroutine call
; a dbg_ref needs to be set to RBX
; and the dbg_len to RBP
; -------------


section .data
  msg db "Starting HTTP Server ...", 10  ; msg variable name, db is define bytes, 10 is dec newline
  len equ $ - msg

  start_http_server_dbg_ref db "LABEL START_HTTP_SERVER", 10  ; debug label reference
  start_http_server_dbg_len equ $ - start_http_server_dbg_ref ; len of the reference

section .bss
  sockfd resq 1           ; Socket file descriptor
  buf  resb 20          ; buffer for ASCII conversion (max 20 digits)


section .text
global _start

_start:
  call   print_start
  call   start_http_server
  call   inf_loop
  jmp   exit

start_http_server:
  mov   rbx, start_http_server_dbg_ref   ; set dbg reference
  mov   rbp, start_http_server_dbg_len   ; set dbg reference len

  ; create the socket
  mov   rax, 0x29         ; sys_socket
  mov   rdi, AF_INET      ; domain
  mov   rsi, SOCK_STREAM  ; type
  mov   rdx, PROTOCOL     ; protocol
  syscall
  mov   [sockfd], rax     ; store return value
  mov   rax, [sockfd]

  ; check for error
  cmp   qword [sockfd], 0 ; check if negative
  jl    panic

  call itoa_rax_to_ascii
  
  mov   rax, 0x01         ; sys_write
  mov   rdi, 0x01         ; set std_out
  syscall
  ret

print_start:
  mov   rax, 0x01       ; sys_write
  mov   rdi, 0x01       ; set std_out
  mov   rsi, msg        ; move char ptr into
  mov   rdx, len        ; move string len into
  syscall
  ret

inf_loop:
  jmp inf_loop


panic:
  mov   rax, 0x01       ; sys_write
  mov   rdi, 0x01       ; set std_out
  mov   rsi, rbx        ; set current dbg reference to rsi
  mov   rdx, rbp        ; set dbg reference len
  syscall
  jmp exit


;-------------------------------
; convert RAX to ASCII decimal
; output: RSI = pointer to first digit, RDX = length
;-------------------------------
itoa_rax_to_ascii:
    lea rdi, [buf + 19]  ; start at end of buffer
    mov rcx, 0            ; digit count
.next_digit:
    xor rdx, rdx
    mov rbx, 10
    div rbx               ; RAX / 10 -> quotient in RAX, remainder in RDX
    add dl, '0'           ; convert remainder to ASCII
    dec rdi
    mov [rdi], dl
    inc rcx
    test rax, rax
    jnz .next_digit
    mov rsi, rdi          ; pointer to first digit
    mov rdx, rcx          ; length
    ret


exit:
  mov rax, 0x3c         ; sys_exit
  mov rdi, 0x00         ; exit code = 0
  syscall
