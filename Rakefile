# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

if Rails.env.production?
  # load assets gems here, so they don't have to be require'd in
  # config/application.rb and take up unnecessary memory in the
  # production environment
  Bundler.require(:assets)
end

Rails.application.load_tasks
