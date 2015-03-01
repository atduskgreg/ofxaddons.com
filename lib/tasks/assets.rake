# do some gymnastics to load assets gems before asset compilation, so
# they don't have to be require'd in config/application.rb and take up
# unnecessary memory

namespace :assets do
  task :load_assets_gems do
    Bundler.require(:assets)
  end

 # 1) select all tasks that begin with the "assets:" namespace
  tasks_in_assets_namespace = Rake.application.tasks.select {|task| task.name.start_with? "assets:"}

  # 2) call #enhance on each of those tasks, passing an array of task dependencies
  tasks_in_assets_namespace.each do |task|
    task.enhance ["assets:load_assets_gems"]
  end
end
