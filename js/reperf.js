var LOOP_TIMES=10000000;
var re=/^(?:[0369]|[258][0369]*[147]|(?:[147]|[258][0369]*[258])(?:[0369]|[147][0369]*[258])*(?:[258]|[147][0369]*[147]))*$/;
var s="11111111111",
    i,isTriple,start;

start=+new Date;
i=LOOP_TIMES;
while (i--) isTriple=parseInt(s)%3 === 0;
console.log("parseInt:",(+new Date)-start,isTriple);

start=+new Date;
i=LOOP_TIMES;
while (i--) isTriple=re.test(s);
console.log("  RegExp:",(+new Date)-start,isTriple);



