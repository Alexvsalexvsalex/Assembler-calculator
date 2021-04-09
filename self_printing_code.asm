                section         .text

                global          _start
_start:

                call            print_program

                jmp             exit


; print one char to stdout, errors are ignored
;    al -- char
print_char:
				push 			rax
                push 			rdi
                push 			rdx
                push 			rcx
                sub             rsp, 1
                mov             [rsp], al

                mov             rax, 1
                mov             rdi, 1
                mov             rsi, rsp
                mov             rdx, 1
                syscall
                add             rsp, 1

                pop 			rcx
                pop 			rdx
                pop 			rdi
                pop 			rax
                ret

print_slash_n:
				mov 			al, 0x27
				call 			print_char
				mov 			al, ','
				call 			print_char
				mov 			al, '0'
				call 			print_char
				mov 			al, 'x'
				call 			print_char
				mov 			al, '0'
				call 			print_char
				mov 			al, 'a'
				call 			print_char
				mov 			al, ','
				call 			print_char
				mov 			al, 0x27
				call 			print_char
				ret

print_apostrophe:
				mov 			al, 0x27
				call 			print_char
				mov 			al, ','
				call 			print_char
				mov 			al, '0'
				call 			print_char
				mov 			al, 'x'
				call 			print_char
				mov 			al, '2'
				call 			print_char
				mov 			al, '7'
				call 			print_char
				mov 			al, ','
				call 			print_char
				mov 			al, 0x27
				call 			print_char
				ret

; print result
;	 rdi -- begin of escaped string
; 	 rdx -- escaped string size
print_program:
				mov 			rcx, program_size
				dec 			rcx

.loop:
				mov 			bl, [program + rcx]
				cmp 			bl, '!'
				je 				.finish_loop
				dec 			rcx
				cmp 			rcx, 0
				jne 			.loop

.finish_loop:	
				mov 			rsi, program
				mov 			rdx, rcx
				call 			print_string

				call 			print_escaped_program

				inc 			rcx
				add 			rsi, rcx
				mov 			rdx, program_size
				sub 			rdx, rcx
				call 			print_string

				ret

; 	 bl -- char
print_escaped_char:
				push 			rax
				cmp 			bl, 0x0a
				jne 			.skip1
				call 			print_slash_n
				jmp 			.success_print
.skip1:
				cmp 			bl, 0x27
				jne 			.skip2
				call 			print_apostrophe
				jmp 			.success_print
.skip2:
				mov 			al, bl
				call 			print_char

.success_print:
				pop 			rax
				ret

; print escaped string in [program]
print_escaped_program:
				push 			rsi
				push 			rdx
                push 			rcx

                mov 			rcx, 0
.loop4:
				mov 			bl, [program + rcx]
 
 				call 			print_escaped_char
				
				inc 			rcx
				cmp 			rcx, program_size
                jne 			.loop4

                pop 			rcx
                pop 			rdx
                pop 			rsi

                ret

; print string to stdout
;    rsi -- string
;    rdx -- size
print_string:
                push            rax
                push 			rdi
                push 			rcx

                mov             rax, 1
                mov             rdi, 1
                syscall

                pop 			rcx
                pop 			rdi
                pop             rax
                ret


exit:
                mov             rax, 60
                xor             rdi, rdi
                syscall


                section         .rodata
