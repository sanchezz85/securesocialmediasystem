class AddHomeserverToUsers < ActiveRecord::Migration
  def change
    add_column :users, :homeserver, :string

  end
end
