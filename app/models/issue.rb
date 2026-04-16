class Issue < ApplicationRecord
  has_many_attached :attachments
  validates :subject, presence: true
  validate :no_duplicate_attachments

  # creador de la issue (obligatori)
  belongs_to :user

  # persona a qui se li assigna la issue
  belongs_to :assignee, class_name: "User", optional: true

  #watchers de la issue
  has_many :issue_watchers, dependent: :destroy
  has_many :watchers, through: :issue_watchers, source: :user

  has_many :issue_tags, dependent: :destroy
  has_many :tags, through: :issue_tags

  belongs_to :priority
  belongs_to :issue_type
  belongs_to :severity
  belongs_to :status
  
  private

  def no_duplicate_attachments
    return unless attachments.attached?

    # Sacamos los checksums de los archivos que ya están guardados
    existing_checksums = attachments.blobs.pluck(:checksum)
    
    # Comparamos los nuevos archivos entre sí y con los existentes
    new_checksums = []
    
    attachments.each do |attachment|
      # Si el archivo es nuevo (no se ha guardado aún)
      if attachment.blob.new_record?
        if existing_checksums.include?(attachment.blob.checksum) || new_checksums.include?(attachment.blob.checksum)
          errors.add(:attachments, "file '#{attachment.filename}' is already attached or duplicated")
        end
        new_checksums << attachment.blob.checksum
      end
    end
  end
end