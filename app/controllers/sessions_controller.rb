class SessionsController < ApplicationController
  
  skip_before_filter :login_required
  
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
    @message = Message.new
    @message.receiver = parsed_json["receiver"]
    @message.sender= parsed_json["sender"]
    @message.content = parsed_json["content"]
    @message.subject = parsed_json["subject"]
    @message.read = parsed_json["read"]
    @message.created_at = parsed_json["created_at"]
    if @message.save
      logger.info("remote_create: message added:" + parsed_json.to_s)
      render json: '{"remote_create status":"successful"}'
    else
      render json: '{"remote_create status":"failure"}'
    end    
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
