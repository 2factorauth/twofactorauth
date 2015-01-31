require 'html/proofer'

task :default => [:verify, :test]

task :verify do
    ruby "./verify.rb"
end

task :test do
  sh 'bundle exec jekyll build --drafts'
  HTML::Proofer.new('./_site',
    :parallel => { :in_threads => 8 },

    :followlocation => true,

    # Some certificates need this to pass
    :ssl_verifypeer => false,

    # Ignore 302 errors and 503's. Some sites use Cloudflare for DDOS
    # protection and this causes 503's.
    :only_4xx => true,

    # For when we are feeling risky
    #validate_html => true,
  ).run
end
