;Print zero ends string procedure
;80 char x 25 line

assume cs:code,ss:stack,ds:data

data segment
	db "Hello ,world!",0Ah,"HA!!!",0
	db "Hello ,world!",0Ah,"New Line!",0Ah,0
data ends

stack segment
	db 32 dup(0)
stack ends

code segment
	start:
	mov ax,data
	mov ds,ax
	mov si,0
	mov dh,12 ; line 13
	mov dl,34 ;column 34
	mov cl,00000010b ;green fg
	call prints
	
	mov si,13h
	mov dh,0
	mov dl,34
	mov cl,11111001b
	call prints
	
	
	
	mov ax,4c00h
	int 21h


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