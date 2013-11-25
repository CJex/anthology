;Clearn screen contents(All contents of current page and before current page)

assume cs:code

code segment
	start:
	
	call clear_screen
	mov ax,4c00h
	int 21h
	
	
	clear_screen: ;Clear screen contents before next page
		push ax
		push bx
		push dx
		push cx
		push ds
		push si
		
		;get current page number
		mov ah,03h
		int 10h ;now bh=page number,dh=line num,dl=column number
		
		;calc current page end byte length
		;one page 4000 byte
		;end addr = (page num+1) * 4000
		
		mov al,bh ;bh max is 7
		inc al
		mov bx,4000
		mov ah,0
		mul bx ;now ax  is the byte length
		
		mov cx,ax
		mov ax,0B800h
		mov ds,ax
		sub si,si
		clear_screen_loop:
			mov byte ptr ds:[si],20h ;set to space char
			add si,2
		loop clear_screen_loop
		
		pop si
		pop ds
		pop cx
		pop dx
		pop bx
		pop ax
	ret
	

code ends

end start