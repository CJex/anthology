/**
 * Array unique,该函数会同时过滤掉null与undefined
 * @link http://jex.im/
 * @param {Array} ary 需要进行unique的数组.
 * @return {Array} 返回没有重复元素的新的数组，
 */
function unique(ary) {
  var i=0,l=ary.length,
      type,p,ret=[],
      guid=(Math.random()*1E18).toString(32)+(+new Date).toString(32),
      objects=[],
      reg={ //Primitive类型值Register
          'string': {},
          'boolean': {},
          'number': {}
      };
  for (;i<l;i++) {
    p = ary[i];
    if (p==null) continue;
    type = typeof p;
    if (reg[type]) {//Primitive类型
      if (!reg[type].hasOwnProperty(p)) {
        reg[type][p] = 1;
        ret.push(p);
      }
    } else {//Object类型
      if (p[guid]) continue;
      p[guid]=1;
      objects.push(p);
      ret.push(p);
    }
  }
  i=objects.length;
  while (i--) {//再将对象上的guid清理掉
    p=objects[i];
    delete p[guid];
  }
  return ret;
}

