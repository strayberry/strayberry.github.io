---
title: 域名解析—— A 记录、CNAME 和 URL 转发区别
date: 2017-02-10 00:00:00
tags: dns blog

---

我们在做域名解析时，尤其是很多虚拟主机，大都会使用到 `CNAME` 解析，独立主机、VPS 则用 A 记录较多，而 URL 转发则会在更换域名时用到，从设置效果来看，都是“解析”到一个“其它” URL 地址，而实际上它们之间还是有些区别的，尤其是 URL 转发和其它两个之间区别很大的。
<!-- more -->

之前阿里云买的万网域名都是用 A 记录直接映射到 ECS 的 IP 地址，
万网要实名认证这点太坑，太容易被 whois 。所以这次域名过期后就买了一个 `GoDaddy` 的域名，而且用了加密邮箱 `ProtonMail` 来注册。

需要把我的 github pages 博客绑定这个新域名 [sonata.life][1] , 在设置域名解析的时候，不知道 URL 转发和 CNAME 的区别，因此遇到了一些问题：

`显示：网页无法正常使用 重定向次数过多`

查了一些 [资料][2] 解决以后，这里来总结一下域名解析。
</br>

### 名词


**域名A记录：** A `(Address)` 记录是域名与 IP 对应的记录。

CNAME记录：CNAME 也是一个常见的记录类别，它是一个域名与域名的别名`( Canonical Name )`对应的记录。当 DNS 系统在查询 CNAME 左面的名称的时候，都会转向 CNAME 右面的名称再进行查询，一直追踪到最后的 PTR 或 A 名称，成功查询后才会做出回应，否则失败。这种记录允许将多个名字映射到同一台计算机。

与 A 记录不同的是，CNAME 别名记录设置的可以是一个域名的描述而不一定是 IP 地址。通常用于同时提供 WWW 和 MAIL 服务的计算机。

**URL转发：** 如果没有一台独立的服务器（也就是没有一个独立的IP地址）或者还有一个域名 B ，想访问 A 域名时访问到 B 域名的内容，这时就可以通过 URL 转发来实现。

转发的方式有两种：隐性转发和显性转发

隐性转发的时候 www.abc.com 跳转到 www.123.com 的内容页面以后，地址栏的域名并不会改变（仍然显示 www.abc.com ）。网页上的相对链接都会显示 www.abc.com
</br>

### A记录、CNAME和URL转发的区别


它们间区别如下：

A记录 —— 映射域名到一个或多个IP。

CNAME——映射域名到另一个域名（子域名）。

URL转发——重定向一个域名到另一个 URL 地址，使用 HTTP 301状态码。


 - **A 记录和 CNAME 属于标准的 DNS 记录，而 URL 转发则实际上只是个简单的重定向。因为 CNAME 是基于 ip 的，而 URL 转发是基于网址。**
   
 - **URL 转发可以转发到某一个目录下，甚至某一个文件上。而 CNAME 是不可以，这就是 URL 转发和 CNAME 的主要区别所在。**
   
 - CNAME 可以随意设，但 URL 转发在一些缺少网络自由的国家是被禁止的，因为 URL 转发还分显示和隐式，很容易造成误解。

</br>

注意，无论是 A 记录、CNAME、URL 转发，在实际使用时是全部可以设置多条记录的。比如：

    ftp.example.com A记录到 IP1，而mail.example.com则A记录到IP2
    
    ftp.example.com CNAME到  ftp.abc.com，而mail.example.com则CNAME到mail.abc.com
    
    ftp.example.com 转发到 ftp.abc.com，而mail.example.com则A记录到mail.abc.com
</br>


### A记录、CNAME、URL适用范围



了解以上区别，在应用方面：

A记录——适应于独立主机、有固定IP地址

CNAME——适应于虚拟主机、变动IP地址主机

URL转发——适应于更换域名又不想抛弃老用户



</br>

参考资料：
http://support.dnsimple.com/articles/differences-between-a-cname-alias-url/


  [1]: https://sonata.life
  [2]: http://mushuichuan.com/2015/12/15/dnsseting/
