---
title: 总结一些 git 的日常命令
date: 2016-07-21 00:00:00
tags: git cmd

---



 - 本地仓库初始化
`$ git init`
<br/>
 - clone 远程仓库
`$ git clone ssh_key`
<br/>
 - 查看当前版本状态
`$ git status`
<br/>
<!-- more -->
 - 添加 README 文件至暂存区（add 可多次）
`$ git add README`
<br/>
 - 添加 文件夹中所有文件进暂存区 ( "." 代表全部)
`$ git add .`
<br/>
 - 提交暂存区全部内容
`$ git commit -m "注释"`
<br/>
 - 查看文件a.php改变( + 表示新增行 ，- 表示删除行)
`$ git diff README`
<br/>
 - 推送你的更新到远程服务器,语法为 git push [远程名] [本地分支]:[远程分支]
`$ git push origin master`
<br/>
 - 如果不再需要某个远程分支了，比如搞定了某个特性并把它合并进了远程的 master 分支（或任何其他存放稳定代码的分支），可以用这个非常无厘头的语法来删除它。因为省略 [本地分支]，那就等于是在说“在这里提取空白然后把它变成[远程分支]”。
`$ git push [远程名] :[分支名]`
<br/>
 - 查看提交的历史记录
`$ git log`

<br/>
<br/>
**git如何删除远程仓库的某次错误提交**



&nbsp;&nbsp;&nbsp;&nbsp;reset命令的三种方式

 1. `$ git reset –mixed`
    
    默认方式，不带任何参数的git reset，就是这种方式，它回退到某个版本，只保留源码，回退commit和stage信息
 2. `$ git reset –soft`
    
    回退到某个版本， 只回退了commit的信息，不会恢复stage（如果还要提交，直接commit即可)
 3. `$ git reset –hard`
    
    彻底回退到某个版本， 本地的源码也会变为上一个版本的内容)

<br/>
**主要方法**
1) 在本地 , 把远程的 master 分支删除
2) 再把 reset 后的分支内容给 push 上去

 - 新建 old_master 分支,作为备份
`$ git branch old_master`
<br/>
 - 将本地的 old_master 分支,推送到远程的 old_master
`$ git push origin old_master:old_master`
<br/>
 - 本地仓库,彻底回退到某一个版本
`$ git reset –-hard  版本号`
<br/>
 - 删除远程的 master 分支, 删除 master 前注意：    
    1. 如果是github,必须在web上登录到github, "Change default branch"为old_master
    2. 因为default branch是master,是不能删除的。所以要先切换成old_master

 `$ git push origin :master`
<br/>
 - 重新创建远程master分支
`$ git push origin master`
<br/>


未完待续...