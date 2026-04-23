class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :omniauthable, omniauth_providers: [ :github ]

  has_many :issue_watchers, dependent: :destroy
  has_many :watched_issues, through: :issue_watchers, source: :issue
  has_many :comments, dependent: :destroy
  has_many :assigned_issues, class_name: "Issue", foreign_key: "assignee_id"

  has_one_attached :avatar

  validates :bio, length: { maximum: 500, message: "es demasiado larga (máximo 500 caracteres)" }
  validate :avatar_content_type
  validate :avatar_size

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.full_name = auth.info.name
    end
  end

  private

  def avatar_content_type
    if avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:avatar, "debe ser una imagen JPEG, PNG o WEBP")
    end
  end

  def avatar_size
    if avatar.attached? && avatar.byte_size > 5.megabytes
      errors.add(:avatar, "es demasiado grande (máximo 5MB)")
    end
  end
end
