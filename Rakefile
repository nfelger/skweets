task :default do
  Dir['modules/*'].each do |module_dir|
    exit(1) unless system("cd #{module_dir} && rake")
  end
end
