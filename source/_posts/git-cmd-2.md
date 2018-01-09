---
title: git 日常命令（2）
date: 2018-01-09 11:45:00
tags: git cmd

---


上回主要讲的命令是:
**本地仓库和远程仓库之间的提交和推送**
**分支的回滚/分支的删除**

那么2018年第一篇更新, 来说说多人协同工作会用到的一些命令：
**分支相关操作: 创建/切换/合并**

<!-- more -->

## git 工作流

    你的本地仓库由 git 维护的三棵“树”组成。第一个是你的 工作目录，它持有实际文件；第二个是 缓存区（Index），它像个缓存区域，临时保存你的改动；最后是 HEAD，指向你最近一次提交后的结果。

![此处输入图片的描述][1]

    事实上，第三个阶段是 commit history 的图。HEAD 一般是指向最新一次 commit 的引用。现在暂时不必究其细节。

## git branch
 - 列出仓库中所有分支
`$ git branch`
<br/>
 - 创建一个名为 < branch > 的分支（不会自动切换到那个分支去）
`$ git branch <branch>`
<br/>
 - 删除指定分支。这是一个安全的操作，Git 会阻止你删除包含未合并更改的分支
`$ git branch -d <branch>`
<br/>
 - 强制删除指定分支，即使包含未合并更改。如果希望永远删除某条开发线的所有提交，应该用这个命令。
`$ git branch -D <branch>`
<br/>
 - 将当前分支命名为 < branch >
`$ git branch -m <branch>`
<br/>
![此处输入图片的描述][2]
> 注意：
> **分支只是指向提交的指针** 
> 在 Git 中，分支是你日常开发流程中的一部分。当你想要添加一个新的功能或是修复一个 bug 时, **不管 bug 是大是小** , 你都应该新建一个分支来封装你的修改。这确保了不稳定的代码永远不会被提交到主代码库中，它同时给了你机会，在并入主分支前清理你 feature 分支的历史。( merge bug分支后删除bug分支，可避免无效提交 )


## git checkout

 - 查看特定分支，分支应该已经通过 git branch 创建。这使得 < existing-branch > 成为当前的分支，并更新工作目录的版本。
`$ git checkout <existing-branch>`
<br/>
 - 创建并查看 < new-branch >，-b 选项是一个方便的标记，告诉Git在运行 git checkout < new-branch > 之前运行 git branch < new-branch >。
`$ git checkout -b <new-branch>`
<br/>
 - 列出仓库中所有分支
`$ git branch`
<br/>

**未 commit 当前分支就 checkout 导致「分离 HEAD」的例子:**

- 当你想要开发新功能时，你创建一个专门的分支，切换过去：
`$ git branch new-feature`
`$ git checkout new-feature`
<br/>
- 接下来，你可以和以往一样提交新的快照：
`$ git add <file>`
`$ git commit -m "Started work on a new feature"`
<br/>
- 当你想要回到「主」代码库时，只要 check out 到 master 分支即可：
`$ git checkout master`
</br>
**这时有个警告会告诉你所做的更改和项目的其余历史处于「分离」的状态。**在你开始新的分支之前，告诉你仓库的状态(未提交)。你可以选择并入完成的新功能，或者在你项目稳定的版本上继续工作。


## git merge

- 将指定分支并入当前分支。Git 会决定使用哪种合并算法。
`$ git merge <branch>`
<br/> 
- 将指定分支并入当前分支，但 *总是* 生成一个合并提交（即使是 **快速向前合并**）。这可以用来记录仓库中发生的所有合并。
`$ git merge --no-ff <branch>`

1. 当当前分支顶端到目标分支路径是线性之时，我们可以采取 **快速向前合并** 。Git 只需要将当前分支 HEAD（快速向前地）移动到目标分支顶端，即可整合两个分支的历史，而不需要“真正”合并分支。
![此处输入图片的描述][3]
<br/>
2. 如果分支已经分叉了，那么就无法进行快速向前合并。当和目标分支之间的路径不是线性之时，Git 只能执行 **三路合并** 。三路合并使用一个专门的提交来合并两个分支的历史。这个术语取自这样一个事实，Git 使用 三个提交来生成合并提交：两个分支顶端和它们共同的祖先。
![此处输入图片的描述][4]
<br/>

## 解决冲突
如果你尝试合并的两个分支同一个文件的同一个部分，Git 将无法决定使用哪个版本。当这种情况发生时，它会停在**合并提交**，让你**手动解决**这些冲突。

接下来，你可以自己修复这个合并。当你准备结束合并时，你只需**对冲突的文件运行** `git add` 告诉 Git 冲突已解决。然后，运行 `git commit` 生成一个合并提交。这和提交一个普通的快照有着完全相同的流程，也就是说，开发者能够轻而易举地管理他们的合并。

**注意**，提交冲突只会出现在三路合并中。在快速向前合并中，我们不可能出现冲突的更改。
<br/>
### Examples:
**快速向前合并**

    # 开始新功能
    git checkout -b new-feature master
    
    # 编辑文件
    git add <file>
    git commit -m "开始新功能"
    
    # 编辑文件
    git add <file>
    git commit -m "完成功能"
    
    # 合并new-feature分支
    git checkout master
    git merge new-feature
    git branch -d new-feature
    

对于临时存在、用作独立开发环境而不是组织长期运行功能的工具的分支来说，这是一种常见的工作流。( 如修复bug )

**三路合并**

    # 开始新功能
    git checkout -b new-feature master
    
    # 编辑文件
    git add <file>
    git commit -m "开始新功能"
    
    # 编辑文件
    git add <file>
    git commit -m "完成功能"
    
    # 在master分支上开发
    git checkout master
    
    # 编辑文件
    git add <file>
    git commit -m "在master上添加了一些极其稳定的功能"
    
    # 合并new-feature分支
    git merge new-feature
    git branch -d new-feature

 master 在这个功能开发时取得了新进展。这是复杂功能和多个开发者同时工作时常见的情形。
 
 对大多数工作流来说，new-feature 会是一个需要一段时间来开发的复杂功能，这也是为什么同时 master 会有新的提交出现。如果你的分支上的功能像上面的一样简单，你会更想将它 rebase 到 master，使用快速向前合并。它会通过整理项目历史来避免多余的合并提交。
 
  [1]: https://raw.githubusercontent.com/strayberry/BlogPictures/master/git/image01.png
  [2]: https://raw.githubusercontent.com/strayberry/BlogPictures/master/git/image02.png
  [3]: https://raw.githubusercontent.com/strayberry/BlogPictures/master/git/image03.png
  [4]: https://raw.githubusercontent.com/strayberry/BlogPictures/master/git/image04.png
