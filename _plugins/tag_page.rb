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
