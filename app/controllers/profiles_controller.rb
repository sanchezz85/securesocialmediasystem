class ProfilesController < ApplicationController
  # GET /profiles
  # GET /profiles.json
  def index
    @profile = current_user.profile
    render "show"
    #respond_to do |format|
      #format.html # show.html.erb
      #format.json { render json: @profile }
    #end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    if params[:id]
      @profile = Profile.find(params[:id])
    else
      @profile = current_user.profile
    end
      
    if @profile
      @profileowner = User.find(@profile.user_id)
    else
      @profileowner = current_user 
    end
    
    @guestbookentries = Guestbookentry.where("receiver= ?", @profileowner.email).order("created_at DESC")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/new
  # GET /profiles/new.json
  def new
    @profile = Profile.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    @profile = current_user.profile
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(params[:profile])
    current_user.profile  = @profile
    
    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created for user: ' + current_user.email }
        #format.json { render json: @profile, status: :created, location: @profile }
      else
        format.html { render action: "new" }
        #format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    @profile = current_user.profile

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url }
      format.json { head :no_content }
    end
  end
end
