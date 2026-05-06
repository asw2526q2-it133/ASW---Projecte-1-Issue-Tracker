class Severity < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :issues

  before_destroy :prevent_deleting_last_one
  before_destroy :check_for_associated_issues

  private

  def prevent_deleting_last_one
    if Severity.count <= 1
      errors.add(:base, "No es pot esborrar la darrera severitat. Ha de quedar almenys una al sistema.")
      throw :abort
    end
  end

  def check_for_associated_issues
    if Issue.where(severity_id: self.id).any?
      errors.add(:base, "No es pot eliminar la severitat '#{self.name}' perquè està sent utilitzada per una o més Issues.")
      throw :abort
    end
  end
end
