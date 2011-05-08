require 'rubygems'
require 'bundler'

Bundler.setup

require 'rspec'
require 'rspec/core/rake_task'

desc 'Build .gem from Gemspec'
task :build do
  system('gem build em-tycoon.gemspec')
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = "-c"
  t.pattern = FileList['spec/*_spec.rb']
end

namespace :spec do
  desc "Spawns (and then reaps) a ktserver process to run online tests against "
  RSpec::Core::RakeTask.new(:online) do |t|
    t.rspec_opts = "-c"
    t.pattern = FileList['spec/online/**/*_spec.rb']
  end
end

require 'rake/rdoctask'

desc 'Generates RDOC'
Rake::RDocTask.new do |rd|
  rd.main = 'README'
  rd.rdoc_files.include("README", "lib/**/*.rb")

  rd.options += [
    '-SHN',
    '-f', 'darkfish',  # This is the important bit
  ]
end

desc "Shells out to 'bundle install'"
task :bundle do
   system('bundle install > /dev/null')
end

