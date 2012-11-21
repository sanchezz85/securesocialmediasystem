class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :lastname
      t.string :firstname
      t.date :birthdate
      t.string :phonenumber
      t.string :street
      t.string :number
      t.string :postalcode
      t.string :city
      t.string :gender
      t.text :hobbies
      t.text :jobs
      t.text :sports
      t.text :education
      t.integer :user_id
      
      t.timestamps 
    end
  end
end
