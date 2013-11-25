assume cs:code,ss:stack

;calc employee everage salary

data segment 
	;21 years
	db '1975','1976','1977','1978','1979','1980','1981'
	db '1982','1983','1984','1985','1986','1987','1988'
	db '1989','1990','1991','1992','1993','1994','1995'
	
	;company income
	dd 16,22,383,1356,2390,8000,16000,24486,50065,97479
	dd 140417,197514,345980,590827,803530,1183000,1843000
	dd 2759000,3753000,4649000,5937000
	
	;employee count
	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258
	dw 2793,4037,5635,8226,11542,14430,15257,17800
data ends

table segment
	db "Year    Income    Employee Count    Everage Salary",0Ah
	db 2048 dup(20h) ;space char fill
	;Warning!!!!!!!!!!!!!!!!!!!!!!!!!
	;At the beginning,I have only allocate 256 byte.
	;Then memory overflow accurred,data has been write to code section
	;Then error report:CPU had meet bad instruction
table ends

tmp segment
	db 32 dup(0)
tmp ends

stack segment
	db 64 dup(0)
stack ends

code segment
	start:
	mov ax,data
	mov ds,ax
	
	mov ax,table
	mov es,ax
	
	mov ax,stack
	mov ss,ax
	
	mov si,51 ; skip table header 51 byte string
	mov di,0
	mov bx,0
	mov cx,21
	table_loop:
		push cx
		
		call read_year
		
		call read_income

		;read employee count
		mov ax,ds:[bx+168]
		mov dx,0
		
		push ds
		mov cx,es
		mov ds,cx
		call dtos
		pop ds
		mov ax,si
		call untilzero_es_si
		mov byte ptr es:[si],20h;replace zero with space
		mov cx,si
		sub cx,ax ;str len
		mov ax,18 ;employee count col width
		sub ax,cx
		add si,ax
		
		;calc everage
		mov ax,ds:[di+84]
		mov dx,ds:[di+86] ;income
		
		mov cx,ds:[bx+168] ; employee count
		
		call divdw
		;convert everage (dx)(ax)  to string
		push ds
		mov cx,es
		mov ds,cx
		call dtos 
		pop ds
		mov ax,si
		call untilzero_es_si
		mov byte ptr es:[si],20h;replace zero with space
		mov cx,si
		sub cx,ax ;str len
		mov ax,14 ;Everage Salary col width
		sub ax,cx
		add si,ax
		mov byte ptr es:[si],0aH
		inc si
		

		add di,4
		add bx,2
		pop cx
	loop table_loop
	
	mov dl,0
	mov dh,12
	mov cl,00000111b
	mov ax,es
	mov ds,ax
	mov si,0
	call prints
	
	mov ax,4c00h
	int 21h
	
	read_income:
		;read income
		;mov bx,84 ;income section offset addr
		mov ax,ds:[di+84]
		mov dx,ds:[di+86]
		
		push ds
		mov cx,es
		mov ds,cx
		call dtos ;convert income to string
		pop ds
		mov ax,si
		call untilzero_es_si ;let si increase to zero string ends addr
		mov byte ptr es:[si],20h;replace zero with space
		mov cx,si
		sub cx,ax ;str len
		mov ax,10 ;Income col width
		sub ax,cx ; skip space num
		add si,ax
		ret
	
	read_year:
		mov ax,ds:[di]
		mov es:[si],ax
		mov ax,ds:[di+2]
		add si,2
		mov es:[si],ax ; year
		
		add si,6 ;with 4 spaces
		ret
	
	untilzero_es_si:
		push cx
		mov cx,0
		untilzero_es_si_loop:
			mov cl,es:[si]
			jcxz ret_untilzero_es_si
			inc si
		loop untilzero_es_si_loop
		
		ret_untilzero_es_si:
		pop cx
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
		mov bx,0
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
		
		add sp,6
		
		pop bp
		ret
	
	prints:
		;Args:
		;ds:si => string start ptr
		;dh => line number(0-24)
		;dl => column number(0-79)
		;cl => string display attribute byte
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