program: 		db              '                section         .text',0x0a,'',0x0a,'                global          _start',0x0a,'_start:',0x0a,'',0x0a,'                call            print_program',0x0a,'',0x0a,'                jmp             exit',0x0a,'',0x0a,'',0x0a,'; print one char to stdout, errors are ignored',0x0a,';    al -- char',0x0a,'print_char:',0x0a,'				push 			rax',0x0a,'                push 			rdi',0x0a,'                push 			rdx',0x0a,'                push 			rcx',0x0a,'                sub             rsp, 1',0x0a,'                mov             [rsp], al',0x0a,'',0x0a,'                mov             rax, 1',0x0a,'                mov             rdi, 1',0x0a,'                mov             rsi, rsp',0x0a,'                mov             rdx, 1',0x0a,'                syscall',0x0a,'                add             rsp, 1',0x0a,'',0x0a,'                pop 			rcx',0x0a,'                pop 			rdx',0x0a,'                pop 			rdi',0x0a,'                pop 			rax',0x0a,'                ret',0x0a,'',0x0a,'print_slash_n:',0x0a,'				mov 			al, 0x27',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,',',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'0',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'x',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'0',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'a',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,',',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, 0x27',0x0a,'				call 			print_char',0x0a,'				ret',0x0a,'',0x0a,'print_apostrophe:',0x0a,'				mov 			al, 0x27',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,',',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'0',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'x',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'2',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,'7',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, ',0x27,',',0x27,'',0x0a,'				call 			print_char',0x0a,'				mov 			al, 0x27',0x0a,'				call 			print_char',0x0a,'				ret',0x0a,'',0x0a,'; print result',0x0a,';	 rdi -- begin of escaped string',0x0a,'; 	 rdx -- escaped string size',0x0a,'print_program:',0x0a,'				mov 			rcx, program_size',0x0a,'				dec 			rcx',0x0a,'',0x0a,'.loop:',0x0a,'				mov 			bl, [program + rcx]',0x0a,'				cmp 			bl, ',0x27,'!',0x27,'',0x0a,'				je 				.finish_loop',0x0a,'				dec 			rcx',0x0a,'				cmp 			rcx, 0',0x0a,'				jne 			.loop',0x0a,'',0x0a,'.finish_loop:	',0x0a,'				mov 			rsi, program',0x0a,'				mov 			rdx, rcx',0x0a,'				call 			print_string',0x0a,'',0x0a,'				call 			print_escaped_program',0x0a,'',0x0a,'				inc 			rcx',0x0a,'				add 			rsi, rcx',0x0a,'				mov 			rdx, program_size',0x0a,'				sub 			rdx, rcx',0x0a,'				call 			print_string',0x0a,'',0x0a,'				ret',0x0a,'',0x0a,'; 	 bl -- char',0x0a,'print_escaped_char:',0x0a,'				push 			rax',0x0a,'				cmp 			bl, 0x0a',0x0a,'				jne 			.skip1',0x0a,'				call 			print_slash_n',0x0a,'				jmp 			.success_print',0x0a,'.skip1:',0x0a,'				cmp 			bl, 0x27',0x0a,'				jne 			.skip2',0x0a,'				call 			print_apostrophe',0x0a,'				jmp 			.success_print',0x0a,'.skip2:',0x0a,'				mov 			al, bl',0x0a,'				call 			print_char',0x0a,'',0x0a,'.success_print:',0x0a,'				pop 			rax',0x0a,'				ret',0x0a,'',0x0a,'; print escaped string in [program]',0x0a,'print_escaped_program:',0x0a,'				push 			rsi',0x0a,'				push 			rdx',0x0a,'                push 			rcx',0x0a,'',0x0a,'                mov 			rcx, 0',0x0a,'.loop4:',0x0a,'				mov 			bl, [program + rcx]',0x0a,' ',0x0a,' 				call 			print_escaped_char',0x0a,'				',0x0a,'				inc 			rcx',0x0a,'				cmp 			rcx, program_size',0x0a,'                jne 			.loop4',0x0a,'',0x0a,'                pop 			rcx',0x0a,'                pop 			rdx',0x0a,'                pop 			rsi',0x0a,'',0x0a,'                ret',0x0a,'',0x0a,'; print string to stdout',0x0a,';    rsi -- string',0x0a,';    rdx -- size',0x0a,'print_string:',0x0a,'                push            rax',0x0a,'                push 			rdi',0x0a,'                push 			rcx',0x0a,'',0x0a,'                mov             rax, 1',0x0a,'                mov             rdi, 1',0x0a,'                syscall',0x0a,'',0x0a,'                pop 			rcx',0x0a,'                pop 			rdi',0x0a,'                pop             rax',0x0a,'                ret',0x0a,'',0x0a,'',0x0a,'exit:',0x0a,'                mov             rax, 60',0x0a,'                xor             rdi, rdi',0x0a,'                syscall',0x0a,'',0x0a,'',0x0a,'                section         .rodata',0x0a,'program: 		db              ',0x27,'!',0x27,'',0x0a,'program_size: 	equ             $ - program',0x0a,''
program_size: 	equ             $ - program
