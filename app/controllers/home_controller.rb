class HomeController < ApplicationController

  def contact
    @guest_post = GuestPost.new
  end

  def guest_book
    @guest_post = GuestPost.new(params[:guest_post])
    if verify_recaptcha(model: @guest_post) && @guest_post.save
      flash[:notice] = 'Your message has been sent successfully. Thanks!!!'
      redirect_to contact_path
    else
      #@guest_post.errors.full_messages.ea
      render action: :contact
    end
  end
end
