assume cs:code

code segment

start:

        mov bx,0b800h

        mov es,bx

        mov di,160*12+2*30        ;初始化显存的偏移地址，

        push di                      ;此处为第12行第30列。

        mov al,10      ;为了有规律可循，初始al的值为10(十进制)

 

rdate:  ;读取日期

        dec al                       

        cmp al,7

        jb rtime        ;当读完‘日’后，就跳至标号rtime处

        call show

        add di,6

        jmp short rdate

 

rtime:  ;读取时间

        sub al,2               

        cmp al,0feh        ;为无符号数相减

        je sign            ;当读完‘秒’后，就跳至标号sign处

        call show

        add di,6

        jmp short rtime

 

sign:   ;显示相关符号

        pop di

        add di,4                  ;定位第一个'/'符号在显存的偏移地址

        mov byte ptr es:[di],'/'

        add di,6

        mov byte ptr es:[di],'/'

        add di,12                  ;跳过日期与时间之间的空格

        mov byte ptr es:[di],':'

        add di,6

        mov byte ptr es:[di],':'


        in al,60h

cmp al,10h ;Q键的扫描码

je quit

jmp start

           ;以上4句为动态获取系统时间的关键

quit:   mov ax,4c00h

        int 21h

 

show:   push ax

        push cx

 

        out 70h,al

        in al,71h

 

        mov ah,al

        mov cl,4

        shr ah,cl

        and al,00001111b

 

        add ah,30h

        add al,30h

 

        mov byte ptr es:[di],ah

        mov byte ptr es:[di+2],al

        pop cx

        pop ax

        ret

 

code ends

end start