                section         .text

                global          _start
_start:

                sub             rsp, 3 * 128 * 8
                mov             rcx, 128
                lea             rdi, [rsp + 128 * 8]
                call            read_long
                lea             rdi, [rsp + 2 * 128 * 8]
                call            read_long
                lea             rbp, [rsp]
                lea             rdi, [rsp + 128 * 8]
                lea             rsi, [rsp + 2 * 128 * 8]
                call            mul_long_long

                call            write_long

                mov             al, 0x0a
                call            write_char

                jmp             exit

; muls two long number
;    rdi -- address of #1 (long number)
;    rsi -- address of #2 (long number)
;    rcx -- length of long numbers in qwords
; result:
;    composition is written to rdi
mul_long_long:
                ; save global data to stack
                push            rsi
                push            rcx
                push            rdx

                mov             rdx, rcx
                ; copy rdi -> rbp
                call            copy_long

                call            set_zero
                ; now rdi is store for answer
                ; reset flags
                clc
.loop:
                ; put 8 bytes [rsi] of second operand to rax
                mov             rax, [rsi]
                ; go to next bytes in second operand
                lea             rsi, [rsi + 8]

                ; rbp keeps shifting
                call            one_step
                call            shift_rbp

                ; decrease digit's counter
                dec             rcx
                jnz             .loop

                ; set correct values to global data from stack
                pop             rdx
                pop             rcx
                pop             rsi
                ret

;    rdi -- dest for adding
;    rbp -- what to add
;    rax -- how many times
;    rdx -- length of long number
one_step:
                sub             rsp, 128 * 8
                lea             r13, [rsp]

                push            rbp
                push            rcx
                mov             rcx, rdx

                ; copy rbp -> r13
                push            rdi
                mov             rdi, rbp
                mov             rbp, r13
                call            copy_long
                mov             rbp, rdi
                pop             rdi

                ; r13 = rax000...000
                push            rdi
                push            rbx
                mov             rdi, r13
                mov             rbx, rax
                call            mul_long_short
                pop             rbx
                pop             rdi

                push            rsi
                mov             rsi, r13
                call            add_long_long
                pop             rsi

                pop             rcx
                pop             rbp
                add             rsp, 128 * 8
                ret

; add zero digit to end of rbp
;    rdx - length
shift_rbp:
                push            rbx
                push            rcx
                push            rdi

                mov             rdi, rbp
                ; this number is 2^32
                mov             rbx, 4294967296
                mov             rcx, rdx
                call            mul_long_short
                call            mul_long_short

                pop             rdi
                pop             rcx
                pop             rbx
                ret

; adds two long number
;    rdi -- address of summand #1 (long number)
;    rsi -- address of summand #2 (long number)
;    rcx -- length of long numbers in qwords
; result:
;    sum is written to rdi
add_long_long:
                ; save global data to stack
                push            rdi
                push            rsi
                push            rcx
                push            rax
                ; reset flags
                clc
.loop:
                ; put one byte [rsi] of second operand to rax
                mov             rax, [rsi]
                ; go to next byte in second operand
                lea             rsi, [rsi + 8]
                adc             [rdi], rax
                ; go to next byte in first operand
                lea             rdi, [rdi + 8]
                ; decrease digit's counter
                dec             rcx
                jnz             .loop

                ; set correct values to global data from stack
                pop             rax
                pop             rcx
                pop             rsi
                pop             rdi
                ret


; adds 64-bit number to long number
;    rdi -- address of summand #1 (long number)
;    rax -- summand #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    sum is written to rdi
add_long_short:
                push            rdi
                push            rcx
                push            rdx
                push            rax

                xor             rdx,rdx
.loop:
                add             [rdi], rax
                adc             rdx, 0
                mov             rax, rdx
                xor             rdx, rdx
                add             rdi, 8
                dec             rcx
                jnz             .loop

                pop             rax
                pop             rdx
                pop             rcx
                pop             rdi
                ret

; multiplies long number by a short
;    rdi -- address of multiplier #1 (long number)
;    rbx -- multiplier #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    product is written to rdi
mul_long_short:
                push            rax
                push            rdi
                push            rcx
                push            rdx
                push            rsi

                xor             rsi, rsi
