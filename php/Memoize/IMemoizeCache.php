<?php
interface IMemoizeCache {
  /**
   * Memcached兼容此接口
   * 设置缓存
   * @param {String} $key
   * @param {Mixed} $value
   * @param {Int} [$expires] 以秒为单位的缓存过期时长，如600表示10分钟后过期
   *                         expires的其它扩展格式Memoize并不关心，
   *                         它从函数静态配置里读取expires后直接传给set方法
   */
  public function set($key,$value,$expires);
  /**
   * 读取缓存
   * @param {String} $key
   * @return {Mixed|Bool} 当缓存不命中时返回false
   */
  public function get($key);
}
