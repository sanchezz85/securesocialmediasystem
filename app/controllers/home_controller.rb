class HomeController < ApplicationController
  
  skip_before_filter :login_required
  
  def new
  end
  def index
  end
end
