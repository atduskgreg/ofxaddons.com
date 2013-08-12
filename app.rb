require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require "sinatra/config_file"
require './models'
require 'yaml'
require 'backports'

config_file 'datas/config.yml'

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

before do
    @categories = Category.all(:order => :name.asc)
end

def bake_html
  File.open('public/index.html', 'w') do |f|
    request = Rack::MockRequest.new(Sinatra::Application)
    f.write request.get('/render').body
  end
end

get "/api/v1/all.json" do
  content_type :json
  repos = Repo.all(:not_addon => false, :is_fork => false, :category.not => nil, :deleted => false, :order => :name.asc)
  {"repos" => repos.collect{|r| r.to_json_hash}}.to_json  
end

get "/" do
  send_file File.join(settings.public_folder, 'index.html')
end

get "/render" do
  @current = "addons"
  @categorized = Repo.all(:not_addon => false, :incomplete => false, :is_fork => false, :deleted => false, :category.not => nil, :order => :name.asc)
  @uncategorized = Repo.all(:not_addon => false, :is_fork => false, :deleted => false, :category => nil, :order => :name.asc)
  @repo_count = Repo.count(:conditions => ['not_addon = ? AND is_fork = ? AND deleted = ?', 'false', 'false', 'false'])
  erb :repos
end

get "/changes" do  
  @current = "changes"
  @most_recent = Repo.all(:not_addon => false, :is_fork => false, :deleted => false, :category.not => nil, :order => [:last_pushed_at.desc]) 
  erb :changes
end

# update all
put "/repos/update_all" do
  protected!
  params[:repos].each do |r|
    @repo = Repo.get(r[0])
    rps = params[:repos][r[0]].select {|k,v| puts "new k #{k} v #{v}"; not v.eql? ""}
    val = @repo.update(rps)
  end

  redirect "/admin"
end

put "/repos/:repo_id" do
  protected!
  @repo = Repo.get(params[:repo_id])
  @repo.update(params[:repo])
  bake_html
  redirect "/admin"
end

get "/repos/:repo_id" do
  @uncategorized = Repo.all(:not_addon => false, :is_fork => false, :category => nil, :deleted => false, :order => :name.asc)
  @repo = Repo.get(params[:repo_id])
  erb :repo
end

get "/admin" do
  protected!
  @not_addons = Repo.all(:not_addon => true, :deleted => false, :order => :name.asc)
  repos = Repo.all(:not_addon => false, :is_fork => false, :deleted => false, :order => :name.asc)

  @incomplete = repos.select{|r| r.incomplete}
  @uncategorized = repos.select{|r| r.category.nil? and not r.incomplete}
  @categorized = repos.partition{|r| not r.category.nil? and not r.incomplete}
  
  erb :admin
end

get "/howto/" do
  @current = "howto"
  erb :howto
end

get "/users/:user_name" do
  @current = "contributors"
  @user = params[:user_name]
  @user_data = Repo.first(:owner => params[:user_name], :not_addon => false, :is_fork => false, :deleted => false)
  @user_repos = Repo.all( :owner => params[:user_name], :not_addon => false, :is_fork => false, :deleted => false, :order => [:followers.desc])
  erb :user
end

get "/contributors" do
  @current = "contributors"
  @contributors = Repo.all(:not_addon => false, :is_fork => false, :deleted => false, :category.not => nil, :order => :name.asc)
  @contributors = @contributors.uniq {|r| r.owner}
  erb :contributors
end

get "/unfinished" do
  @current = "unfinished"
  @uncategorized = Repo.all(:category => nil, :not_addon => false, :is_fork => false, :deleted => false, :order => :name.asc)
  @incomplete = Repo.all(:incomplete => true, :not_addon => false, :is_fork => false, :deleted => false, :order => :name.asc)
  erb :unfinished
end
