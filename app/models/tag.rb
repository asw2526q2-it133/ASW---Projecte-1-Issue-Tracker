class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :issues
  has_many :issue_tags, dependent: :destroy
  has_many :issues, through: :issue_tags
end
