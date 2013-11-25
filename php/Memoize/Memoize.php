<?php
/**
 * Memoize
 * 将函数或方法调用按指定参数配置进行缓存
 *
 * @author CJ
 *
 * You'd better read the article below.
 * @link http://jex.im/programming/memoization-in-php.html
 *
 **/

class Memoize {
  /**
   * 使用Memoize的方法命名时的后缀
   */
  const SUFFIX='_memoized';

  /**
   * 给所有生成的缓存Key加的前缀
   */
  const KEY_PREFIX='MEMOIZE::';
  /**
   * 方法内的用于给Memoize读取配置的静态变量名称
   * 具体配置见$defaultConfig
   */
  const CONFIG_VAR_NAME='memoizeConfig';
  /**
   * 缓存后端，需要具有IMemoizeCache接口
   * @property {IMemoizeCache} $cache
   */
  public static $cache;

  public static $defaultConfig=array(
    'expires'=>600, //默认600s过期
    /**
    {String|False}
    自定义缓存Key格式，指定格式化字符串，其格式同sprintf，以函数参数作为输入
    如：
    function search($year,$author) {
      static $memoizeConfig=array('key'=>'article_%d_%s');
    }
    search(1990,'CJ');
    生成的缓存Key则为'article_1990_CJ'。
    另外支持Python Style的String format命名参数格式，
    并且如果是实例方法调用还可以通过this访问当前实例属性：
    'article_%(id)d_%(author)s'效果与前相同
    'post_%(this->id)' 可以将$this->id序列化进Key
    如果参数不是scalar，则对其应用hash配置的函数
    默认不将$this序列化进Key中
    */
    'key'=>false,
    /**
    {Callable}
    自定义对参数进行hash的方法，默认是serialize函数
    可考虑配置成其它方法，如json_encode，spl_object_hash
    */
    'hash'=>'serialize'
  );

  /**
   * 通过此设置可以运行时开启或关闭Memoize而无需修改代码
   * @property {Bool} $enable
   */
  public static $enable=true;

  /**
   * 以指定参数调用方法，
   * 如果缓存命中，则返回缓存值，
   * 如果缓存不命中，则执行方法，将结果放入缓存并返回结果
   * @param {Callable} $callee
   * @param {Array} [$args]
   * @return {Mixed}
   */
  public static function call($callee,$args=array(),$config=array()) {
    //enable配置为false,将直接调用而不使用缓存
    if (!self::$enable) return call_user_func_array($callee,$args);

    $ref=self::reflect($callee);
    $augs=self::augument($args,$ref);//将参数列表转换成字典并加入默认参数

    $vars=$ref->getStaticVariables();
    if (isset($vars[self::CONFIG_VAR_NAME])) {
      $config=$vars[self::CONFIG_VAR_NAME];
    }
    $config=array_merge(self::$defaultConfig,$config);
    $key=self::_key($ref,$callee,$augs,$config);
    $ret=self::$cache->get($key);
    if (false===$ret) {
      $ret=call_user_func_array($callee,$args);
      self::$cache->set($key,$ret,$config['expires']);
    }
    return $ret;
  }


  /**
   * 根据提供的参数及从函数读取到的静态配置，生成其对应的缓存Key
   * @param {Callable} $callee
   * @param {Array} [$args] 参数数组
   * @param {HashMap} [$config] 提供另外的配置，不使用函数静态配置
   * @return {String} 返回字符串缓存Key
   */
  public static function key($callee,$args=array(),$config=array()) {
    $ref=self::reflect($callee);
    $args=self::augument($args,$ref);
    $vars=$ref->getStaticVariables();
    if (isset($vars[self::CONFIG_VAR_NAME])) {
      $config=$vars[self::CONFIG_VAR_NAME];
    }
    $config=array_merge(self::$defaultConfig,$config);
    return self::_key($ref,$callee,$args,$config);
  }

  /**
   * @param {ReflectionFunction|ReflectionMethod} $ref
   * @param {Callable} $callee
   * @param {HashMap} $augs 已合并默认参数的并且包含原始数字下标的数组
   * @param {HashMap} $config
   */
  private static function _key($ref,$callee,$augs,$config) {
    $key=$config['key'];
    $hash=$config['hash'];
    $prefix=$ref->getNamespaceName();
    if (isset($ref->class)) {
      $prefix=$ref->class.'::'.$ref->name;
    } else {
      $prefix='Function'.'::'.$ref->name;
    }
    if (is_string($key)) {//自定义Key格式
      if (is_object($callee[0]) && !$ref->isStatic()) {//实例方法
        $augs['this']=$callee[0];
      }
      $key=self::formats($key,$augs,$hash);
    } else {
      $key=$hash($augs);
    }
    return self::KEY_PREFIX.$prefix.'::'.$key;
  }

