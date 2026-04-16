class Issue < ApplicationRecord
  # creador de la issue (obligatori)
  belongs_to :user

  # persona a qui se li assigna la issue
  belongs_to :assignee, class_name: "User", optional: true

  # watchers de la issue
  has_many :issue_watchers, dependent: :destroy
  has_many :watchers, through: :issue_watchers, source: :user

  belongs_to :user, optional: true
  has_many :issue_tags, dependent: :destroy
  has_many :tags, through: :issue_tags
  belongs_to :priority
  belongs_to :issue_type
  belongs_to :severity
  belongs_to :status
  has_many :comments, dependent: :destroy

  scope :filter_by_status, ->(names) { joins(:status).where(statuses: { name: names }) if names.present? }
  scope :filter_by_priority, ->(names) { joins(:priority).where(priorities: { name: names }) if names.present? }
  scope :filter_by_severity, ->(names) { joins(:severity).where(severities: { name: names }) if names.present? }
  scope :filter_by_type, ->(names) { joins(:issue_type).where(issue_types: { name: names }) if names.present? }
end
