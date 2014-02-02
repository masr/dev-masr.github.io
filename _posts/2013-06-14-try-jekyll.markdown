---
layout: post
title:  "jekyll+github构建简约博客(一)"
date:   2013-06-14 21:00:00
category: geek
tags: jekyll markdown
---
<p class="excerpt">
<!--excerpt-->
这是入门篇，教你怎么使用jekyll，并且撰写一篇文章。
<!--excerpt-->
</p>

我的开发环境是CentOS6.2。第一步就是安装ruby和ruby gem。不同的系统用不同的安装方法吧！这里就不赘述了。

然后就可以安装jekyll了，可以参照[jekyll](http://jekyllrb.com/)的官网。

{% highlight html %}
> gem install jekyll
> jekyll new blog
> cd blog
> jekyll serve
{% endhighlight %}

我的开发环境是ruby1.8.7，jekyll的版本是1.2.1，如果根据本系列的教程安装博客时出现异常，很有可能是版本问题造成的。请尽量同步到相同版本。

打开浏览器输入`http://localhost:4000`就可以看到jekyll默认生成的页面

主界面

![jekyll_blog](https://github.com/masr/Images/blob/master/2013-06-14/jekyll_blog.png?raw=true)

文章界面

![jekyll_post](https://github.com/masr/Images/blob/master/2013-06-14/jekyll_post.png?raw=true)

乍一看感觉还是蛮清新的，很简约。我们可以自己用markdown写一篇文章。

进入`_posts`文件夹。新建名`2013-06-14-first-blog.markdown`。当然你可以把日期换成今天。

然后编辑代码如下

{% highlight html %}
---
layout: post
title:  "jekyll+github pages构建简约博客"
date:   2013-06-14 21:20:44
category: geek
tags: jekyll
---

我来写第一个hello world吧！
{{ "{% highlight python" }} %}
print "Hello World!"
{{ "{% endhighlight" }} %}
有空可以看看我，[masr.in][masr.in]
[masr.in]: http://masr.in
{% endhighlight %}

然后在blog目录下执行命令`jekyll build`。jekyll每一次的代码改动都需要手动构建。这一点还是比较麻烦的。看一下生成的文章页面吧！

![jekyll_post_first_blog](https://github.com/masr/Images/blob/master/2013-06-14/jekyll_post_first_blog.png?raw=true)

我来详细介绍一下这一段代码的意思。

开头的一段是该文章的元信息，用yaml的格式定义。

layout指明了该文章使用post模板，post模板位于`_layout/post.html`，而post模板又是基于`_layout/default.html`的，后者是最基础的模板页面。post.html中的`{{ "{{content" }}}}`将会插入我们刚才写的文章的内容，形成整个文章页面。

title和date顾名思义，不谈，它们是必不可少的元素。category指的文章的类别，这里只能写一个。如果要写多个，可以用categories。tag是文章的标签。我们之后会用category和tag来实现类似于wordpress中的category和tag页面的功能。

