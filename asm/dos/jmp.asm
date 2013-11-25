assume cs:code

data segment
	nop
	nop
	nop
	nop
data ends

code segment
	start:
	mov ax,data
	mov ds,ax
	mov bx,0
	mov word ptr [bx],offset start
	mov [bx+2],cs
	jmp dword ptr ds:[0]
	;jmp short s
	;jmp near ptr s
	;jmp far ptr s

code ends

end start