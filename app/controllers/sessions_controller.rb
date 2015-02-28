class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    user = User.login(auth)

    if user.admin?
      session[:user_id] = user.id
      cookies[:user_id] = user.id
      redirect_to root_url, :success => "Signed in!"
    else
      user = nil
      redirect_to root_url, :alert => "Sorry! At the moment there's nothing useful to do with login unless you're an admin. Stay tuned, we'll be adding some user-facing features in the future."
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:user_id)
    redirect_to root_url, :success => "Signed out!"
  end

end
