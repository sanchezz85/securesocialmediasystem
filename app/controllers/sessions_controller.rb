class SessionsController < ApplicationController
  def new
  end
  def create
    user = User.authenticate(params[:email]+"@"+local_ip, params[:password])
    if user
      session[:user_id] = user.id
      #user already has a profile? -> show profile, else create profile
      if user.profile == nil
        redirect_to new_profile_path,:notice => "Logged in! Please create your profile now!"
      else
        redirect_to "/profiles", :notice => "Logged in!"
      end
      
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
   end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
