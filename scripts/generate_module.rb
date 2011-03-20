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
  if File.exists?('features')
    require 'cucumber'
    require 'cucumber/rake/task'
    Cucumber::Rake::Task.new(:features) do |t|
      t.cucumber_opts = "features --format pretty"
    end
  end

  if File.exists?('specs')
    require 'rspec/core/rake_task'
    desc "Run all examples"
    RSpec::Core::RakeTask.new(:specs) do |t|
      t.rspec_opts  = ['--color', '--format', 'nested']
    end
  end

  task :default => [:specs, :features].select{|t| Rake::Task.task_defined?(t)}

  task :start do
    do_something!
  end
EOF
end
