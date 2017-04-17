---
title: 通过nginx实现跨域请求
date: 2017-04-17 22:27:38
tags:
---

### 实现过程
* 把下面的配置保存成一个文件，例如：nginx_cors，引入到Nginx的代理配置中去。

```
if ($request_method = 'OPTIONS') {
       add_header 'Access-Control-Allow-Origin' '*';
       add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
       #
       # Custom headers and headers various browsers *should* be OK with but aren't
       #
       add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
       #
       # Tell client that this pre-flight info is valid for 20 days
       #
       add_header 'Access-Control-Max-Age' 1728000;
       add_header 'Content-Type' 'text/plain charset=UTF-8';
       add_header 'Content-Length' 0;
       return 204;
    }
    if ($request_method = 'POST') {
       add_header 'Access-Control-Allow-Origin' '*';
       add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
       add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
    }
    if ($request_method = 'GET') {
       add_header 'Access-Control-Allow-Origin' '*';
       add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
       add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
    }
```

```
location ~* ^/ {

               proxy_pass  http://www.jd.com;

               access_log   /var/log/nginx/jd-access.log main;

               include  /etc/nginx/nginx_cors;

               max_ranges 0;

           }
```
* 再通过访问Nginx这台机器上的地址，就能跨域访问www.jd.com下所有非权限控制的资源和数据了。