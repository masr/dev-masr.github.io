---
layout: post
title:  "jekyll+github构建简约博客(四)"
date:   2013-07-14 21:00:00
category: geek
tags: jekyll disqus
---
<p class="excerpt">
<!--excerpt-->
将disqus comment集成进jekyll博客中
<!--excerpt-->
</p>

Jekyll是一个静态的发布系统，是不带数据库的。而评论恰恰又是一个需要数据存储的功能。那该怎么办？别急，用disqus，把数据存到第三方网站就行了。disqus+jekyll真是天生一对。

怎么集成？你先去[disqus官网](http://disqus.com/)注册一下。然后主页有一个`Get this on your site`类似的按钮，然后按部就班填写信息。

![disqus](https://github.com/masr/Images/blob/master/2013-07-14/disqus1.png?raw=true)

最后disqus会给你一段html+javascript代码。类似于

{% highlight html %}
<div id="disqus_thread"></div>
    <script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'masrblog'; // required: replace example with your forum shortname
        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
    <a href="http://disqus.com" class="dsq-brlink">comments powered by <span class="logo-disqus">Disqus</span></a>
{% endhighlight %}

在_includes下面新建`disqus_comment.html`，内容就是disqus提供的html+javascript代码。

修改_layout下的post.html，修改内容如下：

{% highlight html %}
---
layout: default
type: post
---
<div id="post">
    <h2>{{"{{ page.title "}} }}</h2>
    <p class="meta">{{"{{ page.date | date_to_string "}} }}</p>
    {{"{{ content "}} }}
    {{"{% if page.tags.size > 0 "}} %}
    <h3>Tags : </h3>
    <p class="tags">
        {{"{% for tag in page.tags "}} %}
        <a href="{{"{{ site.url "}} }}/tag/{{"{{ tag "}} }}/">{{"{{ tag "}} }}</a>
        {{"{% endfor "}} %}
    </p>
    {{"{% endif "}} %}
    {{"{% include disqus_comment.html "}} %}
</div>
{% endhighlight %}

在文章的末尾会包含进`disqus_comment.html`文件。这里可能会有点疑惑的就是关于tag的部分，其实我们尚未实现关于tag页面的功能。我们在这里只是把tag展示出来，如果你点击tag链接会出错。关于tag页面，我们会在以后实现。

重新编译一下，看一篇文章试试效果。

![disqus](https://github.com/masr/Images/blob/master/2013-07-14/disqus.png?raw=true)

我们经常可以在一些博客中看到最近评论的列表，很是精致。我们其实也可以利用disqus实现这样的功能。在`_includes`下新建`sidebar_recent_comments.html`，内容如下：

{% highlight html %}
<div id="recent_comments">
    <h3>Recent Comments</h3>

    <div class="comment_list">
        <script type="text/javascript"
                src="http://masrblog.disqus.com/recent_comments_widget.js?num_items=5&hide_avatars=0&avatar_size=32&excerpt_length=200"></script>
    </div>
</div>
{% endhighlight %}

其实disqus已经提供了该组件了，我们只是将它嵌进来。`num_items`是最多显示多少个评论，`avatar_size`是头像的大小，`excerpt_length`是每条评论内容显示的最大长度。

在`_layouts/default.html`中include该页面，便可在所有的页面中都显示最近评论的组件。



