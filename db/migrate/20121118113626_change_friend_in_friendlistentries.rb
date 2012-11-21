class ChangeFriendInFriendlistentries < ActiveRecord::Migration
  def up
    change_column :friendlistentries, :friend, :string
  end

  def down
    change_column :friendlistentries, :friend, :integer
  end
end
