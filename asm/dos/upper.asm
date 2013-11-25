assume cs:code,ss:stack,ds:data

stack segment
	dw 0,0,0,0,0,0,0,0
stack ends

data segment  ; upercase first four chars
	db '1. show         '
	db '2. edit         '
	db '3. open         '
	db '4. menu         '
	db '5. view         '
	db '6. help         '
data ends

code segment
	start:
	mov ax,data
	mov ds,ax
	
	mov ax,stack
	mov ss,ax
	mov sp,16
	
	mov cx,6
	mov bx,0
	outerloop:
		push cx
		mov cx,4
		mov di,3
		innerloop:
			mov al,[bx+di]
			and al,11011111b
			mov [bx+di],al
			inc di
		loop innerloop
		pop cx
		add bx,16
	loop outerloop
	
	mov ax,4c00h
	int 21h

code ends

end start