class ApplicationController < ActionController::Base
  protect_from_forgery
  
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
    @nodes = ["192.168.3.3"]
  end
  
  #Get all user globally
  protected
  def get_all_user
    connection = Faraday::Connection.new(:headers => {:accept =>'application/json'})
    j = ActiveSupport::JSON
    @nodes = get_all_nodes
    @all_user = []
    #@nodes.each do |node|
    #@jsonstring = '[{"created_at":"2012-11-10T15:46:01Z","email":"maier6@hm.edu@192.168.3.2","homeserver":"192.168.3.2","id":1,"password_hash":"$2a$10$Dv/i2OoSmgEawERE6KvXQOj6Nw/ipZEeZMg4UHZgor9aTBywy1kd.","password_salt":"$2a$10$Dv/i2OoSmgEawERE6KvXQO","updated_at":"2012-11-10T15:46:01Z"},{"created_at":"2012-11-10T16:57:32Z","email":"andreasmaier1985@gmx.net@192.168.1.27","homeserver":"192.168.1.27","id":2,"password_hash":"$2a$10$2UUeJOq79HhMV8IaeUs/MutpuPpPcBB4cLjRDDgCjG6Oo0HoVBLiS","password_salt":"$2a$10$2UUeJOq79HhMV8IaeUs/Mu","updated_at":"2012-11-10T16:57:32Z"}]'              
     #@jsonstring = connection.get('localhost:3000/users/index') #ToDo: change "localhost" to "node"!!!!
     #@jsonstring = connection.get do |req|
        #req.url  'localhost:3000/users/index'
        #req.headers['Content-Type'] = 'application/json'
     #end
     response = connection.get do |req|
       req.url 'http://192.168.3.3:3000/users/index'
       req.headers['Content-Type'] = 'application/json'
     end
     
      parsed_json = j.decode(response.body)
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
