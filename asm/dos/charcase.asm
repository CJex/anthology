assume cs:code

lower segment
	db 'lowerstring' ;11
lower ends

upper segment
	db 'UPPERSTRING' ;11
upper ends

code segment
	start:
	mov ax,lower
	mov ds,ax
	
	mov ax,upper
	mov es,ax
	
	mov cx,11
	mov bx,0
	s:
	mov al,[bx]
	and al,11011111b ;upper
	mov [bx],al
	mov al,es:[bx]
	or al,00100000b ;lower
	mov es:[bx],al
	inc bx
	loop s
	
	mov ax,4c00h
	int 21h
code ends


end start