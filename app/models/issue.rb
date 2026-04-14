class Issue < ApplicationRecord
  belongs_to :creator, class_name: 'User'
  belongs_to :status, optional: true
  belongs_to :priority, optional: true
  belongs_to :type, optional: true
  belongs_to :severity, optional: true
  
  has_many :assignments
  has_many :users, through: :assignments
  has_many :comments, dependent: :destroy
  has_many :issue_tags
  has_many :tags, through: :issue_tags
end
