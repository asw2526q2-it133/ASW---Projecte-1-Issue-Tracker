class IssueType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :check_for_associated_issues

  private

  def check_for_associated_issues
    # Buscamos en la columna 'issue_type' de los Issues
    if Issue.where(issue_type: self.name).any?
      errors.add(:base, "No se puede eliminar el tipo '#{self.name}' porque está siendo usado por uno o más Issues.")
      throw :abort
    end
  end
end
