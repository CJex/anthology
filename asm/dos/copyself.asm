assume cs:copyself
copyself segment
	mov ax,cs
	mov ds,ax
	mov ax,0020h
	mov es,ax
	mov bx,0
	mov dx,cx
	sub dx,5 ;mov ax,4c00h and int 20h length=5byte
	mov cx,dx
	
	s:mov al,[bx]
	mov es:[bx],al
	inc bx
	loop s
	
	mov ax,4c00h
	int 20h
copyself ends

end
    
