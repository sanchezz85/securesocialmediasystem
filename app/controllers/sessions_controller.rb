class SessionsController < ApplicationController
  
  def new
  end
  
  def create
    user = User.authenticate(params[:email]+"@"+local_ip, params[:password])
    if user
      session[:user_email] = user.email
      if session[:return_to] #in case there was a request before log_in, return to the requested url
        redirect_to session[:return_to]
      elsif user.profile == nil #user already has a profile? -> show profile, else create profile
        redirect_to new_profile_path,:notice => "Logged in! Please create your profile now!"
      else
        redirect_to "/profiles", :notice => "Logged in!"
      end 
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end
   
  def remote_create
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    @remote_user = User.new
    @remote_user.email = parsed_json["email"]
    @remote_user.homeserver= parsed_json["homeserver"]
    session[:user_email] = @remote_user
    if session[:user_email]
      logger.info("remote_create: session created:" + parsed_json.to_s)
      render json: '{"remote_create status":"successful"}'
    else
      render json: '{"remote_create status":"failure"}'
    end    
  end

  def destroy
    session[:user_email] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
