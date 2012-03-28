#!/usr/bin/env rake
begin
  require 'bundler'
  require 'bundler/setup'
  Bundler::GemHelper.install_tasks
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Masq'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

require 'rake/testtask'

namespace :test do |ns|
  desc "Prepare tests"
  task :prepare do
    Rails.env = 'test'
    Rake::Task['db:setup'].invoke
  end

  tests = %w(unit functional integration)

  tests.each do |type|
    desc "Run #{type} tests"
    Rake::TestTask.new(type) do |t|
      t.libs << 'lib'
      t.libs << 'test'
      t.test_files = FileList["test/#{type}/**/*_test.rb"]
      t.verbose = false
    end
  end

  desc "Run all tests"
  Rake::TestTask.new('all') do |t|
    files = []
    tests.each { |type| files += FileList["test/#{type}/**/*_test.rb"] }

    t.libs << 'lib'
    t.libs << 'test'
    t.test_files = files
    t.verbose = false
  end

end

Rake::Task['test'].clear
desc "Run tests"
task :test => %w[test:prepare test:all]

task :default => :test