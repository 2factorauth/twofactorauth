require 'html/proofer'

task :default => [:verify, :test]

task :verify do
    ruby "./verify.rb"
end

task :test do
  sh 'bundle exec jekyll build --drafts'
  HTML::Proofer.new('./_site',
    :parallel => { :in_threads => 8 },
  ).run
end