.loop:
                mov             rax, [rdi]
                mul             rbx
                add             rax, rsi
                adc             rdx, 0
                mov             [rdi], rax
                add             rdi, 8
                mov             rsi, rdx
                dec             rcx
                jnz             .loop

                pop             rsi
                pop             rdx
                pop             rcx
                pop             rdi
                pop             rax
                ret

; divides long number by a short
;    rdi -- address of dividend (long number)
;    rbx -- divisor (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    quotient is written to rdi
;    rdx -- remainder
div_long_short:
                push            rdi
                push            rax
                push            rcx

                lea             rdi, [rdi + 8 * rcx - 8]
                xor             rdx, rdx

.loop:
                mov             rax, [rdi]
                div             rbx
                mov             [rdi], rax
                sub             rdi, 8
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rax
                pop             rdi
                ret

; make a copy of long number
;    rdi -- address of source
;    rbp -- address of destination
;    rcx -- length of long number
copy_long:
                push            rdi
                push            rbp
                push            rcx
                push            rax
.loop:
                mov             rax, [rdi]
                mov             [rbp], rax
                add             rdi, 8
                add             rbp, 8
                dec             rcx
                jnz             .loop

                pop             rax
                pop             rcx
                pop             rbp
                pop             rdi
                ret

; assigns a zero to long number
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
set_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep stosq

                pop             rcx
                pop             rdi
                pop             rax
                ret

; checks if a long number is a zero
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
; result:
;    ZF=1 if zero
is_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep scasq

                pop             rcx
                pop             rdi
                pop             rax
                ret

; read long number from stdin
;    rdi -- location for output (long number)
;    rcx -- length of long number in qwords
read_long:
                push            rcx
                push            rdi

                call            set_zero
.loop:
                call            read_char
                or              rax, rax
                js              exit
                cmp             rax, 0x0a
                je              .done
                cmp             rax, '0'
                jb              .invalid_char
                cmp             rax, '9'
                ja              .invalid_char

                sub             rax, '0'
                mov             rbx, 10
                call            mul_long_short
                call            add_long_short
                jmp             .loop

.done:
                pop             rdi
                pop             rcx
                ret

.invalid_char:
                mov             rsi, invalid_char_msg
                mov             rdx, invalid_char_msg_size
                call            print_string
                call            write_char
                mov             al, 0x0a
                call            write_char

.skip_loop:
                call            read_char
                or              rax, rax
                js              exit
                cmp             rax, 0x0a
                je              exit
                jmp             .skip_loop

; write long number to stdout
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
write_long:
                push            rax
                push            rcx

                mov             rax, 20
                mul             rcx
                mov             rbp, rsp
                sub             rsp, rax

                mov             rsi, rbp

.loop:
                mov             rbx, 10
                call            div_long_short
                add             rdx, '0'
                dec             rsi
                mov             [rsi], dl
                call            is_zero
                jnz             .loop

                mov             rdx, rbp
                sub             rdx, rsi
                call            print_string

                mov             rsp, rbp
                pop             rcx
                pop             rax
                ret

; read one char from stdin
; result:
;    rax == -1 if error occurs
;    rax \in [0; 255] if OK
read_char:
                push            rcx
                push            rdi

                sub             rsp, 1
                xor             rax, rax
                xor             rdi, rdi
                mov             rsi, rsp
                mov             rdx, 1
                syscall

                cmp             rax, 1
                jne             .error
                xor             rax, rax
                mov             al, [rsp]
                add             rsp, 1

                pop             rdi
                pop             rcx
                ret
.error:
                mov             rax, -1
                add             rsp, 1
                pop             rdi
                pop             rcx
                ret

; write one char to stdout, errors are ignored
;    al -- char
write_char:
                sub             rsp, 1
                mov             [rsp], al

                mov             rax, 1
                mov             rdi, 1
                mov             rsi, rsp
                mov             rdx, 1
                syscall
                add             rsp, 1
                ret

exit:
                mov             rax, 60
                xor             rdi, rdi
                syscall

; print string to stdout
;    rsi -- string
;    rdx -- size
print_string:
                push            rax

                mov             rax, 1
                mov             rdi, 1
                syscall

                pop             rax
                ret


                section         .rodata
invalid_char_msg:
                db              "Invalid character: "
invalid_char_msg_size: equ             $ - invalid_char_msg
