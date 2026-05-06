class IssueType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :prevent_deleting_last_one
  before_destroy :check_for_associated_issues

  private

  def prevent_deleting_last_one
    if IssueType.count <= 1
      errors.add(:base, "No es pot suprimir el darrer tipus. Ha de quedar almenys un al sistema.")
      throw :abort
    end
  end

  def check_for_associated_issues
    if Issue.where(issue_type_id: self.id).any?
      errors.add(:base, "No es pot eliminar el tipus '#{self.name}' perquè està sent utilitzat per una o més Issues.")
      throw :abort
    end
  end
end
