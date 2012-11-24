class MessagesController < ApplicationController
  
  before_filter :login_required, except: [:remote_create, :remote_destroy]
  
  # GET /messages
  # GET /messages.json
  def index
    @incomingmessages = Message.where("receiver=?", current_user.email).order("created_at DESC")
    @outgoingmessages = Message.where("sender=?", current_user.email).order("created_at DESC")
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])
    @message.read = true
    if @message.save
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @message }
      end 
    end
  end
  
  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new
    @users = get_all_user
    @users.delete(current_user)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])
    @message.sender = current_user.email
    #@receiver = User.find_by_email(@message.receiver)
    #@receiver.messages<<@message
    if @message.save
      logger.info("Message from " + @message.sender + " has been sent to " + @message.receiver)
      #check wheter receiver is located on a remote server
      if is_remote_user?(@message.receiver)
        logger.info("remote_create for message is required!")
        #remote message creation
        remote_url = "http://" + parse_homeserver(@message.receiver) + ":3000/messages/remotecreate"
        response = post_to_remote_url(remote_url,@message)
        logger.info("message sent to remote_create with Result: " + response)
        redirect_to @message, notice: 'Message was successfully created.'  
      else
        logger.info("No need for message remote_create!")
        redirect_to @message, notice: 'Message was successfully created.'   
      end      
    else
      logger.info("Error while saving message!")
      render action: "new" 
    end
  end

  # POST /messages/remotecreate
  def remote_create
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    @message = Message.new
    @message.receiver = parsed_json["receiver"]
    @message.sender= parsed_json["sender"]
    @message.content = parsed_json["content"]
    @message.subject = parsed_json["subject"]
    @message.read = parsed_json["read"]
    @message.created_at = parsed_json["created_at"]
    if @message.save
      logger.info("remote_create: message added:" + parsed_json.to_s)
      render json: '{"remote_create status":"successful"}'
    else
      render json: '{"remote_create status":"failure"}'
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])
    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    if @message.destroy
      logger.info("messages#destroy:  message destroyed!")
      if is_remote_user?(@message.sender)
        logger.info("remote_destroy is required!")
        remote_url = "http://" + parse_homeserver(@message.sender) + ":3000/messages/remotedestroy"
        response = post_to_remote_url(remote_url,@message)
        logger.info("message sent to remote_destroy with Result: " + response)    
      end      
      if is_remote_user?(@message.receiver)
        logger.info("remote_destroy is required!")
        remote_url = "http://" + parse_homeserver(@message.receiver) + ":3000/messages/remotedestroy"
        response = post_to_remote_url(remote_url,@message)
        logger.info("message sent to remote_destroy with Result: " + response)    
      end 
      redirect_to messages_url 
    end
  end
  
  # Get /messages/remotedestroy
  def remote_destroy
    j = ActiveSupport::JSON
    parsed_json = j.decode(request.body)
    receiver = parsed_json["receiver"]
    sender = parsed_json["sender"]
    subject = parsed_json["subject"]
    @message = Message.where("receiver =? AND sender =? AND subject =?",receiver,sender,subject).first
    if @message.destroy
      logger.info("remote_destroy: message destroyed:" + parsed_json.to_s)
      render json: '{"remote_destroy status":"successful"}'
    else
      render json: '{"remote_destory status":"failure"}'
    end 
  end

end
