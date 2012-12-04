class SessionsController < ApplicationController
  
  def new
  end
  
  #ToDo: Authentifizierung gegenüber Zentralserver (Feld für google pin hinzufügen)
  #  Wenn erfolgreich, User + SSMS_Token in Session speichern
  def create
    #user = User.authenticate(params[:email]+"@"+local_ip, params[:password]) # entfernen
    
    user = User.find_by_email(params[:email] + "@" + local_ip)
    if !user then
      flash[:error] = "Login failed, user not found on local server. Please only login on your home server."
      render "new"
      return
    end
    
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
    
    if response.headers["ssms-token"] then
      session[:user_email] = params[:email] + "@" + local_ip
      session[:auth_token] = response.headers["ssms-token"]
      if session[:return_to] #in case there was a request before log_in, return to the requested url
        redirect_to "/"
        #redirect_to session[:return_to]
      elsif user.profile == nil #user already has a profile? -> show profile, else create profile
        redirect_to new_profile_path,:notice => "Logged in! Please create your profile now!"
        return
      else
        redirect_to "/"
        #redirect_to "/profiles", :notice => "Logged in!"
        return
      end
    else
      flash[:error] = "Login failed."
      render "new"
      return
    end
  end

  def remote_create #ToDo: nur email übergeben, nicht den ganzen user
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    remote_user = User.new
    remote_user.email = parsed_json["email"]
    remote_user.homeserver= parse_homeserver(@remote_user.email)
    session[:auth_token] = parsed_json["auth-token"]
    if remote_user.homeserver.eql?(local_ip) then
      # return to home server from remote
      session[:user_email] = remote_user.email
    else
      if session[:remote_user_email] 
        logger.info("session#remote_create: session already exists!")
      else
        session[:remote_user_email] = @remote_user.email
        logger.info("session#remote_create: new session created! Session ID:" + request.session_options[:id])
        logger.info("session#remote_create: session[remote_user_email created]:" + session[:remote_user_email])
        logger.info("remote_user.email: " + @remote_user.email)
      end
    end
    session[:auth_token] = auth_token
    logger.info("remote_create: session created:" + parsed_json.to_s)
    render json: '{"session_id":"' + request.session_options[:id]+'"}'
    
    #if session[:remote_user_email]
    #  logger.info("remote_create: session created:" + parsed_json.to_s)
    #  render json: '{"session_id":"' + request.session_options[:id]+'"}'
    #else
    #  render json: '{"remote_create status":"failure"}'
    #end    
  end

  def destroy
    session[:user_email] = nil
    session[:remote_user_email] = nil
    
    #logout at central server
    j = ActiveSupport::JSON
    # Try authorization by token
    #json_object = j.encode({})
    #open faraday connection and post json data to remote url
    connection = Faraday::Connection.new
    response = connection.post do |req|
      req.url  CENTRAL_SERVER_ADDRESS + "/ssms/user/logout"
      req["Content-Type"] = "application/json"
      req.headers["ssms-token"] = session[:auth_token]
      req.body = "{}"
    end
    if response.status == 204 then
      # success
    else
      flash[:error] = "Error making proper logout at central server."
    end
    
    session[:auth_token] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
