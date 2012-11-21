class CreateGuestbookentries < ActiveRecord::Migration
  def change
    create_table :guestbookentries do |t|
      t.string :sender
      t.string :receiver
      t.text :content

      t.timestamps
    end
  end
end
