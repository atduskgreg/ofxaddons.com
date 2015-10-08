class ApisController < ApplicationController

  # General purpose search (all params optional)
  # /api/v1/search?repo=xxx&owner=xxx&category=xxx
  def search1
    addons = Addon

    if params[:repo]
      addons = addons.where("lower(repos.name) = ?", params[:repo].downcase)
    end

    if params[:owner]
      addons = addons.joins(:user).includes(:user).where("lower(users.login) = ?", params[:owner].downcase)
    end

    if params[:category]
      addons = addons.joins(:categories).includes(:categories).where("lower(categories.name) = ?", params[:category].downcase)
    end

    render json: to_v1_repo_hashes(addons)
  end

  # Get info about a user
  def user1
    if user = User.where("lower(users.login) = ?", params[:login].downcase).first
      result = {
        :id => user.id,
        :username => user.login,
        :name => user.name,
        :avatar_url => user.avatar_url,
        :location =>  user.location
      }
      render json: result
    else
      head :not_found
    end
  end

  # Get a user's repositories
  def user_repos1
    addons = Addon.joins(:user).where("lower(users.login) = ?", params[:login].downcase)
    render json: to_v1_repo_hashes(addons)
  end

  # Get a single repository from a user
  def user_repo1
    addon = Addon.joins(:user)
      .where("lower(users.login) = ?", params[:login].downcase)
      .where("lower(repos.name) = ?", params[:repo_name].downcase)
      .first
    render json: to_v1_repo_hash(addon)
  end

  # Get all repositories
  def repos1
    addons = Addon.order("repos.name ASC")
    render json: to_v1_repo_hashes(addons)
  end

  # Get specific repositories by name
  def repo1
    addons = Addon.where("lower(repos.name) = ?", params[:repo_name].downcase)
    render json: to_v1_repo_hashes(addons)
  end

  private

  def to_v1_repo_hashes(repos)
    repos.map { |r| to_v1_repo_hash(r) }
  end

  def to_v1_repo_hash(repo)
    {
      :name => repo.name,
      :owner => repo.user.login,
      :description =>  repo.description,
      :github_created_at => repo.created_at,
      :category => (!repo.categories.empty? ? repo.categories.first.name : ""),
      :homepage => "https://github.com/#{repo.full_name}",
      :clone_url => "https://github.com/#{repo.full_name}.git",
      :warning_labels => repo.warning_labels,
      :latest_commit => {
        :sha => (repo.most_recent_commit.nil?) ? "" :  repo.most_recent_commit['sha'],
        :date => repo.pushed_at,
        :message => (repo.most_recent_commit.nil?) ? "" : repo.most_recent_commit['commit']['message']
      }
    }
  end

end
