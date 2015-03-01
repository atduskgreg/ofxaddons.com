# do some gymnastics to load assets gems before asset compilation, so
# they don't have to be require'd in config/application.rb and take up
# unnecessary memory

namespace :assets do
  task :load_assets_gems do
    Bundler.require(:assets)
  end
end

Rake::Task["assets:environment"].enhance ["assets:load_assets_gems"]
