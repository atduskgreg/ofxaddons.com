class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :current_user
  before_filter :set_body_attrs

  private

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue
      session[:user_id] = nil
      cookies.delete(:user_id)
      @current_user = nil
    end
  end

  def set_body_attrs
    controller, action = params[:controller], params[:action]
    controller = controller.gsub("/", "_")
    @action = "#{controller}_#{action}"
    #data = { controller: controller, action: action }
  end

end
