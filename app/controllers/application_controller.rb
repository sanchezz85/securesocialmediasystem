class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #work around for csrf-problem with json
  skip_before_filter :verify_authenticity_token
  
  helper_method :current_user

  #Get the current user (logged in)
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  #Get the home-server ip for registration/login
  protected
  require 'socket'
  def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  
  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
  ensure
    Socket.do_not_reverse_lookup = orig
  end
  
  #Get all nodes from central services server
  #ToDo: WS-call to receive all nodes
  protected
  def get_all_nodes
    @nodes = ["192.168.1.77"]
  end
  
  #Get all user globally
  #ToDo: Get all users from central server
  protected
  def get_all_user
    connection = Faraday::Connection.new(:headers => {:accept =>'application/json'})
    j = ActiveSupport::JSON
    @nodes = get_all_nodes
    @all_user = []
    #@nodes.each do |node|
     response = connection.get do |req|
       req.url "http://" + get_all_nodes.first+ ":3000/users/index"
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
    #end
  return @all_user  
  end 
  
  
  
  
end
