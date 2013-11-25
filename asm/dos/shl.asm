;Use shl calculate ax=ax*10;(PS:ax*10=ax*2+ax*8)
;shl ax,1 => ax=ax*(2^1)
;shr ax,1 => ax=ax/(2^1)
assume cs:code

code segment
	start:
	mov ax,8
	shl ax,1
	mov bx,ax
	mov ax,8
	mov cl,3
	shl ax,cl
	add ax,bx
	
	mov ax,4c00h
	int 21h
	

code ends

end start