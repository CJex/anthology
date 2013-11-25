assume cs:code

code segment
	db "Hello,World!"
	start:
	mov ax,0b800h
	mov ds,ax
	
	sub bx,bx
	sub di,di
	mov cx,12
	s:
		mov al,cs:[bx]
		mov ah,21h
		mov [di],ax
		inc bx
		add di,2
	loop s
	
	mov ax,4c00h
	int 21h

code ends

end start

