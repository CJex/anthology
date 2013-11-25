# Print command line arguments and environment variables
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
.global _start
_start:
  movl %esp,%ebp
  pushl (%ebp)
  pushl $argcs
  call printf # Print argc
  addl $8,%esp
  # Print argv[]    
  movl $0,%eax
  addl $4,%ebp
argvloop:
  movl (%ebp,%eax,4),%ecx
  jecxz argvloop_end # NULL ends argv[]
  pushl %ecx # String addr
  pushl %eax 
  pushl $argvs
  call printf
  # printf ret value override eax,restore from stack
  movl 4(%esp),%eax 
  addl $12,%esp
  inc %eax
jmp argvloop

argvloop_end:
  leal 4(%ebp,%eax,4),%ebp # skip argv[] and NULL
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
    
