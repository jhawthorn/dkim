require 'rake/testtask'
require 'bundler'

task :default => [:test]

desc 'Run tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

Bundler::GemHelper.install_tasks

desc 'Open an pry (or irb) session preloaded with Dkim'
task :console do
  begin
    require 'pry'
    sh 'pry -I lib -r dkim.rb'
  rescue LoadError => _
    sh 'irb -rubygems -I lib -r dkim.rb'
  end

end

task c: :console
