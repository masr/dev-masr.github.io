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
