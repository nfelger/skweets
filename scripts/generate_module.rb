#!/usr/bin/env ruby

name = ARGV[0]
unless name
  puts "Usage: #{$0} <module>"
  exit -1
end

require 'fileutils'

module_path = File.expand_path('./modules/' + name)
FileUtils.mkdir_p(module_path)
FileUtils.mkdir_p(module_path + '/features')

File.open(module_path + '/Rakefile', 'w') do |rakefile|
  rakefile << <<EOF
require 'rubygems'
require 'rake'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:specs) do |t|
  t.rspec_opts  = ['--color', '--format', 'nested']
end

task :default => [:specs, :features]
EOF
end
