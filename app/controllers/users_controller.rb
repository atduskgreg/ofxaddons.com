class UsersController < ApplicationController

  def index
    @users = User.with_addons_count.order("repo_count DESC, users.login ASC")
  end

  def show
    @user = User.find_provider_login("github", login_param)
    @addons = Addon.where(user_id: @user.id).order("lower(repos.name) ASC")
  end

  private

  def login_param
    params.require(:login)
  end

end
