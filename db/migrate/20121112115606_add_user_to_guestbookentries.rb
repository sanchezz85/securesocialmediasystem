class AddUserToGuestbookentries < ActiveRecord::Migration
  def change
    add_column :guestbookentries, :user_id, :integer

  end
end
