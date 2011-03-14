# Every module has a start task.
Dir['modules/*'].each do |module_dir|
  module_name = module_dir.split('/').last
  namespace module_name.to_sym do
    desc "Start #{module_name}"
    task :start do
      exit(1) unless system("cd #{module_dir} && rake start")
    end
  end
end



desc "Run tests in all projects."
task :default do
  Dir['modules/*'].each do |module_dir|
    exit(1) unless system("cd #{module_dir} && rake")
  end
end
