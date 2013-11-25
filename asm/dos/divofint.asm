;Divide overflow interrupt procedure install
assume cs:code
code segment
	start:
	mov ax,0
	mov es,ax
	mov di,200h ;save doi in memory 0000:0200 
	
	mov ax,cs
	mov ds,ax
	mov si,offset doi
	
	mov cx,offset doi_end - offset doi
	cld
	rep movsb
	
	mov word ptr es:[0],200h ;install it to 0 interrupt addr
	mov word ptr es:[2],0
	
	mov ax,4c00h
	int 21h
	
	
	doi:
		jmp short doi_start
		doi_msg:db "Divide Overflow!!!"
		doi_start:
			mov ax,0B800h
			mov es,ax
			mov di,12*160+36*2
			
			mov ax,cs
			mov ds,ax
			mov si,202h ; string start addr
			
			mov cx,offset doi_start - offset doi_msg ;string length
			doi_loop:
				mov ah,2
				mov al,ds:[si]
				mov es:[di],ax
				add di,2
				inc si
			loop doi_loop
			
			mov ax,4c00h
			int 21h
		
		
	
	doi_end:nop

code ends


end start