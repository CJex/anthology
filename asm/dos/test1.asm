assume cs:code,ds:data,ss:stack

data segment
	dw 01aah,02bbh,03cch,04ddh,0577h,06afh,0788h,08dfh
data ends

stack segment
	dw 0,0,0,0,0,0,0,0
stack ends

code segment
	start:
	mov ax,stack
	mov ss,ax
	mov sp,16
	
	mov ax,data
	mov ds,ax
	
	push ds:[0]
	push ds:[2]
	pop ds:[2]
	pop ds:[0]
	
	mov ax,4c00h
	int 21h
	
code ends

end
    
