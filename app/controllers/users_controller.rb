class UsersController < ApplicationController
  
before_filter :login_required, except: [:index, :create, :new]

  def index
    @users = User.all
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @users }
    end
  end
  
  def new
    @user = User.new
    @last_email = ""
    @local_ip = local_ip
  end
  
  #ToDo: - Passwortlogik rausnehmen
  # =>   Registrierung am Zentralserver aufrufen (password muss zuvor base64 kodiert sein!)
  # =>   Wenn Registrierung am Zentralserver + @user.save erfolgreich, dann "show qr-code" (controller action + view erstellen)
  def create
    @user = User.new
    @user.email = params[:email] + "@" + local_ip
    @user.homeserver = local_ip
    
    @last_email = params[:email]
    
    # Password present?
    if (!params[:password]) || (params[:password] == '') then
      flash.now[:error] = "Enter password"
      render "new"
      return
    end
    
    password = params[:password]
    
    # Password confirmed?
    if password != params[:password_confirmation] then
      flash.now[:error] = "Passwords do not match, try again"
      render "new"
      return
    end
    
    # Password secure?
    if password.match(/^(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){10,255}$/).nil? then
      flash.now[:error] = "Password security too low, please check the password security requirements below"
      render "new"
      return
    end
    
    reg_package = { "username" => params[:email], "password" => ActiveSupport::Base64.encode64(password), "node-address" => local_ip }
    
    #convert object into json
    j = ActiveSupport::JSON
    json_object = j.encode(reg_package)
    #open faraday connection and post json data to remote url
    connection = Faraday::Connection.new
    response = connection.post do |req|
      req.url  CENTRAL_SERVER_ADDRESS + "/ssms/user/register"
      req["Content-Type"] = "application/json"
      req.body = json_object
    end
    
    if j.decode(response.body)["qrcode"] then
      if @user.save then
        flash[:qrcode] = j.decode(response.body)["qrcode"]
        redirect_to "/pages?id=qrcode"
      else
        flash.now[:error] = "Error saving user to local database"
        render "new"
      end 
    else
      flash[:error] = j.decode(response.body).to_s
      render "new"
    end
    
    #@user = User.new(params[:user])
    #@user.email = @user.email + "@" + local_ip
    #if @user.save
    #  redirect_to root_url, :notice => "Signed up!"
    #else
    #  flash.now[:error] = "Error saving"
    #  render "new"
    #end
  end
  
  
end
