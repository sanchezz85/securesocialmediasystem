class FriendlistentriesController < ApplicationController
  
  before_filter :login_required, except: [:remote_create, :remote_destroy, :remote_confirm]
  
  # GET /friendlistentries
  # GET /friendlistentries.json
  def index
    init_displayed_user(current_user.id)
    @friends = Friendlistentry.where("(user_id =? OR friend =?)AND confirmation =?",current_user.id,current_user.email, true)
    @outgoingrequests = Friendlistentry.where("user_id =? AND confirmation =?",current_user.id, false)
    @incomingrequests = Friendlistentry.where("friend =? AND confirmation =?",current_user.email, false)
  end

  # GET /friendlistentries/new
  # GET /friendlistentries/new.json
  def new
    init_displayed_user(current_user.id)
    @friendlistentry = Friendlistentry.new
    #@users = get_all_user
    #@users = get_all_user
    #@users.delete(current_user)
    #current_user.friendlistentries.each do |entry| #remove friends
      #@user_to_be_deleted = User.find(entry.friend)
      #@users.delete(@user_to_be_deleted)
    #end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @friendlistentry }
    end
  end

  # POST /friendlistentries
  # POST /friendlistentries.json
  def create
    init_displayed_user(current_user.id)
    @friendlistentry = Friendlistentry.new(params[:friendlistentry])
    @friendlistentry.confirmation = false
    @friendlistentry.owner = current_user.email
    if Friendlistentry.where(:friend => @friendlistentry.friend , :user_id => current_user.id).exists?
      flash[:notice]= "Either friendship already exists or friendship request has been sent" 
      redirect_to action: "index"
    else
      current_user.friendlistentries<<@friendlistentry
        if @friendlistentry.save
          flash[:notice]= "Friendship request has been sent!" 
          logger.info("New friendlistentry saved: Owner: " + current_user.email + " with friend: " + @friendlistentry.friend)
          #check wheter friend is located on a remote server
          if is_remote_user?(@friendlistentry.friend)
            logger.info("remote_create for friendlistentry is required!")
            #remote friendlistentry creation
            remote_url = create_server_url(parse_homeserver(@friendlistentry.friend)) + "/friendlistentries/remotecreate"
            response = post_to_remote_url(remote_url,@friendlistentry)
            logger.info("friendlistentry sent to remote_create with Result: " + response)
            redirect_to action: "index"
          else
            logger.info("No need for friendlistentry remote_create!")
            redirect_to action: "index"
          end
        else
          logger.info("Error while saving friendlistentry!")
          render action: "new" 
        end
      end
   end
  
  # POST /friendlistentries/remotecreate
  def remote_create
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    @friendlistentry = Friendlistentry.new
    @friendlistentry.friend = parsed_json["friend"]
    @friendlistentry.user_id = parsed_json["user_id"]
    @friendlistentry.owner = parsed_json["owner"]
    @friendlistentry.confirmation = parsed_json["confirmation"]
    if @friendlistentry.save
      logger.info("remote_create: friendlistentry added:" + parsed_json.to_s)
      render json: '{"remote_create status":"successful"}'
    else
      render json: '{"remote_create status":"failure"}'
    end
  end
  

  # DELETE /friendlistentries/1
  # DELETE /friendlistentries/1.json
  def destroy
    init_displayed_user(current_user.id)
    @friendlistentry = Friendlistentry.find(params[:id])
    if @friendlistentry.destroy
      logger.info("friendlistentries#destroy:  friendlistentry destroyed!")
      if is_remote_user?(@friendlistentry.owner)
        logger.info("remote_destroy is required!")
        remote_url = create_server_url(parse_homeserver(@friendlistentry.owner)) + "/friendlistentries/remotedestroy"
        response = post_to_remote_url(remote_url,@friendlistentry)
        logger.info("friendlistentry sent to remote_destroy with Result: " + response)    
      end      
      if is_remote_user?(@friendlistentry.friend)
        logger.info("remote_destroy is required!")
        remote_url = create_server_url(parse_homeserver(@friendlistentry.friend)) + "/friendlistentries/remotedestroy"
        response = post_to_remote_url(remote_url,@friendlistentry)
        logger.info("friendlistentry sent to remote_destroy with Result: " + response)    
      end        
      redirect_to friendlistentries_url 
    end
  end
  
  # Get /friendlistentries/remotedestroy
  def remote_destroy
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    friend = parsed_json["friend"]
    owner = parsed_json["owner"]
    @friendlistentry = Friendlistentry.where("owner =? AND friend =?",owner, friend).first
    if @friendlistentry.destroy
      logger.info("remote_destroy: friendlistentry destroyed:" + parsed_json.to_s)
      render json: '{"remote_destroy status":"successful"}'
    else
      render json: '{"remote_destory status":"failure"}'
    end 
  end
  
  # Get confirmrequest/1
  def confirmrequest
    init_displayed_user(current_user.id)
    @friendlistentry = Friendlistentry.find(params[:id])
    @friendlistentry.confirmation = true
    if @friendlistentry.save
      logger.info("confirmrequest: friendlistentry confirmed!")
      #check wheter friend is located on a remote server
      if is_remote_user?(@friendlistentry.owner) # Owner not friend!
        logger.info("remote_confirmrequest is required!")
        remote_url = create_server_url(parse_homeserver(@friendlistentry.owner)) + "/friendlistentries/remoteconfirm"
        response = post_to_remote_url(remote_url,@friendlistentry)
        logger.info("friendlistentry sent to remote_confirm with Result: " + response)   
      end
      redirect_to friends_path
    end
  end
  
   # Get /friendlistentries/remoteconfirm
  def remote_confirm
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    friend = parsed_json["friend"]
    owner = parsed_json["owner"]
    @friendlistentry = Friendlistentry.where("owner =? AND friend =?",owner, friend).first
    @friendlistentry.confirmation = true
    if @friendlistentry.save
      logger.info("remote_confirm: friendlistentry confirmed:" + parsed_json.to_s)
      render json: '{"remote_confirm status":"successful"}'
    else
      render json: '{"remote_confirm status":"failure"}'
    end 
  end
  
  
end
