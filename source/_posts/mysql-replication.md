---
title: mysql 主从环境搭建
date: 2017-08-05 00:00:00
tags: mysql replication

---



### 安装mysql
创建文件

`mkdir /data/mysql/`

使用通用二进制文件安装
`scp mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz username@hostname:/data/mysql/`
<!-- more -->

解压
`tar mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz -C /data/mysql`

复制制定目录下的全部文件到另一个目录中
`cp -r dir1/. dir2`

生成data目录
`bin/mysql_install_db --user=mysql --datadir=/data/mysql/data/`

初始化
`bin/mysqld --initialize-insecure --user=mysql --basedir=/data/mysql/ --datadir=/data/mysql/data/`
`bin/mysqld --defaults-file=/data/mysql/my.cnf --initialize-insecure --user=mysql `

修改文件所有者
`chown -R mysql .`

启动
`bin/mysqld_safe --user=mysql &`

进入
`mysql -uroot -S mysql.sock`

查看版本
`mysql> select version();
+------------+
| version()  |
+------------+
| 5.7.17-log |
+------------+
1 row in set (0.05 sec)`

</br>
</br>
### 主从配置

设置主机配置
`[mysqld]`
`log-bin=mysql-bin`
`server-id=1`

设置主机用户
`mysql> grant replication slave on *.* TO ‘repl’@‘%’ identified by ’slavepass’;`
`mysql> flush privileges;`

确定当前的二进制日志文件名和位置
`mysql> show master status\G`

设置从站配置
`[mysqld]`
`server-id=2`

启动从站
`bin/mysqld_safe --skip-slave-start &`

从站设置
`mysql> CHANGE MASTER TO `
`-> MASTER_HOST='master_host_name’, `
`-> MASTER_PORT=3306,`
`-> MASTER_USER='replication_user_name’, `
`-> MASTER_PASSWORD='replication_password’, `
`-> MASTER_LOG_FILE='recorded_log_file_name’,` 
`-> MASTER_LOG_POS=recorded_log_position;`

查看从线程状态
`mysql> show slave status\G`

开启从线程
`mysql> start slave;`

关闭从线程
`mysql> stop slave;`

重置从线程
`mysql> reset slave ;`

重置从线程并删除内存中的连接信息
`mysql> reset slave all;`

reset slave all和reset slave的区别

> RESET SLAVE does not change any replication connection parameters such
> as master host, master port, master user, or master password, which
> are retained in memory. This means that START SLAVE can be issued
> without requiring a CHANGE MASTER TO statement following RESET SLAVE.

https://dev.mysql.com/doc/refman/5.7/en/reset-slave.html

重置主线程
`mysql> reset master ;`

> Important The effects of `RESET MASTER` differ from those of `PURGE BINARY LOGS` in 2 key ways:
> 
>  1. `RESET MASTER` removes all binary log files that are listed in the index file, leaving only a single, empty binary log file with a numeric suffix of .000001, whereas the numbering is not reset by `PURGE BINARY LOGS`.
>     
>  2. `RESET MASTER` is not intended to be used while any replication slaves are running. The behavior of `RESET MASTER` when used while slaves are running is undefined (and thus unsupported), whereas `PURGE BINARY LOGS` may be safely used while replication slaves are running.

关闭mysql进程
`bin/mysqladmin -uroot -S mysql.sock shutdown`

</br>
</br>
### 多源复制

从站设置
`mysql> CHANGE MASTER TO `
`-> MASTER_HOST='master_host_name’, `
`-> MASTER_PORT=3306,`
`-> MASTER_USER='replication_user_name’, `
`-> MASTER_PASSWORD='replication_password’, `
`-> MASTER_LOG_FILE='recorded_log_file_name’,` 
`-> MASTER_LOG_POS=recorded_log_position`
`-> for channel 't1';`

查看单个channel状态
`show slave status for channel 't1'\G`

停止单个channel的同步：
`stop slave for channel 't1';`

开启单个channel的同步：
`start slave for channel 't1';`

重置单个channel：
`reset slave all for channel 't1';`

</br>
</br>
### 其他

my.cnf

    [client]
    port = 3306
    socket = /data/mysql/mysql.sock
    [mysqld]
    log_bin = mysql-bin
    basedir = /data/mysql
    datadir = /data/mysql/data
    port = 3306
    server_id = 1
    socket = /data/mysql/mysql.sock
    
    net_read_timeout = 28800
    net_write_timeout = 28800
    sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

在线开启GTID
MySQL5.6开启GTID的功能需要重启服务器生效
`mysql> set global gtid_mode=ON;`

查看user
`mysql> select user,host from mysql.user;`

查看user权限
`mysql> show grants for repl;`

</br>
</br>
### 参考

https://dev.mysql.com/doc/refman/5.7/en/binary-installation.html
https://dev.mysql.com/doc/refman/5.7/en/replication.html


  