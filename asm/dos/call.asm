assume cs:code
;code segment
;	start:
;	mov ax,0
;	call s
;	inc ax
;	s:
;	pop ax
	
;	mov ax,4c00h
;	int 21h
;code ends

code segment
	start:
	mov ax,6
	call ax
	inc ax
	mov bp,sp
	add ax,[bp]
	
	

code ends

end start