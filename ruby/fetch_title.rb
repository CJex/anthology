#!/usr/bin/env ruby
# coding:utf-8
# @author CJ
# @link http://jex.im/

require 'net/http'
require 'pp'
require 'openssl'
require 'cgi'


HTTP_PROXY={:addr=>'127.0.0.1',:port=>8087} #GoAgent Proxy local server

HTTP_RE=%r|^https?://|

HELP = <<HELP
Usage:
  Fetch the page title of url.
    $ fetch_title.rb url
  Transform html links to its page title.
    $ fetch_title.rb links.html
Example:
  fetch_title   list.html
    Input list.html contents:<a href='http://jex.im/'>http://jex.im/</a>
    Output stdout:<a href='http://jex.im/'>CJ's Blog.</a>
  fetch_title   http://jex.im/
HELP



def run(args)
  uri=args[0]
  if !uri
    puts HELP
    exit 1
  end
  if HTTP_RE =~ uri
    puts (fetch_title uri)
  else
    raise "File #{uri} not exist!" unless File.exist? uri
    content=File.read uri
    result=trans_all_title content
    puts result
  end

end


def fetch_title(url)
  res,url=request url
  title=pick_title res.body
  return title,url
end

#translate all link url to page title in html
#@example '<a href="http://jex.im/">http://jex.im/</a>' will be translated to '<a href="http://jex.im/">CJ's Blog</a>'
#@return translated html
def trans_all_title(html)
  a_re=%r|(<a\s+[^<>]*?href="?)([^"><]+)("?[^<>]*>)([^<>]*)</a>|iu
  return html.gsub(a_re) do |a,b,c,d|
    m=a_re.match(a)
    if m
      url=CGI::unescapeHTML m[2]
      next a unless HTTP_RE=~url #skip relative path url
      begin
        title,url=fetch_title url
      rescue Exception=>e
        $stderr.puts 'Request Error:'+url,e.message
        title=''
      end
      title=CGI::escapeHTML(url) if title.empty?
      next m[1]+CGI::escapeHTML(url)+m[3]+title+'</a>'
    else
      next a
    end
  end
end


def pick_title(html)
  title_re = %r|<title\b[^>]*>([^<]+)</title>|
  return title_re.match(html) && title_re.match(html)[1] || ''
end



#return [HTTPResponse,totalURL]
def request(url,opt={})
  proxy=opt[:proxy]
  redirects=opt[:_redirects] || 0
  raise Net::HTTP::HTTPError,'Too many redirects!' if redirects > 10

  uri=URI(url)
  http=Net::HTTP.new(uri.host,uri.port)
  if proxy
    http=Net::HTTP.new(uri.host,uri.port,proxy[:addr],proxy[:port])
  else
    http=Net::HTTP.new(uri.host,uri.port)
  end
  http.verify_mode=OpenSSL::SSL::VERIFY_NONE
  http.use_ssl=uri.scheme == 'https'


  if uri.path.empty?
    uri.path='/'  #URI lib is so stupid
  end

  http.open_timeout=10 #10s for open connection timeout
  res=http.get( uri.path)

  if res.is_a? Net::HTTPRedirection
    opt[:_redirects]=redirects+1
    return request res['Location'],opt
  end
  charset=res.type_params['charset']  || 'utf-8'
  res.body=res.body.encode('utf-8',charset)
  return res,url

rescue Errno::ECONNRESET #FK GFW Connection reset,this time switch to proxy
  return request url,:proxy=>HTTP_PROXY,:_redirects=>redirects
rescue Errno::ETIMEDOUT,Net::OpenTimeout #GFW Again
  if proxy
    res=Net::HTTPResponse.new 'HTTP/1.1',408,'Request Timeout'
    res.body=''
    $stderr.puts 'Request timeout:'+url
    return res,url
  else
    return request url,:proxy=>HTTP_PROXY,:_redirects=>redirects
  end

end

run(ARGV)
