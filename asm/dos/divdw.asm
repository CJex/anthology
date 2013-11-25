;divdw , dword/word = dword
; dividend is dword
; divisor is word
; quotient is dword
; div avoid overflow
assume cs:code,ss:stack,ds:data
stack segment
	dw 16 dup (0)
stack ends

tpl segment
	db "DX is:",0,0,0,0,0aH
	db "AX is:",0,0,0,0,0aH
	db "CX is:",0,0,0,0,0aH
	db 0
tpl ends

data segment
	db 32 dup (0)
data ends

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
	
	
	
;	mov ax,4240h
;	mov dx,000fh
;	mov cx,0ah
;	call divdw ; 0xf4240 / 0x0a = 0x186a0 ...... 0
	;Expected:
	;dx=0001h  - high addr
	;ax=86a0h  - low addr
	;cx=0
	
	mov ax,3bd7h
	mov dx,26h
	mov cx,13
	call divdw ; 0x263bd7 / 0xd = 0x2f0e9 ...... 2
	;Expected
	;dx=0002h
	;ax=f0e9h
	;cx=2
	
	
	
	mov ds:[0],dx
	mov ds:[2],ax
	mov ds:[4],cx
	mov cx,6
	mov si,0
	call dumpm ;convert dx,ax,cx to string in es:[0]
	mov ax,tpl
	mov ds,ax
	
	;Warning:dumpm use low addr first,high addr second
	;here need put high addr first,low addr second in display string
	;copy dx string
	mov ax,es:[2]
	mov ds:[6],ax
	mov ax,es:[0]
	mov ds:[8],ax
	
	;copy ax string
	mov ax,es:[6]
	mov ds:[17],ax
	mov ax,es:[4]
	mov ds:[19],ax
	
	;copy cx string
	mov ax,es:[10]
	mov ds:[28],ax
	mov ax,es:[8]
	mov ds:[30],ax

	
	mov dl,0
	mov dh,12
	mov cl,2
	
	call prints
	
	mov ax,4c00h
	int 21h
	
	
	
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
			;mov byte ptr es:[di],32 ;space
			;inc di
			
			inc si
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