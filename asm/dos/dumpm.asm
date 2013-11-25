;Dump memory contents as hex strings to screen.
assume cs:code,ss:stack,ds:data

data segment
	db "Hello,world!"
	db "Dump memory contents as hex strings to screen."
	db "Dump memory contents as hex strings to screen."
	db "HAHA!!"
data ends

stack segment

stack ends

extra segment
	db 512 dup (0)  ;Warning:static memory allocate 
	;sometimes it's size may be less than needed
extra ends

code segment
	start:
	mov ax,stack
	mov ss,ax
	
	mov ax,data
	mov ds,ax
	
	mov si,0
	mov cx,100
	call dumpm
	
	mov dl,0
	mov dh,12
	mov cl,2
	mov ax,es
	mov ds,ax
	call prints
	
	
	
	mov ax,4c00h
	int 21h
	
	
	
	dumpm:
		;Args:
		;ds:si => memory start addr
		;cx => byte length
		;Returns:
		;es:di => string start addr,end with zero
		push si
		push ax
		push bx
		mov ax,extra
		mov es,ax
		
		nextbyte:
			mov al,ds:[si] ;get one byte
			mov ah,0
			mov bl,16
			div bl ;now al is quotien,ah is remainder
			mov bx,ax
			call ntoc
			mov bl,al ;now bl is first char
			mov al,bh ;convert remainder to char
			call ntoc
			mov bh,al ;now bh is second char
			
			mov es:[di],bx
			add di,2
			mov byte ptr es:[di],32 ;space
			
			inc si
			inc di
		loop nextbyte
		
		mov byte ptr es:[di],0
		pop bx
		pop ax
		pop si
		
		ret
	
	
	ntoc:
		;Convert 0-f number to char "0"-"f"
		;Args:
		;al => store 0-f number
		;Returns:
		;al => store coreesponding char code
		push cx

		mov ah,0
		mov cl,10
		div cl ;now al is quotient
		mov cl,al
		mov ch,0

		jcxz ztonc ; zero to nine convert when quotient is zero
		jmp atofc ;"a" to "f" convert 
		
		ztonc:
		mov al,48
		jmp ntocreturn
		
		atofc:
		mov al,65
		jmp ntocreturn
		
		ntocreturn:
		add al,ah ;add remainder
		
		pop cx
		ret
	
	
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