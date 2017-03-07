# Pageless Redirect Generator
#
# Generates redirect pages based on YAML or htaccess style redirects
#
# To generate redirects create _redirects.yml, _redirects.htaccess, and/or _redirects.json in the Jekyll root directory
# both follow the pattern alias, final destination.
#
# Example _redirects.yml
#
#   initial-page   : /destination-page
#   other-page     : http://example.org/destination-page
#   "another/page" : /destination-page
#
#  Result:
#   Requests to /initial-page are redirected to /destination-page
#   Requests to /other-page are redirected to http://example.org/destination-page
#   Requests to /another/page are redirected to /destination-page
#
#
# Example _redirects.htaccess
#
#   Redirect /some-page /destination-page
#   Redirect 301 /different-page /destination-page
#   Redirect cool-page http://example.org/destination-page
#
#  Result:
#   Requests to /some-page are redirected to /destination-page
#   Requests to /different-page are redirected to /destination-page
#   Requests to /cool-page are redirected to http://example.org/destination-page
#
#
# Example _redirects.json
#
#   {
#     "some-page"        : "/destination-page",
#     "yet-another-page" : "http://example.org/destination-page",
#     "ninth-page"       : "/destination-page"
#   }
#
#  Result:
#   Requests to /some-page are redirected to /destination-page
#   Requests to /yet-another-page are redirected to http://example.org/destination-page
#   Requests to /ninth-page are redirected to /destination-page
#
#
# Author: Nick Quinlan
# Site: http://nicholasquinlan.com
# Plugin Source: https://github.com/nquinlan/jekyll-pageless-redirects
# Plugin License: MIT
# Plugin Credit: This plugin borrows heavily from alias_generator (http://github.com/tsmango/jekyll_alias_generator) by Thomas Mango (http://thomasmango.com)

require 'json'

module Jekyll

  class PagelessRedirectGenerator < Generator

    def generate(site)
      @site = site

      process_yaml
      process_htaccess
      process_json
    end

    def process_yaml
      file_path = @site.source + "/_redirects.yml"
      if File.exists?(file_path)
        YAML.load_file(file_path).each do | new_url, old_url |
          generate_aliases( old_url, new_url )
        end
      end
    end

    def process_htaccess
      file_path = @site.source + "/_redirects.htaccess"
      if File.exists?(file_path)
        # Read the file line by line pushing redirects to the redirects array
        file = File.new(file_path, "r")
        while (line = file.gets)
          # Match the line against a regex, if it matches push it to the object
          /^Redirect(\s+30[1237])?\s+(.+?)\s+(.+?)$/.match(line) { | matches |
            generate_aliases( matches[3], matches[2])
          }
        end
        file.close
      end
    end

    def process_json
      file_path = @site.source + "/_redirects.json"
      if File.exists?(file_path)
        file = File.new(file_path, "r")
        content = JSON.parse(file.read)
        content.each do |new_url, old_url|
            generate_aliases(old_url, new_url)
        end
        file.close
      end
    end

    def generate_aliases(destination_path, aliases)
      alias_paths ||= Array.new
      alias_paths << aliases
      alias_paths.compact!

      alias_paths.flatten.each do |alias_path|
        alias_path = alias_path.to_s

        alias_dir  = File.extname(alias_path).empty? ? alias_path : File.dirname(alias_path)
        alias_file = File.extname(alias_path).empty? ? "index.html" : File.basename(alias_path)

        fs_path_to_dir   = File.join(@site.dest, alias_dir)
        alias_index_path = File.join(alias_dir, alias_file)

        FileUtils.mkdir_p(fs_path_to_dir)

        File.open(File.join(fs_path_to_dir, alias_file), 'w') do |file|
          file.write(alias_template(destination_path))
        end

        (alias_index_path.split('/').size + 1).times do |sections|
          @site.static_files << PagelessRedirectFile.new(@site, @site.dest, alias_index_path.split('/')[1, sections + 1].join('/'), '')
        end
      end
    end

    def alias_template(destination_path)
      <<-EOF
      <!DOCTYPE html>
      <html>
      <head>
      <title>Redirecting...</title>
      <link rel="canonical" href="#{destination_path}"/>
      <meta http-equiv="content-type" content="text/html; charset=utf-8" />
      <meta http-equiv="refresh" content="0; url=#{destination_path}" />
      </head>
      <body>
        <p><strong>Redirecting...</strong></p>
        <p><a href='#{destination_path}'>Click here if you are not redirected.</a></p>
        <script>
          document.location.href = "#{destination_path}";
        </script>
      </body>
      </html>
      EOF
    end
  end

  class PagelessRedirectFile < StaticFile
    require 'set'

    def destination(dest)
      File.join(dest, @dir)
    end

    def modified?
      return false
    end

    def write(dest)
      return true
    end
  end
end
