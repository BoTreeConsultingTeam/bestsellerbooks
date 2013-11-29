class AdminController < ApplicationController
  
  def index
  	redirect_to new_user_session_path
  end

  def new
  	redirect_to root_path
  	flash[:alert] = "Unauthorized"
  end
end
