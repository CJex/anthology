assume cs:code2

;code segment
;	start:
;	mov ax,2000H
;	mov ds,ax
;	mov bx,0
;	sub ax,ax
;	s:
;		mov al,[bx]
;		mov cx,ax
;		jcxz exit
;		inc bx
;	jmp short s
	
;	exit:
;	mov dx,bx
;	mov ax,4c00h
;	int 21h
	
;code ends

code2 segment
	start2:
	mov ax,2000h
	mov ds,ax
	mov bx,0
	
	s2:
		mov cl,[bx]
		mov ch,0
		inc cx
		inc bx
	loop s2
	
	ok:
	dec bx
	mov dx,bx
	mov ax,4c00h
	int 21h

code2 ends

end start2