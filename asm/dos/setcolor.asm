;Set fg and bg color
assume cs:code

code segment
	start:
	mov al,01110010b ;set to green fg and white bg
	mov bx,3;set fg,bg
	call set_color
	mov ax,4c00h
	int 21h

	
	set_color:
		jmp short set_color_start
		color_reset_bits db 0,10001111b,11111000b,10001000b
		;Args:
		;al => color(Binary code: BL  R G B (BG) Highlight R G B(FG) )
		;bx => 
		;	0 to set all bit
		;	1 to set bg
		;	2 to set fg
		;	3 to set bg and fg
		;if you want to set bg only,left other bit to zero
		;Example :  al = 00010000b,bx=1 ;set bg to blue,unchange other bits
		set_color_start:
		push ax
		push cx
		push ds
		push si
		push bx
		push dx
		
		mov cl,color_reset_bits[bx] ;reset bit
		
		;get current page number
		mov ah,03h
		int 10h ;now bh=page number,dh=line num,dl=column number
		
		mov bl,al ;backup al to bl
		
		
		;calc current page end byte length
		;one page 4000 byte
		;end addr = (page num+1) * 4000
		
		mov al,bh;bh=page number
		inc al
		mov dx,4000
		mul dx ;now ax  is the byte length
		
		mov dh,cl ;mov reset bit to dh
		
		mov cx,ax
		mov ax,0B800h
		mov ds,ax
		mov si,1 ;high bit is display color attr
		set_color_loop:
			and byte ptr ds:[si],bh ;first reset bit
			or byte ptr ds:[si],bl
			add si,2
		loop set_color_loop
		
		
		pop dx
		pop bx
		pop si
		pop ds
		pop cx
		pop ax
		
	ret

code ends

end start