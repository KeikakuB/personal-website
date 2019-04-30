module CustomHelpers
    def get_article_id(article)
        path = article.source_file
        ext = article.ext
        res = path.match(/\/([^\/]+)#{ext}/)
        return res.captures[0]
    end
    def has_thumbnail(article)
      return get_thumbnail_path(article) != ""
    end
    def get_thumbnail_path(article)
# this doesn't work because request path doesn't work on the projects page
        id = get_article_id(article)
        thumbnail_path = "/images/#{article.data.blog}/#{id}"
        source_thumbnail_path = "source#{thumbnail_path}"
        glob = Dir.glob("#{source_thumbnail_path}/thumbnail.*")
        if not glob[0]
          return ""
        end
        return "#{thumbnail_path}/#{File.basename(glob[0])}"
    end

    def has_video?(article)
      return !article.data.youtube_video_id.nil?
    end

    def has_images?(article)
        id = get_article_id(article)
        images_path = "/images/#{article.data.blog}/#{id}/screenshots"
        source_images_path = "source#{images_path}"
        if Dir.exists?(source_images_path)
          Dir.foreach(source_images_path) do |file|
              if File.file?("#{source_images_path}/#{file}")
                  return true
              end
          end
        end
        return false
    end
    def get_images(article)
        res = []
        id = get_article_id(article)
        images_path = "/images/#{article.data.blog}/#{id}/screenshots"
        source_images_path = "source#{images_path}"
        if Dir.exists?(source_images_path)
          Dir.foreach(source_images_path) do |file|
              if File.file?("#{source_images_path}/#{file}")
                  name = File.basename(file, File.extname(file))
                  screenshot_path = "#{images_path}/#{file}"
                  next_data = OpenStruct.new(:name => name, :screenshot_path => screenshot_path)
                  res.push(next_data)
              end
          end
        end
        return res
    end

    def try_page_video(page)
      has_video = has_video?(page)
      res = ""
      if has_video
        res <<
%{
<div class="row justify-content-center readable">
    <div class="col-12">
      <div class="row align-items-center justify-content-center">
        <div class="embed-responsive embed-responsive-16by9">
          <iframe class="embed-responsive-item" src="https://www.youtube-nocookie.com/embed/#{page.data.youtube_video_id}?rel=0&amp;showinfo=0" frameborder="0" allowfullscreen></iframe>
        </div>
      </div>
    </div>
</div>
  }
      end
      return res
    end

    def try_page_images(page)
      has_images = has_images?(page)
      res = ""
      if has_images
        res <<
%{
<div class="row justify-content-center readable">
  <div class="col-12">
      <div id="carouselScreenshots" class="carousel slide" data-ride="carousel">
        <ol class="carousel-indicators">
}
        index = 0
        get_images(page).each do |data|
          res <<
%{
            <li data-target="#carouselScreenshots" data-slide-to="#{index}" class="#{index == 0 ? "active" : ''}"></li>
}
            index = index + 1
        end
        res <<
%{
        </ol>
        <div class="carousel-inner">
}
        index = 0
        get_images(page).each do |data|
          res <<
%{
            <div class="carousel-item#{index == 0 ? " active" : ''}">
              <img class="d-block w-100" src="#{data.screenshot_path}" alt="#{data.name}"/>
            </div>
}
          index = index + 1
        end
        res <<
%{
        </div>
        <a class="carousel-control-prev" href="#carouselScreenshots" role="button" data-slide="prev">
          <span class="carousel-control-prev-icon" aria-hidden="true"></span>
          <span class="sr-only">Previous</span>
        </a>
        <a class="carousel-control-next" href="#carouselScreenshots" role="button" data-slide="next">
          <span class="carousel-control-next-icon" aria-hidden="true"></span>
          <span class="sr-only">Next</span>
        </a>
      </div>
  </div>
</div>
}
      end
      return res
    end

    def project_album(projects, title = nil, pred = nil)
        res = ""
        if pred.nil?
          pred = lambda {|p| true}
        end
        unless title.nil?
          res <<
%{
<div class="container-fluid album-title">
}
          res << page_title(title)
          res <<
%{
</div>
}
        end
        res <<
%{
<div class="container-fluid album">
  <div class="row album-row justify-content-center">
}
          projects.select{|p| pred.call(p)}.each do |project|
            tags_subtitle =  project.tags.select{|t| link_to t, tag_path(t)}.join(" - ")
            res <<
%{
            <div class="col">
              <a href="#{project.url}">
                <div class="card mx-auto">
                  <img class="card-img-top" src="#{get_thumbnail_path(project)}" alt="#{project.title} Thumbnail"></img>
                  <div class="card-body mb-3">
                    <h5 class="card-title">#{project.title}</h5>
                    <h6 class="card-subtitle mb-2">#{tags_subtitle}</h6>
}
            unless project.data.blurb.nil?
              res <<
%{
                    <p class="card-text">#{project.data.blurb}</p>
}
            end
            res <<
%{
                  </div>
                </div>
              </a>
            </div>
}
        end
        res <<
%{
  </div>
</div>
}
        return res
    end

    def page_title(title)
      res = ""
      res <<
%{
<div class="row justify-content-center text-center page-title">
<h3>#{title}</h3>
</div>
}
      return res
    end

    def articles_table(articles, title = nil)
        res = ""
        unless title.nil?
          res << page_title(title)
        end
        res <<
%{
<table class="table mx-auto">
  <thead>
    <th scope="col" class="table-nowrap">Date</th>
    <th scope="col">Title</th>
    <th scope="col" class="d-none d-md-table-cell">Tags</th>
  </thead>
  <tbody>
}
      articles.each do |article|
        res <<
%{
    <tr>
      <td class="table-nowrap">
        <a href="#{blog_year_path(article.date.year)}">
          <div>
            #{article.date.strftime('%Y-%m-%d')}
          </div>
        </a>
      </td>
      <td>
        <a href="#{article.url}">
          <div>
          #{article.title}
          </div>
        </a>
      </td>
      <td class="d-none d-md-table-cell">#{article.tags.collect{ |t| link_to t, tag_path(t) }.join(' - ')}</td>
    </tr>
}
      end
      res <<
%{
  </tbody>
</table>
}
      return res
    end

    def page_tags(page)
      res = ""
      res <<
%{
<div class="row row-links justify-content-center">
  <div class="col text-center">
    <ul class="list-inline ul-links">
}
      res <<
%{
      <li class="list-inline-item li-links">#{link_to page.date.year, blog_year_path(page.date.year)}</li>
}
      if not page.tags.nil? and not page.tags.size == 0
        page.tags.each do |tag, articles|
          res <<
%{
      <li class="list-inline-item li-links">#{link_to tag, tag_path(tag) }</li>
}
        end
      res <<
%{
    </ul>
  </div>
</div>
}
      end
      return res
    end

    def page_links(page)
      res = ""
      if not current_page.data.links.nil? and not current_page.data.links.length == 0
        res <<
%{
<div class="row row-links justify-content-center">
  <div class="col text-center">
    <ul class="list-inline ul-links">
}
        current_page.data.links.collect{ |l| l.split(',')}.collect{ |l| link_to l[0], l[1]}.each do |l|
          res <<
%{
      <li class="list-inline-item li-links">#{l}</li>
}

        end
      res <<
%{
    </ul>
  </div>
</div>
}
      end
      return res
    end

    def get_review_categories_data()
        res = []
        articles = blog('reviews').articles
        data.review_categories.each do |c|
            name = c.name
            category = c.category
            count = articles.count{ |x| x.data['category'] == c.category };
            next_data = OpenStruct.new(:name => name, :category => category, :count => count)
            res.push(next_data)
        end
        return res
    end
end
