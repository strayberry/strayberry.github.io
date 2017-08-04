---
title: 搭建 lnmp 遇到的各种 bug
date: 2016-07-28 00:00:00
tags: nginx php

---



由于一年前挖下的一个坑需要快速完成一个php的项目，于是在闲置了很久的阿里云服务器上装了 `lnmp` 的集成环境，选用了传言非常优雅的 `lumen` 框架，踏入了这个坑。
而在这个在 `lnmp` 上调试 `lumen` 的时候，遇到了各种各样的 **bug** ，下面挑几个讲一下，希望能帮到一些踩了同样坑的人 。
<!-- more -->

**1. php弹出下载、不解析的问题**


根据[官方教程][1]的安装步骤安装好了 `lnmp` ，显示如下

    +-------------------------------------------+
    |    Manager for LNMP, Written by Licess    |
    +-------------------------------------------+
    |              http://lnmp.org              |
    +-------------------------------------------+
这时域名虽然解析到了服务器上，但是还没配置虚拟主机显然是404错误的。
所以需要去修改 `Nginx` 的配置文件 `nginx.conf` 来配置虚拟主机

作为一个面向google编程的人，google以后，看到了这个教程

> nginx的配置、虚拟主机、负载均衡和反向代理[（1）][2],[（2）][3],[（3）][4]。

相当详细地介绍了 `nginx.conf` 配置文件各个部分的含义

照着这个改了一下地方
 `nginx -t` **检查语法错误**
 `nginx -s reload` **重启nginx**

这一改出现了一个严重的bug，
输入 url 以后入口文件 index.php 直接弹出下载，没有解析

[**解决：**][5]

> 自己修改过下面2处的配置，导致nginx配置文件里的设置和php-fpm上的设置不一样。如果使用unix套接字，修改
> /usr/local/php/etc/php-fpm.cnf 里设置， php 5.2为 /tmp/php-cgi.sock php
> 5.3及以上版本为 listen = /tmp/php-cgi.sock ，
> 
> 同时  /usr/local/nginx/conf/nginx.conf 及其 /usr/local/nginx/conf/vhost/ 
> 下面的虚拟主机配置里的 fastcgi_pass unix:/tmp/php-cgi.sock;  不一致就必定502。
> 
> 有时候unix套接字模式下可能会502， 可以尝试改成tcp/ip的方式  php 5.2下 /tmp/php-cgi.sock 替换为
> 127.0.0.1:9000 php 5.3及以上版本 listen = /tmp/php-cgi.sock 替换为 listen = 127.0.0.1:9000， nginx配置文件及虚拟主机配置文件里 fastcgi_pass unix:/tmp/php-cgi.sock; 替换为 fastcgi_pass 127.0.0.1:9000; 
> 
> 之后重启试试。
> 
> 还需要补充的就是不要按网上找到的教程随便修改配置，网上找到的可能会路径不一样，也可能会导致502或有相关的错误产生。

