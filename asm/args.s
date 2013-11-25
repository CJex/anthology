# Print command line arguments and environment variables
.section .data
  char1: .int 0 # One char store
.section .text
.global _start
_start:
  leal char1,%ecx
  movl (%esp),%eax # argc
  addl $48,%eax # add 48 to convert int to its ord
  movl %eax,(%ecx)
  movl $1,%edx
  call puts
  call newln
  # Print command line arguments
  leal 4(%esp),%edx # 4,skip argc
  pushl %edx
  call puta
  addl $4,%esp
  call newln
  # Print environment variables
  movl (%esp),%ecx
  leal 8(%esp,%ecx,4),%edx # 8,skip argc and NULL(ends argv[])
  pushl %edx
  call puta
  addl $4,%esp
  # Exit
  mov $1,%eax
  mov $0,%ebx
  int $0x80
newln:# Print line break
  pushl %ebp
  movl %esp,%ebp
  pushl %ecx
  pushl %edx

  movl $char1,%ecx
  movl $10,(%ecx) # 10,"\n"
  movl $1,%edx
  call puts

  popl %edx
  popl %ecx
  leave
  ret
# Print string.
puts:# Args:%ecx=String addr,%edx=String length
  pushl %ebp
  movl %esp,%ebp
  pushl %eax
  pushl %ebx
  movl $4,%eax # sys_write call
  movl $1,%ebx # stdout
  int $0x80
  popl %ebx
  popl %eax
  leave
  ret
# Get string length
strlen:# Args: String addr
  pushl %ebp
  movl %esp,%ebp
  pushl %edi
  pushl %ecx

  movl 8(%ebp),%edi # Get arg1
  movl $0xffffffff,%ecx
  xor %al,%al
  cld
  repne scasb
  movl $0xffffffff,%eax
  subl %ecx,%eax
  dec %eax

  popl %ecx
  popl %edi
  leave
  ret
# Print string[] with line break
puta:# Args:%edi=Start addr
  pushl %ebp
  movl %esp,%ebp
  pushl %edi
  pushl %ebx
  pushl %ecx
  pushl %eax
  pushl %edx

  movl 8(%ebp),%edi # Get arg1
  xorl %ebx,%ebx # index

  puta_loop:
  movl (%edi,%ebx,4),%ecx
  test %ecx,%ecx # NULL end
  jz puta_ret
  pushl %ecx
  call strlen
  addl $4,%esp
  movl %eax,%edx
  call puts
  call newln
  inc %ebx
  jmp puta_loop

  puta_ret:
  popl %edx
  popl %eax
  popl %ecx
  popl %ebx
  popl %edi
  leave
  ret
