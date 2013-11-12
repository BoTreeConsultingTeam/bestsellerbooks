class MyRegistrationsController < ApplicationController

  prepend_view_path "app/views/devise"

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save && @user.admin?
      flash.now[:notice] = "You have successfully sign up"
      redirect_to manually_add_isbn_create_path
    elsif @user.save && !@user.admin?
      flash.now[:notice] = "You have successfully sign up"
      redirect_to root_path    
    else
      flash.now[:notice] = "Error has occurred"
      redirect_to root_path
    end
  end
  
end