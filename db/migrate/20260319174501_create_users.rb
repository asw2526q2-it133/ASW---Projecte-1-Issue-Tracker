class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :encrypted_password, null: false, default: ""
      t.string :full_name
      t.text :bio
      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end
