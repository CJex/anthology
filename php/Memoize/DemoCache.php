<?php

/**
 * DemoCache.
 * A simple in-memory cache implements aim of running TestMemoize.
 *
 *
 * @author CJ
 *
 * You'd better read the article below.
 * @link http://jex.im/programming/memoization-in-php.html
 *
 **/

class DemoCache implements IMemoizeCache {
  const EXPIRES_30DAY=2592000;//miniutes
  private $store;
  public function __construct() {
    $this->store=array();
  }
  public function get($key) {
    $key=md5($key);
    if (!isset($this->store[$key])) {
      return false;
    }
    list($value,$expires)=unserialize($this->store[$key]);
    if (!$expires || $expires>=time()) return $value;
    return false;
  }
  public function set($key,$value,$expires=0) {
    if ($expires && $expires<self::EXPIRES_30DAY) {
      $expires+=time();
    }
    $this->store[md5($key)]=serialize(array($value,$expires));
  }
  public function flush() {
    $this->store=array();
  }
}
