;Convert hex number to digital string

assume cs:code,ss:stack,ds:data
data segment
	db 64 dup (0)
data ends

stack segment
	db 16 dup (0)
stack ends

code segment
	start:
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	
	mov ax,0
	mov dx,0ffffh
	call dtos
	
	mov dh,12
	mov dl,34
	mov cl,2
	call prints
	
	mov ax,4c00h
	int 21h
	
	ntos:
		;Convert less than 0xffff number to digital string
		;Args:
		;ax => number
		;Returns:
		;ds:si => string start addr,string end with 0
		push ax
		push si
		push bx
		push dx
		
		mov bx,0 ;count string length
		divloop:
			mov dx,0
			mov cx,10
			div cx ;number store in ax
			add dl,30h 
			mov dh,0
			push dx ;double space,sigh~
			inc bx
			
			mov cx,ax
			jcxz return_ntos
		jmp divloop
		
		return_ntos:
		mov cx,bx
		poploop:
			pop ax
			mov ds:[si],al
			inc si
		loop poploop
		
		mov byte ptr ds:[si],0	
		pop dx
		pop bx
		pop si
		pop ax
		ret

	dtos:
		;Convert less than 0xFFFFFFFF number to digital string
		;Args:
		;dx => number high addr
		;ax => number low addr
		;Return:
		;ds:si	string start addr,end with zero
		push cx
		push bx
		push si
		
		dtos_divloop:
			mov cx,10
			call divdw
			add cx,30h
			push cx
			inc bx
			mov cx,dx
			jcxz jaxz
		loop dtos_divloop
		
		jaxz:
			mov cx,ax
			jcxz return_dtos
			jmp dtos_divloop
		
		return_dtos:
		mov cx,bx
		dtos_poploop:
			pop ax
			mov ds:[si],al
			inc si
		loop dtos_poploop
		
		mov byte ptr ds:[si],0	
		
		pop si
		pop bx
		pop cx
		ret
		
	
		
	divdw:
		;Args:
		;ax => divident low 16bit
		;dx => divident high 16bit
		;cx => divisor
		;Returns:
		;ax => quotient low 16bit
		;dx => quotient high 16bit
		;cx => remainder
		push bp
		push ax
		mov bp,sp
		push dx
		push cx	
		
		mov ax,dx
		sub dx,dx
		div cx
		
		push ax ;high bit quotient
		
		mov ax,ss:[bp] ; restore original ax
		div cx
		mov cx,dx ; total remainder
		pop dx
		
;		pop bp ;ignore pop
;		pop bp ;ignore pop
;		pop bp ;ignore pop
		add sp,6
		
		pop bp
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
