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
	db 21 dup('year summ ne ?? ')
table ends

stack segment
	db 16 dup(0)
stack ends

code segment
	start:
	mov ax,data
	mov ds,ax
	
	mov ax,table
	mov es,ax
	
	mov ax,stack
	mov ss,ax
	
	
	
	mov si,0
	mov cx,21
	s:
		push cx
		
		mov cx,16
		mov bx,0
		s0:
			add bx,si
		loop s0
		
		push bx ;calc table row index
		
		mov cx,4
		mov di,0
		s1:
			add di,si ;calc 4 byte offset
		loop s1 
		
		mov ax,[di]
		mov dx,[di+2]
		mov es:[bx],ax 
		mov es:[bx+2],dx ;year
		
		mov ax,[di+84]
		mov dx,[di+86]
		mov es:[bx+5],ax 
		mov es:[bx+7],dx ;income

		mov di,si
		add di,di  ; calc 2 byte offset

		mov cx,[di+168]
		mov es:[bx+10],cx ; count
		push cx ;save count
		
		pop bx ;saved count
		div bx 
		pop bx ;saved table row index
		mov es:[bx+13],ax ;everage	

		inc si
		pop cx
		
	loop s
	

code ends

end start