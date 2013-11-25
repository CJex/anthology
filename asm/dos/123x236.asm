assume cs:test1
; calculate 123*236
test1 segment
	mov ax,236
	mov cx,122
	s:add ax,236
	loop s
	mov ax,4c00h
	int 20h
test1 ends

end
    
