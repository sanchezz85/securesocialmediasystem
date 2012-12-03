class SessionsController < ApplicationController
  
  def new
  end
  
  #ToDo: Authentifizierung gegenüber Zentralserver (Feld für google pin hinzufügen)
  #  Wenn erfolgreich, User + SSMS_Token in Session speichern
  def create
    #user = User.authenticate(params[:email]+"@"+local_ip, params[:password]) # entfernen
    
    auth_package = { "username" => params[:email], "password" => ActiveSupport::Base64.encode64(params[:password]), "totp-token" => params[:authcode] }
    
    #convert object into json
    j = ActiveSupport::JSON
    json_object = j.encode(auth_package)
    #open faraday connection and post json data to remote url
    connection = Faraday::Connection.new
    response = connection.post do |req|
      req.url  CENTRAL_SERVER_ADDRESS + "/ssms/user/login"
      req["Content-Type"] = "application/json"
      req.body = json_object
    end
    
    flash[:notice] = response.headers.to_s
    
    if response.headers["ssms-token"] then
      session[:user_email] = params[:email] + "@" + local_ip
      session[:auth_token] = response.headers["ssms-token"]
      if session[:return_to] #in case there was a request before log_in, return to the requested url
        redirect_to session[:return_to]
      elsif user.profile == nil #user already has a profile? -> show profile, else create profile
        redirect_to new_profile_path,:notice => "Logged in! Please create your profile now!"
      else
        redirect_to "/profiles", :notice => "Logged in!"
      end
    else
      flash[:error] = "Login failed."
      render "new"
    end
  end
   
  def remote_create #ToDo: nur email übergeben, nicht den ganzen user
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    @remote_user = User.new
    @remote_user.email = parsed_json["email"]
    @remote_user.homeserver= parsed_json["homeserver"]
    if session[:remote_user_email] 
      logger.info("session#remote_create: session already exists!")
    else
      session[:remote_user_email] = @remote_user.email
      logger.info("session#remote_create: new session created! Session ID:" + request.session_options[:id])
      logger.info("session#remote_create: session[remote_user_email created]:" + session[:remote_user_email])
      logger.info("remote_user.email: " + @remote_user.email)
    end
    if session[:remote_user_email]
      logger.info("remote_create: session created:" + parsed_json.to_s)
      render json: '{"session_id":"' + request.session_options[:id]+'"}'
    else
      render json: '{"remote_create status":"failure"}'
    end    
  end

  def destroy
    session[:user_email] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
