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
  end
  
  #ToDo: - Passwortlogik rausnehmen
  # =>   Registrierung am Zentralserver aufrufen (password muss zuvor base64 kodiert sein!)
  # =>   Wenn Registrierung am Zentralserver + @user.save erfolgreich, dann "show qr-code" (controller action + view erstellen)
  def create
  @user = User.new(params[:user])
  @user.email = @user.email + "@" + local_ip
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end
  
  
end
