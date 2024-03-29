class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #work around for csrf-problem with json
  skip_before_filter :verify_authenticity_token
  
  helper_method :current_user
  helper_method :remote_user
  helper_method :create_server_url

  #Get the current user (logged in)
  private
  def current_user
    @current_user ||= User.find_by_email(session[:user_email]) if session[:user_email]
  end
  
  private
  def remote_user
    @remote_user ||= session[:remote_user_email] if session[:remote_user_email] 
  end
  
  #Create propper url to remote server
  def create_server_url(ip)
    return REMOTE_SERVER_LINK_PREFIX + ip + REMOTE_SERVER_LINK_PORT
  end
  
  protected
  def init_displayed_user(id)
    if id then
      #profile = Profile.find(id)
      #@displayed_user ||= User.find_by_email(profile.email)
      @displayed_user = User.find(id)
    else
      @displayed_user = nil
    end
  end
  
  protected
  def login_required
    #if (remote)request has param sessionid, map the corresponding session to this request
    if params[:sessionid] and params[:email]  
      #loading remote_user_email from session (created by remote session creation one request ago )
      loaded_session = Session.find_by_session_id(params[:sessionid])
      data = Marshal.load(ActiveSupport::Base64.decode64(loaded_session.data))
      remote_user_email = data["remote_user_email"]
      #if is_remote_user?(params[:email])
        session[:remote_user_email] = remote_user_email
      #else
        #session[:user_email] = params[:email] 
      #end
      session[:auth_token] = data["auth_token"]
      #request.session_options[:id] =  params[:sessionid]
      logger.info("Session id forwared:" + request.session_options[:id])
      if session[:remote_user_email]
        logger.info("remoter_user_email already exists!: " + session[:remote_user_email])
      else
        session[:remote_user_email] = params[:email]
        logger.info("remoter_user_email created!: " + session[:remote_user_email])
      end
    end
    
   #Authorize at central server
    if session[:user_email] then
      email = session[:user_email]
    elsif session[:remote_user_email] then
      email = session[:remote_user_email]
    end
    if email && session[:auth_token] then
      j = ActiveSupport::JSON
      # Try authorization by token
      #json_object = j.encode({})
      #open faraday connection and post json data to remote url
      connection = Faraday::Connection.new
      response = connection.get do |req|
        req.url  CENTRAL_SERVER_ADDRESS + "/ssms/user/auth"
        #req["Content-Type"] = ""
        req.headers["ssms-token"] = session[:auth_token]
        #req.body = "{}"
     end
      if response.status == 204 then
        # success
        session[:auth_token] = response.headers["ssms-token"]
        return true
      end
     flash[:csm] = j.decode(response.body).to_s
    end
  
    
    logger.info("sessions doesn't exist! -> Login")
    flash[:warning]='You are not logged in or your session timed out. Please login to continue.'
    session[:return_to]=request.fullpath
    redirect_to log_in_path
    return false 
  end
  
  #Get the home-server ip for registration/login
  protected
  #require 'socket'
  def local_ip
    return LOCAL_IP
  #orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  
  #UDPSocket.open do |s|
  #  s.connect '64.233.187.99', 1
  #  s.addr.last
  #end
  #ensure
  #  Socket.do_not_reverse_lookup = orig
  end
  
  #Get all nodes from central services server
  #ToDo: WS-call to receive all nodes
  protected
  def get_all_nodes
    if session[:auth_token] then
      j = ActiveSupport::JSON
      connection = Faraday::Connection.new
      response = connection.get do |req|
        req.url  CENTRAL_SERVER_ADDRESS + "/ssms/node"
        req["Content-Type"] = "application/json"
        req.headers["ssms-token"] = session[:auth_token]
        req.body = "{}"
      end
      resp = j.decode(response.body)
      @nodes = []
      resp.each do |str|
        @nodes.append(str["address"])
      end
      return @nodes
    end
  end
  
  #Get all user globally
  #ToDo: Get all users from central server
  protected
  def get_all_user
    connection = Faraday::Connection.new(:headers => {:accept =>'application/json'})
    j = ActiveSupport::JSON
    @all_user = User.all
    @nodes = get_all_nodes
    if @nodes
      @nodes.each do |node|
        if !node.eql?(local_ip)
          response = connection.get do |req|
            req.url create_server_url(node) + "/users/index"
            req.headers['Content-Type'] = 'application/json'
          end
          parsed_json = j.decode(response.body)
          logger.info("get_all_user: received and decoded json with user info: " + parsed_json.to_s)
          parsed_json.each do |u| # convert json to user objects
            user = User.new
            user.email = u["email"]
            user.id = u["id"]
            user.homeserver = u["homeserver"]
            @all_user<<user
          end
        end
      end
    else
      logger.info("get_all_user: no other nodes available!")
    end
    return @all_user  
  end
  
  #parse for homeserver url
  protected
  def parse_homeserver(string)
    stringlist = string.split("@")
    return stringlist.last
  end
  
  #Checks whether a user is located on a remote server
  protected
  def is_remote_user?(username)
    remote_ip = parse_homeserver(username)
    if remote_ip.eql?(local_ip)
      return false
    else
      return true
    end 
  end 
  
  #method for posting a object as json to a remote url
  protected
  def post_to_remote_url(remote_url,object)
    #convert object into json
    j = ActiveSupport::JSON
    #package = { "email" => user.email, "auth-token" => session[:auth_token] }
    json_object = j.encode(object)
    #open faraday connection and post json data to remote url
    connection = Faraday::Connection.new
    response = connection.post do |req|
      req.url  remote_url
      req["Content-Type"] = "application/json"
      req.body = json_object 
      #req.headers["ssms-token"] = session[:auth_token]  
    end
    return (j.decode(response.body)).to_s 
  end
 
end
