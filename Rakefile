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
  t.pattern = FileList['spec/**/*_spec.rb']
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

namespace :store do
  tt_pid_file = File.expand_path("../log/ttserver.pid",  __FILE__)
  mc_pid_file = File.expand_path("../log/memcached.pid", __FILE__)

  desc "Start a Tokyto Tyrant and a memcached server on port 1978"
  task :start do
    if File.file?(tt_pid_file)
      Process.kill("TERM", File.read(tt_pid_file).to_i) rescue system 'rm -f "%s"' % tt_pid_file
    end
    system 'ttserver -host 127.0.0.1 -port 1978 -pid "%s" -dmn' % tt_pid_file
    if File.file?(tt_pid_file)
      Process.kill("TERM", File.read(mc_pid_file).to_i) rescue system 'rm -f "%s"' % mc_pid_file
    end
    system 'memcached -p 11212 -l 127.0.0.1 -P "%s" -d' % mc_pid_file
  end

  desc "Stops the TT that was started with store:start"
  task :stop do
    if File.file?(tt_pid_file)
      Process.kill("TERM", File.read(tt_pid_file).to_i) rescue File.delete(tt_pid_file)
    end
    if File.file?(mc_pid_file)
      Process.kill("KILL", File.read(mc_pid_file).to_i) rescue File.delete(mc_pid_file)
    end
  end
end

