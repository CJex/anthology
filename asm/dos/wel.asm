assume cs:code,ss:stack

data segment
	db 'Hello,world!'
data ends

stack segment
	db 16 dup (0)
stack ends

code segment
	start:
	mov ax,0b800h
	mov es,ax   ;graphic memory start addr
	mov ax,data
	mov ds,ax

	
	;80 char x 25 line,low addr store ascii code,high addr store attribute
	
	mov cx,7fffh ;hole graphic buffer
	mov bx,0
	clearloop: ;clear screen
		mov byte ptr es:[bx],0
		inc bx
	loop clearloop

	;line 12 addr: 80*2*11=640h
	;center pre-indent chars count: (80-12)*2/2=68=44h
	;640h+44h=684h
	mov bx,684h
	mov cx,12 ;"Hello,world!" length=12
	charloop:
		push bx
		mov al,[di] ;char
		
		;Binary code: BL  R G B (BG) Highlight R G B(FG) 
		mov ah,00000010b ;green fg 00000010
		mov es:[bx],ax
		
		add bx,0a0h ;move to next line
		
		mov ah,00100100b;green bg and red fg  00100100
		mov es:[bx],ax
		
		add bx,0a0h ;move to next line
		
		mov ah,01110001b;white bg and blue fg 01110001
		mov es:[bx],ax
		
		pop bx
		
		;move to next char addr
		inc di
		add bx,2 

	loop charloop
	
	
	mov ax,4c00h
	int 21h
code ends

end start
