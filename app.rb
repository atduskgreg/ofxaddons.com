require 'rubygems'
require 'sinatra'
require './models'

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end

end

get "/" do
  @repos = Repo.all(:not_addon => false, :order => :name.asc)
  erb :repos
end

put "/repos/:repo_id" do
  protected!
  
  @repo = Repo.get(params[:repo_id])
  @repo.update(params[:repo])
  redirect "/admin"
end

get "/repos/:repo_id" do
  @repo = Repo.get(params[:repo_id])
  erb :repo
end

get "/admin" do
  protected!
  
  @not_addons = Repo.all(:not_addon => true, :order => :name.asc)
  
  repos = Repo.all(:not_addon => false, :order => :name.asc)
  @uncategorized, @categorized = repos.partition{|r| r.category.nil?}
  
  erb :admin
end