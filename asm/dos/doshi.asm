;Show "Hi,world!" use dos interrupt

assume cs:code,ds:data
data segment
	db "Hi,world!","$"
data ends
code segment
	start:
	mov ax,data
	mov ds,ax ;string section addr
	mov dx,0 ;string start offset addr
	mov ah,9 ;No.9 Sub is print function
	int 21h 
	
	mov ax,4c00h
	int 21h

code ends

end start

