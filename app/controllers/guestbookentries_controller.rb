class GuestbookentriesController < ApplicationController
  
  before_filter :login_required
  
  # GET /guestbookentries
  # GET /guestbookentries.json
  def index
    @guestbookentries = Guestbookentry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @guestbookentries }
    end
  end

  # GET /guestbookentries/1
  # GET /guestbookentries/1.json
  def show
    @guestbookentry = Guestbookentry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @guestbookentry }
    end
  end

  # GET /guestbookentries/new/1
  # GET /guestbookentries/new.json
  def new
    @guestbookentry = Guestbookentry.new
    @profile = Profile.find(params[:id])
    @guestbookowner = User.find(@profile.user_id)
    @guestbookentry.receiver = @guestbookowner.email
    @guestbookentry.sender = current_user.email
    @guestbookentry.save
    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @guestbookentry }
    end
  end

  # GET /guestbookentries/1/edit
  def edit
    @guestbookentry = Guestbookentry.find(params[:id])
  end

  # POST /guestbookentries
  # POST /guestbookentries.json
  def create
    @guestbookentry = Guestbookentry.new(params[:guestbookentry])

    respond_to do |format|
      if @guestbookentry.save
        format.html { redirect_to @guestbookentry, notice: 'Guestbookentry was successfully created.' }
        format.json { render json: @guestbookentry, status: :created, location: @guestbookentry }
      else
        format.html { render action: "new" }
        format.json { render json: @guestbookentry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /guestbookentries/1
  # PUT /guestbookentries/1.json
  def update
    @guestbookentry = Guestbookentry.find(params[:id])
    @guestbookentryowner = User.find_by_email(@guestbookentry.receiver)
    @guestbookentryowner.guestbookentries<<@guestbookentry
    @lastProfile = Profile.where("email =?",@guestbookentry.receiver).first
   
    respond_to do |format|
      if @guestbookentry.update_attributes(params[:guestbookentry])
        format.html { redirect_to '/profiles?email='+@lastProfile.email , notice: 'Guestbookentry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @guestbookentry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /guestbookentries/1
  # DELETE /guestbookentries/1.json
  def destroy
    @guestbookentry = Guestbookentry.find(params[:id])
    @guestbookentry.destroy
    redirect_to my_profile_path
    
  end
end
