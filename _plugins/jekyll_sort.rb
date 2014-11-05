#https://raw.githubusercontent.com/kylepaulsen/Jekyll-Sort
module Jekyll

  class DataSorter < Jekyll::Generator
    safe true
    priority :lowest

    def initialize(config)
    end

    def generate(site)
      config = site.config

      if !config['jekyll_sort']
        return
      end

      if !config['posts']
        postData = []
        site.posts.each { |post|
          postHash = post.data
          postHash['url'] ||= post.url
          postHash['content'] ||= post.content
          postHash['date'] ||= post.date
          postHash['tags'] ||= post.data.has_key?('tags') ? post.data['tags'] : []
          postHash['sort'] ||= post.data.has_key?('sort') ? post.data['sort'] : 0
          postData.push(postHash)
        }
        config['posts'] = postData
      end

      if !config['pages']
        pageData = []
        site.site_payload["site"]["pages"].each { |page|
          pageHash = page.data
          pageHash['url'] ||= page.url
          pageHash['content'] ||= page.content
          pageHash['tags'] ||= page.data.has_key?('tags') ? page.data['tags'] : []
          pageHash['sort'] ||= page.data.has_key?('sort') ? page.data['sort'] : 0
          pageData.push(pageHash)
        }
        config['pages'] = pageData
      end

      sort_jobs = config['jekyll_sort']
      ans = []
      sort_jobs.each do |job|

        # Filter by tags if necessary, use raw src if not
        if job.has_key?('include_tags')
          data = filter_by_tag(config[job['src']], job['include_tags'])
        else
          data = config[job['src']]
        end

        # Sort the desired collection
        if job['by']
          ans = data.sort {|a,b| a[job['by']] <=> b[job['by']] } if data
        else
          ans = data.sort
        end

        case job['direction']
        when "down"
          ans.reverse!
        end

        config[job['dest']] = ans
      end
    end

    # Filter content collection by the "include_tags" attribute on the config
    #   +content_collection+ an array of hashes
    #   +tags+ an array of tags to filter by
    #
    # Returns a filtered collection by tag
    def filter_by_tag(content_collection, tags)
      filtered = []
      content_collection.each { |item|
        tags.each do |tag|
          if item["tags"].include?(tag) || item["tags"].include?(tag.capitalize)
            filtered.push(item)
            next
          end
        end
      }
      filtered
    end
  end

end
