---
layout: post
title:  "jekyll+github构建简约博客(二)"
date:   2013-07-09 10:00:00
category: geek
tags: jekyll
---
<p class="excerpt">
<!--excerpt-->
本文会讲解如何分页显示主页的文章列表。
<!--excerpt-->
</p>
上一篇文章[《jekyll+github构建简约博客(一)》](http://blog.masr.in/geek/try-jekyll.html)中介绍了如何构建一个简单的jekyll的小博客。但是这个博客的功能未免太简单了。试想，如果作者脑抽了一下子发了100篇文章，岂不是主页也要显示100个文章的列表？所以，我们先来实现一个分页的小功能。

首先打开网站根目录下的`_config.yml`，添加几行：
{% highlight yaml %}
paginate: 2 
paginate_path: "page:num"
host: 0.0.0.0
port: 4000
destination: ./_site
plugins: ./_plugins
layouts: ./_layouts
timezone: 'Asia/Shanghai'
includes: ['.htaccess']
{% endhighlight %}

`paginate`指的是一页显示多少个文章。`paginate_path`的意思是分页的url地址是怎么表示的，比如 http://localhost:4000/page4
表示首页中文章的第四页。后面的配置其实和分页没什么关系，但是也是一些很关键的配置项。`host`指的是jekyll服务器启动后可以接收哪个客户端IP的访问，
本例中服务器可以介绍任意IP的访问。如果你只想本机测试访问，可以设置host为127.0.0.1。
`port`为服务器的端口。`destination`是网站的生成目录，我们知道jekyll会把所有的内容编译成静态的html页面，
而真实的服务器读取的正是这里面的内容，我们写的模板代码在jekyll服务器启动的时候就已经编译好了，
本例中目标目录为_site。`plugins`指的是插件代码的目录，`layouts`指的是模板页面的目录，`timezone`是时区。
`includes`指的是添加文件编译到destination中，默认.htaccess是被忽略添加的，有时我们如果将代码部署到apache服务器中，
那么我们自然希望用.htaccess做一些事情了。

然后我们开始分页的html代码。在根目录下新建`_includes`文件夹，添加pagination.html，代码如下。

{% highlight html %}
{{"{% if paginator.total_pages != 1 "}} %}
<div id="pagination" class="pagination">
    <ul class="pages fix_height">
        {{"{% if paginator.page == 1 "}} %}
        <li class="current-page">
            <span>1</span>
            {{"{% else "}} %}
        <li class="page">
            <a href="{{"{{ pager_url "}} }}/">1</a>
            {{"{% endif "}} %}
        </li>
        {{"{% for count in (2..paginator.total_pages) "}} %}

        {{"{% if count == paginator.page "}} %}
        <li class="page current-page">
            <span>{{"{{ count "}} }}</span>
            {{"{% else "}} %}
        <li class="page">
            <a href="{{"{{ pager_url "}} }}/page{{"{{ count "}} }}/">{{"{{ count "}} }}</a>
            {{"{% endif "}} %}
        </li>
        {{"{% endfor "}} %}
        <li class="page last_page">
            <a href="{{"{{ pager_url "}} }}/page{{"{{ paginator.total_pages "}} }}/">Last</a>
        </li>
    </ul>
</div>
{{"{% endif  "}} %}

{% endhighlight %}

解释一下，paginator是jekyll的内嵌对象，主要根据网页的url来判断当前的页数，然后动态获取文章构造paginator对象。page为1的情况不能写在循环里的原因是，url为`http://localhost:4000/page1`是jekyll无法识别的，第一页就是`http://localhost:4000`。

然后是css代码，在css/main.css中

{% highlight css %}
#pagination {
    border-top: 1px dotted #888888;
    padding-top: 1em;
}
#pagination li {
    float: left;
    display: block;
    height: 1.3em;
    width: 1.3em;
    line-height: 1.3em;
    text-align: center;
}
#pagination li.last_page {
    width: 3em;
}
#pagination li.current-page {
    background-color: #ddd;
}
#pagination li a {
    text-decoration: underline;
}
{% endhighlight %}

css很简单，略过。最后重新编译网站，查看效果，如下。

简单的分页效果也做好了。

![pagination](https://github.com/masr/Images/blob/master/2013-07-09/pagination.png?raw=true)


