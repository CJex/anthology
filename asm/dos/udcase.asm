;Transfer string(ends with zero and contains any char) to upper case or lower case
assume cs:code,ds:data,ss:stack

data segment
	db "Hello,world!",0
data ends

stack segment
	db 64 dup (0)
stack ends

code segment
	start:
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	
	mov si,0
	call tolower
	mov dh,13
	mov dl,34
	mov cl,2
	call prints

	mov ax,4c00h
	int 21h
	
	
	toupper:
		push cx
		mov cx,0
		call chcase
		pop cx
		ret
		
	tolower:
		push cx
		mov cx,1
		call chcase
		pop cx
		ret

	chcase:
		;Args:
		;ds:si => string start addr
		;cx => if cx==0 ,toupper,else to lower
		push si
		push ax
		push cx
		push bx
		
		mov bx,cx ;backup cx
		
		jcxz cp_to_lower ;if cx==0,to upper,cmp lower range
		;else,set to upper range
		mov al,65
		mov ah,90
		jmp chcase_loop
		
		cp_to_lower:
		mov al,97
		mov ah,122
		
		
		chcase_loop:
			mov cx,0
			push cx
			popf  ;reset flag
			
			mov cl,ds:[si]
			jcxz chcase_return
			mov bh,cl ;now char is in bh
			mov cl,bl ;now cx is still means :upper or lower
			;judge if this char is in range
			cmp bh,al
			jb next_char
			cmp bh,ah
			ja next_char

			jcxz toupper_and
			or bh,00100000b
			jmp next_char
			
			toupper_and:
			and bh,11011111b
			
			next_char:
			mov ds:[si],bh
			inc si
		jmp chcase_loop
		
		chcase_return:
		pop bx
		pop cx
		pop ax
		pop si
		ret


	prints:
		; args:
		; ds:si => string start ptr
		; dh => line number(0-24)
		; dl => column number(0-79)
		; cl => string display attribute byte
		push ax 
		push bx
		push es
		push di
		push si
		push dx
		push cx
		
		
		
		;calc DisplayMemory addr
		mov al,0a0h ;one line 160 bytes
		mul dh ;multi line count
		add dl,dl ;column x 2byte
		mov dh,0
		add ax,dx 
		mov bx,ax ;DM start addr
		
		mov ax,0B800h 
		mov es,ax ;use es:[di] access DM
		
		mov dh,cl ;display attr now in dh
		mov di,0 ; count line printed byte
		s:
			mov cl,ds:[si]
			mov ch,0
			jcxz return
			sub cx,0ah ;if it is line break char
			jcxz newline
			add cx,0ah
			
			mov ch,dh
			mov es:[bx],cx
			inc si
			add di,2 
			add bx,2
		jmp s
		
		
		
		newline:
			mov ax,0A0h ;one line total byte - printed byte = new line skip byte
			sub ax,di ;new line addr
			add bx,ax
			inc si
			sub di,di 
		jmp s
		
		return:
		
		pop cx
		pop dx
		pop si
		pop di
		pop es
		pop bx
		pop ax
		ret
code ends

end start