  /**
   * Pattern支持基本的sprintf格式，如果参数不是scalar,将调用$hash方法转换
   * 另外当$args参数为关联数组时,支持Python Style的命名方式,并且支持简单的只有一级的对象属性访问表达式
   * 如：'prefix_%(this->tags)s_%(this->count)d_%(keyword)s'，this->tags为一个数组
   * 效果同：sprintf('prefix_%s_%d_%s',
   *              $hash($args['this']->tags),
   *              $args['this']->count
   *              $args['keyword'])
   * @param {String} $p 格式化的Pattern字符串
   * @param {HashMap|Array} $args 格式化参数
   * @param {Callable} [$hash] 将不是scalar的值转换成字符串的函数，默认是序列化方法
   */
  public static function formats($p,$args,$hash='serialize') {
    if (empty($args)) return $p;
    $keys=array_keys($args);
    if (strpos($p,'%(')===false) {//不包含命名格式
      $a=array($p);
      foreach ($args as $i=>$v) {
        if (!is_int($i)) continue;
        //将非标量进行序列化
        $a[]=!is_scalar($v)?$hash($v):$v;
      }
      return call_user_func_array('sprintf',$a);
    } else {//Python Style的命名参数format
      $values=array(0);
      $i=0;
      $p=preg_replace_callback('/%%|%(?:\(([^()\s]+)\))?[^%]+/',
        function ($m) use($args,$hash,&$values,&$i) {
          if ($m[0]==='%%') return '%%';
          if (isset($m[1])) {//匹配到命名参数
            $k=explode('->',$m[1]);
            $v=$args[$k[0]];
            if (count($k)===2) $v=$v->{$k[1]};
            $m[0]=str_replace("%($m[1])",'%',$m[0]);
          } else {
            $v=$args[$i++];
          }
          if (!is_scalar($v)) $v=$hash($v);
          $values[]=$v;
          return $m[0];
        },$p);
      $values[0]=$p;
      return call_user_func_array('sprintf',$values);
    }

  }

  /**
   * 将数组参数转换成字典参数，以参数名为Key，并且将函数的默认参数合并进去
   * @param {Array} $args 参数数组
   * @param {ReflectionFunction|ReflectionMethod} $ref 方法或函数的反射对象
   * @return {HashMap} 返回关联数组，保留原来传入参数的顺序的数字下标
   */
  private static function augument($args,$ref) {
    $params=$ref->getParameters();
    foreach($params as $p) {
        $pos=$p->getPosition();
        $name=$p->getName();
        if (isset($args[$pos])) {
          $args[$name]=$args[$pos];
        } elseif ($p->isDefaultValueAvailable()) {
          $args[$name]=$p->getDefaultValue();
        }
    }
    return $args;
  }
  /**
   * 创建方法的反射
   * @param {Callable} $callee
   * @return {ReflectionFunction|ReflectionMethod}
   */
  public static function reflect($callee) {
    if (is_string($callee)) {
      if (strpos($callee,'::')!==false) {//静态方法
        $ref=new ReflectionMethod($callee);
      } else {
        $ref=new ReflectionFunction($callee);
      }
    } else{
      $ref=new ReflectionMethod($callee[0],$callee[1]);
    }
    return $ref;
  }

  /**
   * 将一个函数或方法调用包装成一个缓存化的新函数
   * @param {Callable} $callee
   * @return {Closure}
   */
  public static function wrap(callable $callee) {
    return function () use($callee) {
      return self::call($callee,func_get_args());
    };
  }

  /**
   * 自动生成对应于那些具有Memoize::SUFFIX后缀的全局函数的变量函数
   * 即自动创建对应于函数：function add_memoized($a,$b) {return $a+$b;}
   * 的缓存化版本：$add
   * 调用时使用：$add(3,4);
   */
  public static function globals() {
    $l=strlen(self::SUFFIX);
    $fns=get_defined_functions();
    foreach ($fns['user'] as $f) {
      //function name ends with suffix
      if (substr_compare($f,self::SUFFIX,-$l)===0) {
        $new=substr($f,0,-$l);
        if (!isset($GLOBALS[$new])) {
          $GLOBALS[$new]=self::wrap($f);
        }
      }
    }
  }
}




trait Memoizable {
  /**
   * 在需要缓存化的类中：use Memoizable;
   * 在定义缓存化方法时，加上 Memoize::SUFFIX，即'_memoized'后缀
   * 在调用方法时不加后缀，通过下面的重载方法调用Memoize::call
   */
  public static function __callStatic($name,$args) {
    $real=$name.Memoize::SUFFIX;
    if (method_exists(__CLASS__,$real)) {
      return Memoize::call(array(__CLASS__,$real),$args);
    }
    $parent=get_parent_class(__CLASS__);
    if ($parent && method_exists($parent,'__callStatic')) {
      return parent::__callStatic($name,$args);
    }
    throw new Exception('Undefined method '.__CLASS__."::$name;");
  }
  public function __call($name,$args) {
    $real=$name.Memoize::SUFFIX;
    if (method_exists($this,$real)) {
      return Memoize::call(array($this,$real),$args);
    }
    $parent=get_parent_class(__CLASS__);
    if ($parent && method_exists($parent,'__call')) {
      return parent::__call($name,$args);
    }
    throw new Exception('Undefined method '.__CLASS__."->$name;");
  }
}

