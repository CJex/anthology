#!/usr/bin/env ruby
MAX_PAD = 2 ** 9
LOOP_COUNT= 2 ** 20
FETCH_BLOCK_SIZE=(`cpuid|grep "prefetching"`.match /(\d+)\s+byte/)[1].to_i
TMP_S='/tmp/align-test.s'
TMP_BIN='/tmp/align-test.bin'

def p2align(p)
  padding= (['nop'] * p).join "\n"
  code=<<ASM
.section .data
  msg: .asciz "%d\\n"
.section .text
.global main
main:
  call empty_loop
  push %eax
  push $msg
  call printf
  call exit

empty_loop:
  jmp after_pad
  #{padding}
  after_pad:
  call clock
  pushl %eax
  movl $#{LOOP_COUNT},%ecx
  loop_start:
    dec %ecx
    dec %ecx
    cmpl $0,%ecx
  jge loop_start
  call clock
  popl %ecx
  subl %ecx,%eax
  ret
ASM

  File.open TMP_S,'wb' do |f| f.write code end
  `gcc #{TMP_S} -o #{TMP_BIN}`
  i=1 # 要不要多执行几次取平均值呢？
  clocks=0
  i.times do
    c=`#{TMP_BIN}`.to_i
    clocks+=c
  end
  return clocks / i
end
DAT_FILE="align-perf-plot.dat"
dat=(0..MAX_PAD).map {|p| "#{p} #{p2align p}" }
File.open(DAT_FILE,"wb") {|f|f.write dat.join("\n")}

plot_cmd=<<CMD
set ylabel "Clocks"
set xlabel "Padding"
set xtics #{FETCH_BLOCK_SIZE}
set tics out
set xrange [0:#{MAX_PAD}]
set xtics nomirror
set ytics nomirror
set style data lines
set terminal png font "sans-serif,16" size #{[(MAX_PAD/FETCH_BLOCK_SIZE)*70,1080].max},300
set output "align-perf-plot.png"
plot "#{DAT_FILE}" title  "Time"  lw 2 lc rgb "blue"
CMD

IO.popen 'gnuplot','w' do |io| io.puts plot_cmd end
