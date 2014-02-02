---
layout: post
title:  "jekyll+github构建简约博客(三)"
date:   2013-07-09 17:00:00
category: geek
tags: jekyll
---
<p class="excerpt">
<!--excerpt-->
本文会讲解怎样创建文章摘要功能并在首页显示出来。
<!--excerpt-->
</p>

首先，我们在_includes下面新建`post_item.html`，内容为
{% highlight html %}
<li class="post_item">
    <span class="date">{{"{{ post.date | date_to_string "}} }}</span> &raquo;
    <a class="title" href="{{"{{ site.url "}} }}{{"{{ post.url "}} }}">{{"{{post.title "}} }}</a>

    <p class="excerpt">{{"{{ post.content | extract_excerpt "}} }}</p>
</li>
{% endhighlight %}

其中`extract_excerpt`是一个我们将要实现的函数，会将文章中的摘要提取出来。

我们来创建一个含有摘要内容的文章。

{% highlight html %}
---
layout: post
title:  "Try Excerpt"
date:   2013-07-09 17:34:44
category: geek
tags: jekyll
---
<p class="excerpt">
<!--excerpt-->
本文会讲解怎样创建文章摘要功能并在首页显示出来。
<!--excerpt-->
</p>
摘要又称概要、内容提要。摘要是以提供文献内容梗概为目的，不加评论和补充解释，简明、确切地记述文献重要内容的短文。
其基本要素包括研究目的、方法、结果和结论。具体地讲就是研究工作的主要对象和范围，采用的手段和方法，得出的结果和重要的结论，有时也包括具有情报价值的其它重要的信息。
{% endhighlight %}

其中关于excerpt的那部分代码看起来蛮奇怪的，这是我们的一个约定，所有的摘要都要放在`<!--excerpt-->`中间，这样程序才能知道哪一部分是摘要。

接下来就来实现`extract_excerpt`这个方法。

新建_plugins文件夹，新建`excerpt_filter.rb`

{% highlight ruby %}
module Jekyll
    module ExcerptFilter
        def extract_excerpt(input)
            input.split('<!--excerpt-->')[1]
        end
    end
end

Liquid::Template.register_filter(Jekyll::ExcerptFilter)

{% endhighlight %}

我们注册了一个filter，jekyll在编译的时候会先读取_plugins目录下的文件，
并且注册extract_excerpt方法。之后我们在模板中用到这个filter时，
jekyll就会调用这个方法。这个函数很简单，就是将摘要提取出来。

接下来再修改index.html

{% highlight html %}
---
layout: default
title: Your New Jekyll Site
---

<div id="home">
    <h2 class="posts_index_title">Posts</h2>
    <ul class="posts">
        {{"{% if site.paginate "}} %}
        {{"{% for post in paginator.posts "}} %}
        {{"{% include post_item.html "}} %}
        {{"{% endfor "}} %}
        {{"{% assign pager_url = site.url "}} %}
        {{"{% include pagination.html "}} %}
        {{"{% else "}} %}
        {{"{% for post in site.posts "}} %}
        {{"{% include post_item.html "}} %}
        {{"{% endfor "}} %}

        {{"{% endif "}} %}
    </ul>
</div>
{% endhighlight %}

在渲染每一个文章的时候调用`post_item.html`模板。

还要修改css代码：

{% highlight css %}
li.post_item p.excerpt {
    font-size: 90%;
    margin: 0;
    padding-left: 2em;
    color: #555;
}
.post p.excerpt {
    background: #dddddd;
    font-style: italic;
    padding: 0.8em;
}
{% endhighlight %}

编译整个网站，看一下效果。
![excerpt](https://github.com/masr/Images/blob/master/2013-07-09/excerpt.png?raw=true)

![post_excerpt](https://github.com/masr/Images/blob/master/2013-07-09/post_excerpt.png?raw=true)

