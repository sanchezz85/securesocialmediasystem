class HomeController < ApplicationController
  
  def new
  end
  def index
    if current_user
      init_displayed_user(current_user.id)
    end
  end
end
