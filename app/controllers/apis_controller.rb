class ApisController < ApplicationController

  # General purpose search (all params optional)
  # /api/v1/search?repo=xxx&owner=xxx&category=xxx
  def search1
    @results = Addon

    if params[:repo]
      @results = @results.where("lower(repos.name) = ?", params[:repo].downcase)
    end

    if params[:owner]
      @results = @results.joins(:user).includes(:user).where("lower(users.login) = ?", params[:owner].downcase)
    end

    if params[:category]
      @results = @results.joins(:categories).includes(:categories).where("lower(categories.name) = ?", params[:category].downcase)
    end

    @results = @results.map do |r|
      {
        :name => r.name,
        :owner => r.owner_login,
        :description =>  r.description,
        :github_created_at => r.created_at,
        :category => r.categories.first.name,
        :homepage => "https://github.com/#{r.full_name}",
        :clone_url => "https://github.com/#{r.full_name}.git",
        :warning_labels => r.warning_labels,
        :latest_commit => {
          :sha => (r.most_recent_commit.nil?) ? "" :  r.most_recent_commit['sha'],
          :date => r.pushed_at,
          :message => (r.most_recent_commit.nil?) ? "" : r.most_recent_commit['commit']['message']
        }
      }
    end

    render json: @results
  end

  # # Get info about a user
  def user1

  end
  #   content_type :json
  #   contributor = Contributor.first(:conditions => ["lower(login) = ?", params[:username].downcase])
  #   json user: contributor.to_json_hash
  # end

  # # Get a user's repositories
  # get "/api/v1/users/:username/repos" do
  #   content_type :json
  #   repos = Repo.all(:conditions => ["lower(owner) = ?", params[:username].downcase ],  :not_addon => false, :category.not => nil, :deleted => false)
  #   json repos: repos.collect{ |r| r.to_json_hash_v2 }
  # end

  # # Get a single repository from a user
  # get "/api/v1/users/:username/repos/:repo_name" do
  #   content_type :json
  #   repo = Repo.first(:conditions => ["lower(name) = ? AND lower(owner) = ?", params[:repo_name].downcase, params[:username].downcase],  :not_addon => false, :category.not => nil, :deleted => false)
  #   json repo: repo.to_json_hash_v2
  # end

  # # Get all repositories
  # get "/api/v1/repos" do
  #   content_type :json
  #   repos = Repo.all(:not_addon => false, :is_fork => false, :category.not => nil, :deleted => false, :order => :name.asc)
  #   json repos: repos.collect{ |r| r.to_json_hash_v2 }
  # end

  # # Get specific repositories by name
  # get "/api/v1/repos/:repo_name" do
  #   content_type :json
  #   repos = Repo.all(:conditions => ["lower(name) = ?", params[:repo_name].downcase], :not_addon => false, :is_fork => false, :category.not => nil, :deleted => false)
  #   json repos: repos.collect{ |r| r.to_json_hash_v2 }
  # end

  # # DEPRECATED: user /api/v1/repos
  # get "/api/v1/all.json" do
  #   content_type :json
  #   repos = Repo.all(:not_addon => false, :is_fork => false, :category.not => nil, :deleted => false, :order => :name.asc)
  #   {"repos" => repos.collect{|r| r.to_json_hash}}.to_json
  # end

end
