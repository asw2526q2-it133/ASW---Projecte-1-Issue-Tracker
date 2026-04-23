class Issue < ApplicationRecord
  attr_accessor :remove_attachments
  validates :subject, presence: true
  validate :no_duplicate_attachments

  # creador de la issue (obligatori)
  belongs_to :user

  # persona a qui se li assigna la issue
  belongs_to :assignee, class_name: "User", optional: true
  scope :open_assigned, -> { joins(:status).where.not(statuses: { name: ['Closed', 'Resolved'] }) }

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
  
  private

  def no_duplicate_attachments
    return unless attachments.attached?

    existing_checksums = attachments.blobs.reject(&:new_record?).map(&:checksum)
    new_checksums = []

    attachments.blobs.select(&:new_record?).each do |blob|
      if existing_checksums.include?(blob.checksum) || new_checksums.include?(blob.checksum)
        errors.add(:attachments, "file '#{blob.filename}' is already attached or duplicated")
      else
        new_checksums << blob.checksum
      end
    end
  end
  
  has_many :comments, dependent: :destroy
  has_many :activities, dependent: :destroy

  has_many_attached :attachments

  scope :filter_by_status, ->(names) { joins(:status).where(statuses: { name: names }) if names.present? }
  scope :filter_by_priority, ->(names) { joins(:priority).where(priorities: { name: names }) if names.present? }
  scope :filter_by_severity, ->(names) { joins(:severity).where(severities: { name: names }) if names.present? }
  scope :filter_by_type, ->(names) { joins(:issue_type).where(issue_types: { name: names }) if names.present? }
end
