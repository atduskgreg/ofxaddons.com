# config valid only for current version of Capistrano
lock '3.4.0'

server '104.130.78.26', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,      'git@example.com:atduskgreg/ofxaddons.com.git'
set :application,   'ofxaddons.com'
set :user,          'deploy'

set :pty,            true
set :use_sudo,       false
set :stage,          :production
set :deploy_via,     :remote_cache
set :deploy_to,      "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
