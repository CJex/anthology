#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <re2/re2.h>
#include <math.h>
#include <string>
#define LOOP_TIMES 10000000
int main() {
  int dfa[3][10]={
    0,1,2,0,1,2,0,1,2,0,
    1,2,0,1,2,0,1,2,0,1,
    2,0,1,2,0,1,2,0,1,2};
  clock_t start,end;
  int i;
  const char* num="2147483646";

  i=LOOP_TIMES;
  start=clock();
  while (i--) {
    const char* str=num;
    int from=0;
    while( *str ) {
      from=dfa[from][(*str++ - '0')];
    }
    int isTriple=from==0;
  }
  printf(" DFA:%d\n",clock()-start);

  i=LOOP_TIMES;
  start=clock();
  while (i--) {
    double val = atof(num);
    int isTriple = fmod(val,(double)3)==0;
  }
  printf("atoi:%d\n",clock()-start);

  RE2::Options opt(RE2::Latin1);
  opt.set_never_capture(true);
  RE2 re("(?:[0369]|[258][0369]*[147]|"
  "(?:[147]|[258][0369]*[258])"
  "(?:[0369]|[147][0369]*[258])*"
  "(?:[258]|[147][0369]*[147]))*",opt);

  i=LOOP_TIMES;
  start=clock();
  while (i--) {
    int isTriple =RE2::FullMatch(num, re);
  }
  printf(" re2:%d\n",clock()-start);
}

