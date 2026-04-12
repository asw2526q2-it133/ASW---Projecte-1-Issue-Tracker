class Issue < ApplicationRecord
  # Supongo que habrà mas cosas aqui
  #
  #
  #
  #
  belongs_to :user, optional: true
  has_many :issue_tags, dependent: :destroy
  has_many :tags, through: :issue_tags
end
