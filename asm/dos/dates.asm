assume cs:code

code segment

start:

        mov bx,0b800h

        mov es,bx

        mov di,160*12+2*30        ;��ʼ���Դ��ƫ�Ƶ�ַ��

        push di                      ;�˴�Ϊ��12�е�30�С�

        mov al,10      ;Ϊ���й��ɿ�ѭ����ʼal��ֵΪ10(ʮ����)

 

rdate:  ;��ȡ����

        dec al                       

        cmp al,7

        jb rtime        ;�����ꡮ�ա��󣬾��������rtime��

        call show

        add di,6

        jmp short rdate

 

rtime:  ;��ȡʱ��

        sub al,2               

        cmp al,0feh        ;Ϊ�޷��������

        je sign            ;�����ꡮ�롯�󣬾��������sign��

        call show

        add di,6

        jmp short rtime

 

sign:   ;��ʾ��ط���

        pop di

        add di,4                  ;��λ��һ��'/'�������Դ��ƫ�Ƶ�ַ

        mov byte ptr es:[di],'/'

        add di,6

        mov byte ptr es:[di],'/'

        add di,12                  ;����������ʱ��֮��Ŀո�

        mov byte ptr es:[di],':'

        add di,6

        mov byte ptr es:[di],':'


        in al,60h

cmp al,10h ;Q����ɨ����

je quit

jmp start

           ;����4��Ϊ��̬��ȡϵͳʱ��Ĺؼ�

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