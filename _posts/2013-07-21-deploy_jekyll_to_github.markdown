---
layout: post
title:  "jekyll+github构建简约博客(七)"
date:   2013-07-21 15:00:00
category: geek
tags: jekyll github
---

<p class="excerpt">
<!--excerpt-->
本文是关于jekyll博客的最后一章，介绍怎样部署jekyll博客到github pages上。
<!--excerpt-->
</p>

首先你得有一个github账号，然后新建一个repository，名字为`<username>.github.io`，作为存放jekyll静态页面的地方。这里的username就是你的github的用户名。笔者新建地址是[https://github.com/masr/masr.github.io](https://github.com/masr/masr.github.io)。

其中需要添加一个文件`CNAME`到jekyll博客的根目录下，里面填写博客的域名，比如`blog.masr.in`。

然后需要到域名注册商更改域名的设置。如果你想直接把一级域名映射过来，就要修改A记录为`204.232.175.78`，如果是二级域名，就需要做CNAME，指向`<username>.github.io`，笔者将`blog.masr.in`别名指向了`masr.github.io`。

接下来要做的事情就是将编译好的内容发布到新建的repo里面。我写了一个自动化的部署脚本，放置在开发环境的jekyll的根目录，取名为`deploy.sh`。

{% highlight bash %}
#!/bin/bash -e
jekyll build
rm -rf ../masr.github.io/*
cp -r _site/* ../masr.github.io/
cd ../masr.github.io/
git add -A
git commit -m"jekyll static"
git push origin master 
{% endhighlight %}

`#!/bin/bash -e`的意思是只要运行过程中出现异常情况，也就是某一个命令返回了非0值，那么整个process就退出了，
这样可以避免将错误的代码提交到github上。首先编译开发环境的代码，然后删除个ithub的repo中的所有内容，
但是像.git和.htaccess等隐藏文件会保留。然后再用_site/下编译好的页面复制到github的repo中。
然后进入github的repo，将代码提交到github上。就ok了。

现在，jekyll博客的代码工作就完成了。但是只是完成了必要的功能而已。
很多CSS代码，笔者都没有贴出来。如果你需要查看整个项目的代码。
可以访问[github代码](https://github.com/masr/dev-masr.github.io )。这个代码库就是 http://blog.masr.in 的代码。

如果不出意外的话，在浏览器中输入你的博客域名，就会显示出你的博客页面了。至此关于jekyll博客的部分就都介绍完毕了。但是其实很多关于样式的CSS代码没有贴出来。读者可以访问[here][masrblog github]。这个代码库就是 http://blog.masr.in 的代码。

