---
title: JQuery+ajax+jsonp跨域访问
date: 2017-04-17 23:02:55
tags:
---
### 实现过程
* Jsonp(JSON with Padding)是资料格式 json 的一种“使用模式”，可以让网页从别的网域获取资料。
关于Jsonp更详细的资料请参考http://baike.baidu.com/view/2131174.htm，下面给出例子：

客户端代码
```
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<script type="text/javascript" src="resource/js/jquery-1.7.2.js"></script>
</head>
<script type="text/javascript">
$(function(){
    /*
    //简写形式，效果相同
    $.getJSON("http://app.example.com/base/json.do?sid=1494&busiId=101&jsonpCallback=?",
            function(data){
                $("#showcontent").text("Result:"+data.result)
    });
    */
    $.ajax({
        type : "get",
        async:false,
        url : "http://app.example.com/base/json.do?sid=1494&busiId=101",
        dataType : "jsonp",//数据类型为jsonp
        jsonp: "jsonpCallback",//服务端用于接收callback调用的function名的参数
        success : function(data){
            $("#showcontent").text("Result:"+data.result)
        },
        error:function(){
            alert('fail');
        }
    });
});
</script>
<body>
<div id="showcontent">Result:</div>
</body>
</html>
```
服务器端代码
```
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class ExchangeJsonController {
    @RequestMapping("/base/json.do")
    public void exchangeJson(HttpServletRequest request,HttpServletResponse response) {
       try {
        response.setContentType("text/plain");
        response.setHeader("Pragma", "No-cache");
        response.setHeader("Cache-Control", "no-cache");
        response.setDateHeader("Expires", 0);
        Map<String,String> map = new HashMap<String,String>();
        map.put("result", "content");
        PrintWriter out = response.getWriter();
        JSONObject resultJSON = JSONObject.fromObject(map); //根据需要拼装json
        String jsonpCallback = request.getParameter("jsonpCallback");//客户端请求参数
        out.println(jsonpCallback+"("+resultJSON.toString(1,1)+")");//返回jsonp格式数据
        out.flush();
        out.close();
      } catch (IOException e) {
       e.printStackTrace();
      }
    }
}
```