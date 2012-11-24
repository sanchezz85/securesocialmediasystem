class UsersController < ApplicationController
  
  skip_before_filter :login_required
  
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
