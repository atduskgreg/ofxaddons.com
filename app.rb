require 'rubygems'
require 'sinatra'
require './models'
require 'yaml'

helpers do

  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    
    user = User.first(:username => "admin")
    
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [user.username, user.password]
  end

end

get "/" do
  @categories = Category.all(:order => :name.asc)
  
  @repo_count = Repo.count(:conditions => ['not_addon = ?', 'false'])
  
  @uncategorized = Repo.all(:not_addon => false, :category => nil, :order => :name.asc)
  erb :repos
end

put "/repos/:repo_id" do
  protected!
  
  @repo = Repo.get(params[:repo_id])
  @repo.update(params[:repo])
  redirect "/admin"
end

get "/repos/:repo_id" do
    @categories = Category.all(:order => :name.asc)
  @uncategorized = Repo.all(:not_addon => false, :category => nil, :order => :name.asc)

  @repo = Repo.get(params[:repo_id])
  erb :repo
end

get "/admin" do
  protected!
  
  @categories = Category.all
  
  @not_addons = Repo.all(:not_addon => true, :order => :name.asc)
  
  repos = Repo.all(:not_addon => false, :order => :name.asc)
  @uncategorized, @categorized = repos.partition{|r| r.category.nil?}
  
  erb :admin
end