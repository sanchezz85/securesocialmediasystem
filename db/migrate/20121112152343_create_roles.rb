class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :friendlistentry_id
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
