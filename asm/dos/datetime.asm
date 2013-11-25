;Show current date and time
;Date time store in CMOS
;70h port store addr,71h port read data
;Date time data addr:
; second:0 minute:2 hour:4 date:7  month:8 year:9
;Date time data format:BCD,4 unit binary describe a digit
;1 byte,high addr=decade
assume cs:code
data segment
	db "00-00-00 00:00:00$"
	;Year only have two number
data ends

store segment
	db 16 dup(0)
store ends


code segment
	start:
	
	mov ah,03h ;No.3 sub in 10h interrupt,get cursor
	int 10h;Return bh=page num,dh=line num,dl=column number
	mov ax,store
	mov es,ax
	mov di,0
	;save bh,dh,dl
	mov es:[di],bx
	mov es:[di+2],dx
	
	
	
	refresh_datetime:
	;restore page\line\col number (bh,dh,dl)
	mov bx,es:[di]
	mov dx,es:[di+2]
	
	;reset to old page\line\column number
	mov ah,02h ;set cursor
	int 10h
	
	mov ax,data
	mov ds,ax
	
	;read year
	mov al,9
	mov ah,2 
	sub si,si
	call read_cmos_bcd
	
	;read month
	mov al,8
	mov ah,1
	inc si
	call read_cmos_bcd
	
	;read date
	mov al,7
	mov ah,1
	inc si
	call read_cmos_bcd
	
	;read hour
	mov al,4
	mov ah,1
	inc si
	call read_cmos_bcd
	
	;read munite
	mov al,2
	mov ah,1
	inc si
	call read_cmos_bcd
	
	;read second
	mov al,0
	mov ah,1
	inc si
	call read_cmos_bcd
	
	
	

	mov dx,0 ;string start addr
	mov ah,9
	int 21h
	
	;dead loop is not a resolution,it cause cpu turn to 100%
	;jmp refresh_datetime
	mov ax,4c00h
	int 21h
	
	
	read_cmos_bcd:
		;Args:
		;al => start addr
		;Return:
		;Write converted string in ds:si 
		;si point to the end of string after called
		push cx
		
		out 70h,al
		in al,71h ;read one byte
		mov ah,al
		;For convenience
		;al store byte high 4 bit
		;ah store byte low 4 bit
		;Because,human read order
		;High bit put low addr
		;Example:string "12","1" must store in low addr in memory
		
		mov cl,4
		shr al,cl ;only retain high 4 bit
		and ah,00001111b ;clear high 4 bit to 0
		
		add ah,30h
		add al,30h
		
		mov ds:[si],ax
		add si,2
		
		pop cx
		ret
code ends

end start