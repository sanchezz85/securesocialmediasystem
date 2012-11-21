class AddConfirmationToFriendlistentries < ActiveRecord::Migration
  def change
    add_column :friendlistentries, :confirmation, :boolean

  end
end
