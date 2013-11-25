Memoization in PHP
==================


Please see：<http://jex.im/programming/memoization-in-php.html>

Required PHP5.4 or above.

##Example

```php
require_once('Memoize.php');

function my_expensive_fn() {
  sleep(10);
  return rand();
}

Memoize::call('my_expensive_fn'); # => costs 10 seconds
Memoize::call('my_expensive_fn'); # => cached,only costs 0.0000001seconds


function expensive_fn_memoized() {
  sleep(10);
  return rand();
}
Memoize::globals();
$expensive_fn(); # => same as Memoize::call('expensive_fn_memoized')

$fn=Memoize::wrap('my_expensive_fn');
$fn(); # => same as Memoize::call('my_expensive_fn')


class Test {
  use Memoizable;
  public $name='CJ';
  public static function search_memoizable($keywords) {
    static $memoizeConfig=array('expires'=>60); # =>  expires after 60 seconds
    sleep(10);
    return $keywords;
  }
  public function getName_memoizable() {
    //config custom cache key
    static $memoizeConfig=array('key'=>'%(this->name)s');
    return $this->name;
  }
}
Test::search('Hacker'); # => same as Memoize::call('Test::search_memoizable',array('Hacker'));
$t=new Test;
$t->getName(); # => same as Memoize::call(array($this,'getName_memoizable'));

```
