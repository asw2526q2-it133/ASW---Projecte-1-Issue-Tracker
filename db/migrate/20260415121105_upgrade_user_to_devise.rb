class UpgradeUserToDevise < ActiveRecord::Migration[8.1]
  def change
  add_column :users, :encrypted_password, :string, null: false, default: ""
  add_column :users, :full_name, :string
  add_column :users, :bio, :text
  add_column :users, :provider, :string
  add_column :users, :uid, :string
  
  # Treu has_secure_password si existía
  remove_column :users, :password_digest, :string if column_exists?(:users, :password_digest)
  end
end
