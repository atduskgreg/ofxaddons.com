class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]
    user = User.login(auth)
    session[:user_id] = user.id
    cookies[:user_id] = user.id
    redirect_to root_url, :notice => "Signed in!"
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:user_id)
    redirect_to root_url, :notice => "Signed out!"
  end

end
