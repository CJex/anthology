<?php
/**
 * PHP4 JSON
 * @link http://jex.im/
 */

/**
 * JSON Encode
 * @warn Any input string must be UTF-8 encoding
 * @param {Any} $data Any type object to serialize.
 * @return {String} serialized json string.
 */
function json_stringify($data) {
  if (is_null($data)) return 'null';
  if (is_scalar($data)) return json_stringify_scalar($data);
  if (empty($data)) return '[]';
  if (is_object($data)) {
    $data=get_object_vars($data);
    if (empty($data)) return '{}';
  }
  $keys=array_keys($data);
  if ($keys===array_keys($keys)) {
    $data=array_map(__FUNCTION__,$data);
    return '['.join(',',$data).']';
  } else {//不是有序数字下标的数组即视为关联数组
    $a=array();
    foreach ($data as $k=>$v) {
      $a[]=json_stringify_scalar(strval($k)).':'.json_stringify($v);
    }
    return '{'.join(',',$a).'}';
  }
}

function json_stringify_scalar($v) {
  if (is_bool($v)) {
    $v = $v?'true':'false';
  } else if (is_string($v)) {
    $v=addcslashes($v,"\t\n\r\"\/\\");//转义特殊字符
    $v='"'.preg_replace_callback('|[^\x00-\x7F]+|','_unicode_escape',$v).'"';
  }
  return (string)$v;
}

function _unicode_escape($s) {
  //Warning:字符串必须为UTF-8编码
  $s=str_split(iconv('UTF-8','UCS-2BE',$s[0]),2);
  foreach ($s as $i=>$c) {
    $s[$i]=sprintf('\u%02x%02x',ord($c{0}),ord($c{1}));
  }
  return join('',$s);
}

/**
 * JSON decode
 * @param {String} $s The string json data.
 * @param {Boolean} [$assoc=false] Return assoc array if $assoc is true.
 * @return decode result corresponding object.
 */
function json_parse($s,$assoc=false) {
  static $strings,$count=0;
  if (is_string($s)) {
    $s=trim($s);
    $strings=array();
    //匹配字符串结束引号应该确保前面只能有偶数个'\'
    //如 "ab\"c"中 \" 不能被视为字符串结束引号
    $s=preg_replace_callback('/"([\s\S]*?(?<!\\\\)(?:\\\\\\\\)*)"/',__FUNCTION__,$s);
    //去除特殊字符后做简单的安全检测
    $clean=str_replace(array('true','false','null','{','}','[',']',',',':','#','.'),'',$s);
    if ($clean && !is_numeric($clean)) {//可能是格式不正确的JSON、恶意代码
      return NULL;
    }
    $s=str_replace(
      array('{','[',']','}',':','null'),
      //通过'(object)'类型转换将关联数组转换成stdClass instance
      array(($assoc?'':'(object)').'array(','array(',')',')','=>','NULL')
      ,$s);
    $s=preg_replace_callback('/#\d+#/',__FUNCTION__,$s);
    //抑制错误,如{3##}能通过上面的安全检测但却无法转换成正确的PHP代码
    @$data=eval("return $s;");
    $strings=$count=0;//GC
    return $data;
  } elseif (count($s)>1) {//存储字符串
    $strings[]=_unicode_unescape(str_replace(array('$','\\/'),array('\\$','/'),$s[0]));
    return '#'.($count++).'#';
  } else {//读取存储的值
    $index=substr($s[0],1,strlen($s[0])-2);
    return $strings[$index];
  }
}

function _unicode_unescape($data) {
  if (is_string($data)) {
    //匹配 Unicode escape时，需要注意匹配'\u'前面只能有偶数个'\'，如'\\u5409'不应被匹配
    return preg_replace_callback(
           '/(?<!\\\\)((?:\\\\\\\\)*)\\\\u([a-f0-9]{2})([a-f0-9]{2})/i',
           __FUNCTION__,$data);
  }
  return $data[1].iconv("UCS-2BE","UTF-8",chr(hexdec($data[2])).chr(hexdec($data[3])));
}



