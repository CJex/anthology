assume cs:test1

test1 segment
    mov ax,2000h
    mov ss,ax
    mov sp,0
    add sp,10
    pop ax
    pop bx
    push ax
    push bx
    pop ax
    pop bx
    
    mov ax,4c00h
	int 21h
test1 ends

end
