assume cs:reverse
reverse segment
	dw 01aah,02bbh,03cch,04ddh,05eeh,06ffh,07abh,08dch
	dw 0,0,0,0,0,0,0,0
	
	_start:
	mov ax,cs
	mov ss,ax
	mov sp,20h
	
	mov bx,0
	mov cx,8
	s:
	push cs:[bx]
	add bx,2
	loop s
	
	mov bx,0
	mov cx,8
	s0:
	pop cs:[bx]
	add bx,2
	loop s0
	
	mov ax,4c00h
	int 21h
	
reverse ends

end _start
    
