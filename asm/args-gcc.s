# Print command line arguments,compiled with gcc
.section .data
  argcs:
    .asciz "argc=%d\n"
  argvs:
    .asciz "argv[%d]=%s\n"
  env_header:
    .asciz "Current environment variables:\n"
  envs:
    .asciz "%s\n"
.section .text
.global main
main:
  movl %esp,%ebp
  pushl 4(%ebp) # Skip ret addr
  pushl $argcs
  call printf # Print argc
  addl $8,%esp
  # Print argv[]    
  movl $0,%eax
  movl 8(%esp),%ebp # Skip argc and ret addr
argvloop:
  movl (%ebp,%eax,4),%ecx
  jecxz argvloop_end # NULL ends argv[]
  pushl %ecx # String addr
  pushl %eax 
  pushl $argvs
  call printf
  # prinf ret value override eax,restore from stack
  movl 4(%esp),%eax 
  addl $12,%esp
  inc %eax
jmp argvloop

argvloop_end:
  movl 12(%esp),%ebp # Skip argc,ret,argv
  pushl $env_header
  call printf
  addl $4,%esp
envloop:
  movl (%ebp),%ecx 
  jecxz end # NULL ends envp[]
  pushl %ecx
  pushl $envs
  call printf
  addl $8,%esp
  addl $4,%ebp
jmp envloop

end:
  pushl $0
  call exit
    
