class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
  has_many :issue_tags, dependent: :destroy
  has_many :issues, through: :issue_tags

  before_destroy :prevent_deleting_last_one
  before_destroy :check_for_associated_issues

  private

  def prevent_deleting_last_one
    if Tag.count <= 1
      errors.add(:base, "No es pot esborrar el darrer tag. Ha de quedar almenys un al sistema.")
      throw :abort
    end
  end

  def check_for_associated_issues
    if issue_tags.any?
      errors.add(:base, "El tag està en ús per una o més issues. Has de reassignar-ho a un altre tag abans d'esborrar-ho.")
      throw :abort
    end
  end
end