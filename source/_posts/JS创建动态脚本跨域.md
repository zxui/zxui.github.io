---
title: JS创建动态脚本跨域
date: 2017-04-17 22:39:06
tags:
---
### 实现过程
*   script标签本身就可以访问其它域的资源，不受浏览器同源策略的限制，可以通过在页面动态创建script标签，代码如下：

```
var script = document.createElement('script');
script.src = "http://aa.xx.com/js/*.js";
document.body.appendChild(script);
```

* 这样通过动态创建script标签就可以加载其它域的js文件，然后通过本页面就可以调用加载后js文件的函数，这样做的缺陷就是不能加载其它域的文档，只能是js文件，jsonp便是通过这种方式实现的，jsonp通过向其它域传入一个callback参数，通过其他域的后台将callback参数值和json串包装成javascript函数返回，因为是通过script标签发出的请求，浏览器会将返回来的字符串按照javascript进行解析执行，实现了域与域之间的数据传输。