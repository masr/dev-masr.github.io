---
layout: post
title:  "jekyll+github构建简约博客(五)"
date:   2013-07-20 00:00:00
category: geek
tags: jekyll liquid
---
<p class="excerpt">
<!--excerpt-->
增加类似于wordpress的文章类别页面的功能
<!--excerpt-->
</p>

wordpress系统会有类别和标签的概念，同样的用户可以查看某一类别或是标签下的文章。我们也来动手实践一下。

首先，我们在`_includes`下新建`sidebar_categories.html`，内容为
{% highlight html %}
<div id="category_entries">
    <h3>Categories</h3>
    <ul class="fix_height">
        <li><a href="{{"{{ site.url "}} }}/geek/" title="view all posts">Geek</a>
        </li>
        <li><a href="{{"{{ site.url "}} }}/music/" title="view all posts">Music</a>
        </li>
        <li><a href="{{"{{ site.url "}} }}/poem/" title="view all posts">Poem</a>
        </li>
        <li><a href="{{"{{ site.url "}} }}/life/" title="view all posts">Life</a>
        </li>
        <li><a href="{{"{{ site.url "}} }}/messages.html">Messages</a></li>
        <li><a href="{{"{{ site.url "}} }}/about.html">About</a></li>
    </ul>
</div>
{% endhighlight %}

这是作为侧边栏的一块，等功能实现之后会放到主页中显示，可以在`_layouts`下的`default.html`中添加一行语句`{{"{% include sidebar_categories.html "}} %}`便可将分类目录集成到默认的模板页面。

现在是有了一个分类目录的样子了，但是其实功能还没有实现。因为我们并没有指明`{{"{{ site.url "}} }}/life`是什么。如果你直接打开这个链接，会出错。所以我们需要写一些代码。首先在`_layouts`下新建`category_index.html`，内容如下：

{% highlight html %}
---
layout: default
---

<div id="category_home" class="category {{"{{page.category"}} }}">
    <h2>{{"{{page.category|capitalize"}} }} posts</h2>
    <ul class="posts">
        {{"{% if site.paginate "}} %}

        {{"{% for post in paginator.posts "}} %}
        {{"{% include post_item.html "}} %}
        {{"{% endfor "}} %}
        {{"{% capture pager_url "}} %}{{"{{ site.url "}} }}/{{"{{ page.category "}} }}{{"{% endcapture "}} %}
        {{"{% include pagination.html "}} %}

        {{"{% else "}} %}

        {{"{% for post in site.categories[page.category] "}} %}
        {{"{% include post_item.html "}} %}
        {{"{% endfor "}} %}

        {{"{% endif "}} %}
    </ul>
</div>
{% endhighlight %}

这就是某类别下的文章列表页面，其实和`index.html`非常相像。如果我们不添加分页功能到`category_index.html`下的话，代码很简单，只要加这几行就行了：

{% highlight html %}
     {{"{% for post in site.categories[page.category] "}} %}
     {{"{% include post_item.html "}} %}
     {{"{% endfor "}} %}
{% endhighlight %}

但是如果要加入分页功能的话就略复杂了。我们需要写一些ruby代码。在`_plugins`下新建`category_page.rb`，内容如下：

{% highlight ruby %}

module Jekyll
  class CategoryIndexPage < Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
      self.data['category'] = category
      category_title_prefix = site.config['category_title_prefix'] || 'Category: '
      self.data['title'] = "#{category_title_prefix}#{category}"
    end
  end


  class CategoryPages < Generator
    safe true

    def generate(site)
      site.categories.keys.each do |category|
        if category_layout?(site)
          if CategoryPager.pagination_enabled?(site.config)
            paginate(site, category)
          else
            index(site, category)
          end
        end
      end
    end

    def category_layout?(site)
      site.layouts.key? 'category_index'
    end

    def paginate(site, category)
      category_posts = site.categories[category].sort_by { |p| -p.date.to_f }

      pages = CategoryPager.calculate_pages(category_posts, site.config['paginate'].to_i)

      (1..pages).each do |num_page|
        pager = CategoryPager.new(site, num_page, category_posts, category, pages)

        if num_page>1
          newpage = CategoryIndexPage.new(site, site.source, "#{category}/page#{num_page}", category)
          newpage.pager = pager
          site.pages << newpage
        else
          newpage = CategoryIndexPage.new(site, site.source, category, category)
          newpage.pager = pager
          site.pages << newpage
        end

      end
    end

    def index(site, category)
      site.pages << CategoryIndexPage.new(site, site.source, category, category)
    end

  end

  class CategoryPager < Pager
    attr_reader :category

    def self.pagination_enabled?(config)
      !config['paginate'].nil?
    end

    def initialize(config, page, all_posts, category, num_pages = nil)
      @category = category
      super config, page, all_posts, num_pages
    end

    alias_method :original_to_liquid, :to_liquid

    def to_liquid
      x = original_to_liquid
      x['category'] = @category
      x
    end

  end

end

{% endhighlight %}

这一段代码比较晦涩难懂。其实以上的代码实现的功能只是生成一些页面而已，比如/life文件夹，/geek文件夹，包括/geek/index.html，/geek/page2/index.html之类的。类似于下图：

![category_site_generator](https://github.com/masr/Images/blob/master/2013-07-20/category_site_generator.png?raw=true)

图中所有的文件都是jekyll自动编译生成的，其所在的路径就对应着url的路径，比如访问 http://blog.masr.in/geek 的时候，其实访问的是`/geek/index.html`目录，比如 http://blog.masr.in/geek/page2 访问的就是`/geek/page2/index.html`。 上面的代码看不懂也没有关系，只要能正常工作就OK了。

重新编译一下，看看效果吧！


