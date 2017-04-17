---
title: AJAX跨域访问——XMLHttpRequest代理实现
date: 2017-04-17 22:40:57
tags:
---
### 实现过程

* 跨域访问简单来说就是A网站的JavaScript代码试图访问B网站,包括提交内容和获取内容.由于安全原因,跨域访问是被各大浏览器所默认禁止的.在广域网环境中，由于浏览器的安全限制，网络连接的跨域访问时不被允许的，XmlHttpRequest也不例外。但有时候跨域访问资源是必需的。

* 我们不能在浏览器端直接使用AJAX来跨域访问资源，但是在服务器端是没有这种跨域安全限制的。所以，我们只需要让服务器端帮我们完成“跨域访问”的工作，然后在浏览器端用AJAX获取服务器端“跨域访问”的结果就可以了。这就是所谓的在服务器端创建一个 XmlHttpRequest代理，通过这个代理来访问其他域名下的资源。

* 使用XmlHttpRequest访问同一域名下的资源：直接访问：
![image](http://dl2.iteye.com/upload/attachment/0118/1805/bab2a499-19f0-3fe7-b506-c4a9f9eff5af.jpg)
* 用服务器端的XmlHttpRequest代理来跨域访问资源：
![image](http://dl2.iteye.com/upload/attachment/0118/1807/a0c63504-f1af-340e-b897-52e365fd0571.jpg)
* 前端页面代码
```
if(url.indexOf("http://")==0){
     url=url.replace("?","&");
     url="Proxy?url"+url;
}
```
* 后端代码代码
```
public class Proxy extends javax.servlet.http.HttpServlet {
    protected void doPost(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response)
            throws javax.servlet.ServletException, java.io.IOException  {
        response.setContentType("text/html;charset=GB2312");
        String url = request.getParameter("url");
        StringBuffer param = new StringBuffer();
        Enumeration enu = request.getParameterNames();
        int total = 0;
        while(enu.hasMoreElements()){
            String name = (String)enu.nextElement();
            if(!name.equals("url")){
                if(total == 0){
                    param.append(name).append("=").append(URLEncoder.encode(request.getParameter(name),"UTF-8"));
                } else{
                    param.append("&").append(name).append("=").append(URLEncoder.encode(request.getParameter(name),"UTF-8"));
                }
                total++;

            }
        }
        PrintWriter out = response.getWriter();
        if(url != null){
            URL connect = new URL(url.toString());
            URLConnection connection = connect.openConnection();
            connection.setDoOutput(true);
            OutputStreamWriter paramout = new OutputStreamWriter(connection.getOutputStream());
            paramout.write(param.toString());
            paramout.flush();
            BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream(),"GB2312"));
            String line;
            while((line = reader.readLine()) != null){
               out.println(line);
            }
            paramout.close();
            reader.close();
        }

    }

```