于是用回了默认的nginx.conf文件

    user  www www;
    
    worker_processes auto;
    
    error_log  /home/wwwlogs/nginx_error.log  crit;
    
    pid        /usr/local/nginx/logs/nginx.pid;
    
    #Specifies the value for maximum file descriptors that can be opened by this process.
    worker_rlimit_nofile 51200;
    
    events
        {
            use epoll;
            worker_connections 51200;
            multi_accept on;
        }
    
    http
        {
            include       mime.types;
            default_type  application/octet-stream;
    
            server_names_hash_bucket_size 128;
            client_header_buffer_size 32k;
            large_client_header_buffers 4 32k;
            client_max_body_size 50m;
    
            sendfile   on;
            tcp_nopush on;
    
            keepalive_timeout 60;
    
            tcp_nodelay on;
    
            fastcgi_connect_timeout 300;
            fastcgi_send_timeout 300;
            fastcgi_read_timeout 300;
            fastcgi_buffer_size 64k;
            fastcgi_buffers 4 64k;
            fastcgi_busy_buffers_size 128k;
            fastcgi_temp_file_write_size 256k;
    
            gzip on;
            gzip_min_length  1k;
            gzip_buffers     4 16k;
            gzip_http_version 1.1;
            gzip_comp_level 2;
            gzip_types     text/plain application/javascript application/x-javascript text/javascript text/css application/xml application/xml+rss;
            gzip_vary on;
            gzip_proxied   expired no-cache no-store private auth;
            gzip_disable   "MSIE [1-6]\.";
    
            #limit_conn_zone $binary_remote_addr zone=perip:10m;
            ##If enable limit_conn_zone,add "limit_conn perip 10;" to server section.
    
            server_tokens off;
            
            #log format
            log_format  access  
            '$remote_addr - $remote_user [$time_local] "$request" '
            '$status $body_bytes_sent "$http_referer" '
        '"$http_user_agent" $http_x_forwarded_for';
    		access_log off;
    
    server
        {
            listen 80 default_server;
            #listen [::]:80 default_server ipv6only=on;
            server_name www.lnmp.org;
            index index.html index.htm index.php;
            root  /home/wwwroot/default;
    
            #error_page   404   /404.html;
            include enable-php.conf;
    
            location /nginx_status
            {
                stub_status on;
                access_log   off;
            }
    
            location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
            {
                expires      30d;
            }
    
            location ~ .*\.(js|css)?$
            {
                expires      12h;
            }
    
            location ~ /\.
            {
                deny all;
            }
    
            access_log  /home/wwwlogs/access.log  access;
        }
    include vhost/*.conf;
    }

修改了 server 和 include 

    	server {
    			listen  80;
    			server_name  127.0.0.1;
    			location / {
    				root   /home/wwwroot/default;
    				index  index.html index.htm;
    		}
    		
    	}
    
    include /usr/local/nginx/conf/vhost/*;

lnmp配置vhost时生成的 servername.conf

    server
        {
            listen 80;
            #listen [::]:80;
            
            #server-name为自定义
            server_name server-name;
            index index.html index.htm index.php default.html default.htm default.php;
           
            #server-name,project-name为自定义
            root  /home/wwwroot/server-name/project-name/public;
    
            include 子域名.conf;
            #error_page   404   /404.html;
            location ~ [^/]\.php(/|$)
            {
                # comment try_files $uri =404; to enable pathinfo
                try_files $uri =404;
                fastcgi_pass  unix:/tmp/php-cgi.sock;
                fastcgi_index index.php;
                include fastcgi.conf;
                #include pathinfo.conf;
            }
    
            location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
            {
                expires      30d;
            }
    
            location ~ .*\.(js|css)?$
            {
                expires      12h;
            }
            
            #server-name为自定义
            access_log  /home/wwwlogs/server-name.log access;
        }




**2. error_log，LNMP下如何开启PHP错误日志**
解析 php 文件的问题解决了，出现了的却不是欢迎页面而是 **http error 500** 
而且 lnmp 下的错误需要在 `/usr/local/php/etc/php-fpm.conf` 里设置，错误信息才会记录到 `php-fpm.conf` 里 `error_log` 设置的文件里

[**解决**][6]

> LNMP下的错误需要在/usr/local/php/etc/php-fpm.conf里设置，
> 
> 加上catch_workers_output = yes，
> 
> 错误信息就会记录到php-fpm.conf里error_log设置的文件里。
> 
> 或php-fpm.conf里加上
> 
> php_admin_value[error_log] = /usr/local/php/var/log/php-error.log
> 
> php_admin_flag[log_errors] = on
> 
> 上述两种方法都行，重启php-fpm生效
> 
> 同理php.ini里的display_errors也是需要在php-fpm.conf里设置的，
> 
> 加上php_flag[display_errors] = On就开启了。
> 
> 有时可能错误日志文件不自动创建，
> 
> 可以执行：touch /usr/local/php/var/log/php-error.log && chown www:www
> /usr/local/php/var/log/php-error.log


**3. open_basedir**
成功在 `error_log` 里面记录下产生 `http error 500` 的 php日志 后，
下面来分析日志来解决产生 `http error 500` 的原因

    [28-Jul-2016 14:45:12] WARNING: [pool www] child 6795 said into stderr: "NOTICE: PHP message: PHP Warning:  require(): open_basedir restriction in effect. File(/home/wwwroot/server-name/project-name/bootstrap/app.php) is not within the allowed path(s): (/home/wwwroot/server-name/project-name/public:/tmp/:/proc/) in /home/wwwroot/server-name/project-name/public/index.php on line 14"
    [28-Jul-2016 14:45:12] WARNING: [pool www] child 6795 said into stderr: "NOTICE: PHP message: PHP Warning:  require(/home/wwwroot/server-name/project-name/bootstrap/app.php): failed to open stream: Operation not permitted in /home/wwwroot/server-name/project-name/public/index.php on line 14"
    [28-Jul-2016 14:45:12] WARNING: [pool www] child 6795 said into stderr: "NOTICE: PHP message: PHP Fatal error:  require(): Failed opening required '/home/wwwroot/server-name/project-name/public/../bootstrap/app.php' (include_path='.:/usr/local/php/lib/php') in /home/wwwroot/server-name/project-name/public/index.php on line 14"

这个报错的意思就是说open_basedir受到了限制

[**解决**][7]

`php.ini` 中的 `open_basedir` 参数，
设置这个参数即可限定php脚本的访问范围。
我们针对每个站点，需要php能够访问该站点所在目录以及`/tmp/`临时目录。

> open_basedir=.:/tmp/   冒号的作用是隔开多个路径，这里面根据字面理解，第一个点就代表当前目录。
> 
> 看起来是很完美了，OK，保存配置，重启php-fpm
> 
> 结果nginx 报502错误。
> 
> 研究了一会，发现 . 这种相对路径写法，至少在nginx+phpfastcgi下是行不通的。
> 
> 好吧，暂时妥协
> 
> open_basedir=/home/wwwroot/:/tmp/
> 
> 这样总行了，将php限制在所有站点的父目录，这样至少阻止了php访问服务器上web目录以外的目录。
> 
> 到了这里，还是有隐患的，只要wwwroot下任意一个站点被拿到webshell，那么其他站点将不能幸免.
> 
> 不甘心哪，度娘是找不到有用的信息了，都是些垃圾复制粘贴，于是去了谷歌。
> 
> 搜了一下，找到一个遇到同样问题的鬼佬，里面有人给了一个方法，成功解决。
> 
> 那就是在nginx 每个server下，加上
> 
> fastcgi_param  PHP_VALUE  "open_basedir=$document_root:/tmp/"; 
> 
> 重启nginx，成功！你也可以把这行代码放到fastcgi.conf里，前提是你得在server{}中包含它。
> 
> 至此，nginx + php5.3 是没有问题了。
> 
> 然后我又在另外一台vps上，环境是php5.2 发现此方法不生效。

`php -v` **查看php版本**

    PHP 5.5.25 (cli) (built: Mar  9 2016 20:26:17) Copyright (c) 1997-2015 The PHP Group Zend Engine v2.5.0, Copyright (c) 1998-2015 Zend Technologies
        with Zend Guard Loader v3.3, Copyright (c) 1998-2014, by Zend Technologies
        with Zend OPcache v7.0.4-dev, Copyright (c) 1999-2015, by Zend Technologies

php版本是5.5,但是试了最后这个办法也不支持。
由于现在服务器上只有一个站点，所以暂时先用 `open_basedir=/home/wwwroot/:/tmp/` 凑合着，
看看之后能不能解决这个问题。

`lnmp restart` **重启lnmp**

    NOTICE: Finishing ...
    NOTICE: exiting, bye-bye!
    NOTICE: fpm is running, pid 12097
    NOTICE: ready to handle connections

刷新，最后终于出现了期待已久的lumen欢迎页面~~



**最后：**

到这里为止，环境算是搭建好了。
lnmp环境是web应用很常见的环境，现在算是对它的目录结构有了一个基本的认识。

还有Nginx的负载均衡和反向代理和HTTP缓存，也是非常值得深入去学习的。

  [1]: http://lnmp.org/install.html
  [2]: https://www.zybuluo.com/phper/note/89391
  [3]: https://www.zybuluo.com/phper/note/90310
  [4]: https://www.zybuluo.com/phper/note/133244
  [5]: http://lnmp.org/faq/lnmp-Nginx-502-Bad-Gateway.html
  [6]: http://lnmp.org/faq.html
  [7]: http://www.oschina.net/question/878142_106780