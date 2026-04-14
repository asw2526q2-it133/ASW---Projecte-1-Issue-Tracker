class User < ApplicationRecord
  has_many :created_issues, class_name: 'Issue', foreign_key: 'creator_id'
  has_many :assignments
  has_many :assigned_issues, through: :assignments, source: :issue
  has_many :comments
end
