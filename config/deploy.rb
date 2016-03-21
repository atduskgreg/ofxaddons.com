# config valid only for current version of Capistrano
lock '3.4.0'

server 'deploy@104.130.78.26', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,      'https://github.com/atduskgreg/ofxaddons.com.git'
set :application,   'ofxaddons.com'
set :user,          'deploy'

set :pty,            true
set :use_sudo,       false
set :stage,          :production
set :deploy_via,     :remote_cache
set :deploy_to,      "/home/#{fetch(:user)}/#{fetch(:application)}"

set :linked_files, fetch(:linked_files, []).push('config/database.yml')
set :linked_files, fetch(:linked_files, []).push('config/secrets.yml')

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
      before 'deploy:restart'
      invoke 'deploy'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
