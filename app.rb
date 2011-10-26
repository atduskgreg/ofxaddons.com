require 'rubygems'
require 'sinatra'
require 'models'

get "/" do
  @repos = Repo.all(:order => :name.asc)
  erb :repos
end

delete "/repos/:repo_id" do
  @repo = Repo.get(params[:repo_id])
  @repo.destroy
  redirect "/"
end

get "/repos/:repo_id" do
  @repo = Repo.get(params[:repo_id])
  erb :repo
end