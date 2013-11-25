<?php

/**
 * TestMemoize
 *
 *
 * @author CJ
 *
 * You'd better read the article below.
 * @link http://jex.im/programming/memoization-in-php.html
 *
 **/

require_once('PHPUnit/Autoload.php');
require_once('Memoize.php');
require_once('IMemoizeCache.php');
require_once('DemoCache.php');

Memoize::$cache=new DemoCache;

class TestMemoize extends PHPUnit_Framework_TestCase {
  public function test_key() {
    $obj=new Demo;
    $args=array(3);
    $expect="MEMOIZE::Demo::test_memoized::result_PHP_3";
    $this->assertEquals($expect,Memoize::key(array($obj,'test_memoized'),$args));

    $args=array('PHP','jex.im');
    $expect="MEMOIZE::Demo::search_memoized::result_PHP_jex.im";
    $this->assertEquals($expect,Memoize::key('Demo::search_memoized',$args));

    $key='result_%(site)s_%s_%(keyword)4s_%s';
    Demo::search_memoized('','',$key);//change key
    $expect="MEMOIZE::Demo::search_memoized::result_jex.im_PHP_ PHP_jex.im";
    $this->assertEquals($expect,Memoize::key('Demo::search_memoized',$args));
  }
  public function test_static_call() {
    $a='PHP';
    $b='jex.im';
    $this->assertEquals(Demo::search($a,$b),Demo::search($a,$b));
    $this->assertNotEquals(Demo::search($a,$b),Demo::search($b,$a));

    //test expires
    $v=Demo::search($a,$b);
    sleep(3);
    $this->assertNotEquals($v,Demo::search($a,$b));

    $this->assertEquals('not_exist',Demo::not_exist());
  }
  public function test_instance_call() {
    $obj=new Demo;
    $obj->prop='PHP';
    $a='Arg';
    $this->assertEquals($obj->test($a),$obj->test($a));
    $v=$obj->test($a);
    $obj->prop='Changed';
    $this->assertNotEquals($v,$obj->test($a));
    $this->assertEquals($obj->test($a),$obj->test($a));

    $this->assertEquals('not_exist',$obj->not_exist());
  }
  public function test_formats() {
    $s='Not any more';
    $this->assertEquals($s,Memoize::formats($s,array()));

    $s='Just sprintf:%s,%d,%.2f';
    $a=array('A',10,10.00003);
    $this->assertEquals(sprintf($s,$a[0],$a[1],$a[2]),Memoize::formats($s,$a));

    $s='With serialize:%d,%s';
    $b=array('k1'=>1,'k2'=>2);
    $a=array(3,$b);
    $this->assertEquals(
      sprintf($s,$a[0],serialize($a[1])),
      Memoize::formats($s,$a));

    $s='With named:%(id)04d,%(name)s';
    $s2='With named:%04d,%s';
    $a=array('id'=>33,'name'=>555);
    $this->assertEquals(
      sprintf($s2,$a['id'],$a['name']),
      Memoize::formats($s,$a));

    $s='With property:%(this->id)04d,%(this->name)s,%(this->self)s';
    $s2='With property:%04d,%s,%s';
    $o=(object)array('id'=>33,'name'=>555);
    $o->self=$o;
    $a=array('this'=>$o);
    $this->assertEquals(
      sprintf($s2,$a['this']->id,$a['this']->name,serialize($o)),
      Memoize::formats($s,$a));

    $s='Mix named and nubmer:%(this->id)04d,%s,%d,%(name)s,%(this->name)s,%(this)s';
    $s2='Mix named and nubmer:%04d,%s,%d,%s,%s,%s';
    $o=(object)array(
      'id'=>13,
      'name'=>'this'
    );
    $a=array('this'=>$o,'name'=>'AAA','xxx',999);
    $this->assertEquals(
      sprintf($s2,$a['this']->id,$a[0],$a[1],$a['name'],$a['this']->name,serialize($o)),
      Memoize::formats($s,$a));


  }
  public function test_demo_cache() {
    $cache=new DemoCache;
    $key='key';
    $value=(object)array('name'=>'CJ','age'=>18);
    $cache->set($key,$value);
    $this->assertEquals($value,$cache->get($key));
    $this->assertEquals(false,$cache->get('not key'));
    $cache->set($key,$value,2);
    sleep(1);
    $this->assertEquals($value,$cache->get($key));
    sleep(3);
    $this->assertEquals(false,$cache->get($key));

    $cache->set($key,$value,time()+2);
    sleep(1);
    $this->assertEquals($value,$cache->get($key));
    sleep(3);
    $this->assertEquals(false,$cache->get($key));
  }

  public function test_globals() {
    global $test1,$test2;
    Memoize::globals();
    $ks=array('Haskell','Hacker','Human');

    foreach ($ks as $k) {
      $this->assertEquals($test1($k),$test1($k));
      $this->assertEquals($test1($k),$test1($k));
      $this->assertEquals($test2($k),$test2($k));
      $this->assertNotEquals($test1($k),$test2($k));
      $this->assertNotEquals(test3($k),test3($k));
    }

    Memoize::$defaultConfig['expires']=1;

    $k='new fresh';
    $v=$test1($k);
    $this->assertEquals($v,$test1($k),$test1($k));
    sleep(2);
    $this->assertNotEquals($test1($k),$v);
    $this->assertEquals($test1($k),$test1($k));

    Memoize::$defaultConfig['expires']=600;
  }


}

class Base {
  public static function __callStatic($name,$args) {
    return $name;
  }
  public function __call($name,$args) {
    return $name;
  }
}

class Demo extends Base {
  use Memoizable;
  public $prop='PHP';
  public static function search_memoized($keyword,$site,$key=NULL) {
    static $memoizeConfig=array(
      'expires'=>2,
      'key'=>'result_%s_%s'
    );
    if (!empty($key)) {
      $memoizeConfig['key']=$key;
    }
    return $keyword.$site.rand();
  }
  public function test_memoized($a) {
    static $memoizeConfig=array(
      'expires'=>2,
      'key'=>'result_%(this->prop)s_%s'
    );
    return rand();
  }
}

function test1_memoized($keyword) {
  return $keyword.rand();
}

function test2_memoized($keyword) {
  return $keyword.rand();
}

function test3($keyword) {
  return $keyword.rand();
}





