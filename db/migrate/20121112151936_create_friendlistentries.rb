class CreateFriendlistentries < ActiveRecord::Migration
  def change
    create_table :friendlistentries do |t|
      t.integer :friend
      t.integer :user_id

      t.timestamps
    end
  end
end
