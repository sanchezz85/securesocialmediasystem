class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :sender
      t.string :receiver
      t.text :content
      t.boolean :read

      t.timestamps
    end
  end
end
