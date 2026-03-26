class User < ApplicationRecord
  has_secure_password
  has_many :issues, dependent: :destroy
end
