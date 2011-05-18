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

