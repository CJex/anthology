assume cs:twotwo
; calculate 2^12
twotwo segment

    mov [bx],ax
    mov ax,2
    mov cx,11
    s:add ax,ax ; run 1 times
    loop s   ; run s 10 times again + first 1 times = 11 times
    mov ax,4c00h
    int 20h
twotwo ends

end
    
