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
	
	
	
	mov si,0 ;table row index
	mov di,0 ;year & income offset
	mov bx,0 ;employee count offset
	mov cx,21
	s:
		mov ax,[di]
		mov es:[si],ax
		mov ax,[di+2]
		mov es:[si+2],ax ;year
		
		mov ax,54h[di]
		mov es:[si+5],ax
		mov dx,56h[di]
		mov es:[si+7],dx ;income
		
		mov bp,0a8h[bx]
		mov es:[si+10],bp ;count
		
		div word ptr es:[si+10]
		mov es:[si+13],ax ;everage
		
		
		add si,16 ;table row length 16
		add di,4;year & income length 4
		add bx,2;employee count length 2
	loop s
	

code ends

end start