assume cs:code
;When you run this program in cmd.exe. The total scroll up lines will come out more two line.
code segment
	start:
	
	mov al,3 ;scroll up 1 line
	call scroll_line
	
	mov ax,4c00h
	int 21h
	
	scroll_line:
		;Scroll screen up N  lines
		;Args:
		;al => 1 - 25  line number
		push ax
		push bx
		push cx
		push dx
		push ds
		push si
		push es
		push di
		pushf
		
		xor ch,ch
		mov cl,al
		jcxz scroll_line_return ;if al=0,do nothing
		cmp al,25
		ja set_al_to_25
		cmp al,1
		jb set_al_to_1 ;ensure al is in range(1,25)
		
		after_fix_al:
		mov bx,0b800h
		mov ds,bx
		mov es,bx
		
		;get scroll to line start addr
		;al is line inc/dec count
		mov dl,160
		mul dl
		mov bx,ax ;now bx is line inc/dec byte length
		
		mov di,0 ;es:[di] dest addrs
		mov si,bx ;ds:[si] source addr
		
		mov cx,0FA0h ;one page byte size
		cld ;inc si,di
		rep movsb
		mov cx,0FA0h
		sub cx,bx
		scroll_clear_loop:
			mov byte ptr es:[di],' '
			inc di
			inc di
		loop scroll_clear_loop
		
		
		scroll_line_return:
		popf
		pop di
		pop es
		pop si
		pop ds
		pop dx
		pop cx
		pop bx
		pop ax
	ret
	
	set_al_to_25:
		mov al,25
		jmp short after_fix_al
	set_al_to_1:
		mov al,1
		jmp short after_fix_al

	
	
code ends

end start