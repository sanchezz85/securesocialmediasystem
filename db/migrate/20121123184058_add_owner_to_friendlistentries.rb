class AddOwnerToFriendlistentries < ActiveRecord::Migration
  def change
    add_column :friendlistentries, :owner, :string

  end
end
