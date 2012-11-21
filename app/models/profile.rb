class Profile < ActiveRecord::Base
  belongs_to :user
  has_attached_file :photo, :styles => {:small => "150x150>"}
end
