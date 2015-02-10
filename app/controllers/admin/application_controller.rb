class Admin::ApplicationController < ApplicationController

  layout "admin"

  before_filter :ensure_admin

  def ensure_admin
    unless @current_user
      redirect_to(root_path)
    end
  end

end
