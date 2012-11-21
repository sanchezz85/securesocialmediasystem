class FriendlistentriesController < ApplicationController
  # GET /friendlistentries
  # GET /friendlistentries.json
  def index
    @friends = Friendlistentry.where("user_id =? AND confirmation =?",current_user.id, true)
    @outgoingrequests = Friendlistentry.where("user_id =? AND confirmation =?",current_user.id, false)
    @incomingrequests = Friendlistentry.where("friend =? AND confirmation =?",current_user.id, false)
  end

  # GET /friendlistentries/1
  # GET /friendlistentries/1.json
  def show
    @friendlistentry = Friendlistentry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @friendlistentry }
    end
  end

  # GET /friendlistentries/new
  # GET /friendlistentries/new.json
  def new
    @friendlistentry = Friendlistentry.new
    #@users = get_all_user
    @users = get_all_user
    #current_user.friendlistentries.each do |entry| #remove friends
      #@user_to_be_deleted = User.find(entry.friend)
      #@users.delete(@user_to_be_deleted)
    #end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @friendlistentry }
    end
  end

  # GET /friendlistentries/1/edit
  def edit
    @friendlistentry = Friendlistentry.find(params[:id])
    @users = User.all
    @users.delete(current_user)
  end

  # POST /friendlistentries
  # POST /friendlistentries.json
  def create
    @friendlistentry = Friendlistentry.new(params[:friendlistentry])
    @friendlistentry.confirmation = false
    #if Friendlistentry.where(:friend => @friendlistentry.friend , :user_id => current_user.id).exists? || @friendlistentry.friend = current_user.email
      #redirect_to action: "index"
    #else
      current_user.friendlistentries<<@friendlistentry
        if @friendlistentry.save
          #remote friendlistentry creation
          ##extract remote url
          list = @friendlistentry.friend.split("@")
          remote_url = "http://" +list.last + ":3000/friendlistentries/remotecreate"
          ##convert friendlistentry into json
          j = ActiveSupport::JSON
          json_friendlistentry = j.encode(@friendlistentry)
          ##open faraday connection and post json data to remote url
          connection = Faraday::Connection.new(:headers => {:accept =>'application/json'})
          response = connection.post do |req|
            req.url  remote_url
            req.headers['Content-Type'] = 'application/json'
            req.body = json_friendlistentry 
          end
          redirect_to action: "index"
        else
          render action: "new" 
          
        end
      #end
      
   end
  
  # POST /friendlistentries/remotecreate
  def remote_create
    @friendlistentry = Friendlistentry.new(params[:friendlistentry])
    @friendlistentry.save
  end
  
  

  # PUT /friendlistentries/1
  # PUT /friendlistentries/1.json
  def update
    @friendlistentry = Friendlistentry.find(params[:id])

    respond_to do |format|
      if @friendlistentry.update_attributes(params[:friendlistentry])
        format.html { redirect_to @friendlistentry, notice: 'Friendlistentry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @friendlistentry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /friendlistentries/1
  # DELETE /friendlistentries/1.json
  def destroy
    @friendlistentry = Friendlistentry.find(params[:id])
    @friendlistentry.destroy
    respond_to do |format|
      format.html { redirect_to friendlistentries_url }
      format.json { head :no_content }
    end
  end
  
  # Get confirmrequest/1
  def confirmrequest
    @friendlistentry = Friendlistentry.find(params[:id])
    @friendlistentry.confirmation = true
    @friendlistentry.save
    redirect_to friends_path
  end
  

  
  
  
end
