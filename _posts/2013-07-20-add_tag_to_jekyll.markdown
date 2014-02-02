---
layout: post
title:  "jekyll+github构建简约博客(六)"
date:   2013-07-20 00:00:00
category: geek
tags: jekyll jquery liquid
---
<p class="excerpt">
<!--excerpt-->
增加类似于wordpress的标签页面和标签云的功能
<!--excerpt-->
</p>

首先，我们在`_includes`下新建`sidebar_tagcloud.html`，内容为
{% highlight html %}
<script type="text/javascript" src="{{"{{ site.url "}} }}/views/js/jquery.tagcloud.js"></script>

<div id='tag_cloud'>
    <h3>Tag Could</h3>

    <div class="tags">
        {{"{% for tag in site.tags "}} %}
        <a href="{{"{{ site.url "}} }}/tag/{{"{{ tag[0] "}} }}/" title="{{"{{ tag[1].size "}} }} posts" rel="{{"{{ tag[1].size "}} }}">
            {{"{{ tag[0]"}} }}</a>
        {{"{% endfor "}} %}
    </div>
</div>
{% endhighlight %}

我们用到了一个插件叫jquery.tagcloud，下载地址是 [https://github.com/addywaddy/jquery.tagcloud.js](https://github.com/addywaddy/jquery.tagcloud.js)。

这是作为侧边栏的一块，等功能实现之后会放到主页中显示，可以在`_layouts`下的`default.html`中添加一行语句`{{"{% include sidebar_tagcloud.html "}} %}`便可将标签云的组件集成到默认的模板页面，因为`default.html`是所有页面的父页面，所以该组件会在所有的页面上显示。

现在是有了一个标签云的样子了，并且看起来蛮酷的。但是其实功能还没有完全实现。因为我们并没有指明`{{"{{ site.url "}} }}/tag/jekyll`是什么。如果你直接打开这个链接，会出错。所以我们需要写一些代码。首先在`_layouts`下新建`tag_index.html`，内容如下：

{% highlight html %}
---
layout: default
---

<div id="tag_home" class="tag {{"{{page.tag"}} }}">
    <h2>{{"{{page.tag|capitalize"}} }} posts</h2>
    <ul class="posts">
        {{"{% if site.paginate "}} %}

        {{"{% for post in paginator.posts "}} %}
        {{"{% include post_item.html "}} %}
        {{"{% endfor "}} %}
        {{"{% capture pager_url "}} %}{{"{{ site.url "}} }}/tag/{{"{{page.tag"}} }}{{"{% endcapture "}} %}
        {{"{% include pagination.html "}} %}

        {{"{% else "}} %}

        {{"{% for post in site.tags[page.tag] "}} %}
        {{"{% include post_item.html "}} %}
        {{"{% endfor "}} %}

        {{"{% endif "}} %}
    </ul>
</div>
{% endhighlight %}

这就是某标签下的文章列表页面，其实和`index.html`非常相像。如果我们不添加分页功能到`tag_index.html`下的话，代码很简单，只要加这几行就行了：

{% highlight html %}
      {{"{% for post in site.tags[page.tag] "}} %}
      {{"{% include post_item.html "}} %}
      {{"{% endfor "}} %}
{% endhighlight %}

但是如果要加入分页功能的话就略复杂了。我们需要写一些ruby代码。在`_plugins`下新建`tag_page.rb`，内容如下：

{% highlight ruby %}

module Jekyll
  class TagIndexPage < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
      self.data['tag'] = tag
      tag_title_prefix = site.config['tag_title_prefix'] || 'Tag: '
      self.data['title'] = "#{tag_title_prefix}#{tag}"
    end
  end


  class TagPages < Generator
    safe true

    def generate(site)
      site.tags.each do |tag|
        if tag_layout?(site)
          if TagPager.pagination_enabled?(site.config)
            paginate(site, tag[0])
          else
            index(site, tag[0])
          end
        end
      end
    end

    def tag_layout?(site)
      site.layouts.key? 'tag_index'
    end

    def paginate(site, tag)
      tag_posts = site.tags[tag].sort_by { |p| -p.date.to_f }

      pages = TagPager.calculate_pages(tag_posts, site.config['paginate'].to_i)

      (1..pages).each do |num_page|
        pager = TagPager.new(site, num_page, tag_posts, tag, pages)

        if num_page>1
          newpage = TagIndexPage.new(site, site.source, "tag/#{tag}/page#{num_page}", tag)
          newpage.pager = pager
          site.pages << newpage
        else
          newpage = TagIndexPage.new(site, site.source, "tag/#{tag}", tag)
          newpage.pager = pager
          site.pages << newpage
        end

      end
    end

    def index(site, tag)
      site.pages << TagIndexPage.new(site, site.source, "tag/#{tag}", tag)
    end

  end

  class TagPager < Pager
    attr_reader :tag

    def self.pagination_enabled?(config)
      !config['paginate'].nil?
    end

    def initialize(site, page, all_posts, tag, num_pages = nil)
      @tag = tag
      super site, page, all_posts, num_pages
    end

    alias_method :original_to_liquid, :to_liquid

    def to_liquid
      x = original_to_liquid
      x['tag'] = @tag
      x
    end

  end

end

{% endhighlight %}

添加了上面的代码之后，关于标签的页面就生成了。再访问 http://blog.masr.in/tag/jekyll 就不会报错了，显示的是jekyll标签下的文章列表，而且还是支持分页显示的。

下一篇文章笔者会介绍怎么把这个jekyll项目部署到github pages上的。


