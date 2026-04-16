class Severity < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :issues
  before_destroy :check_for_associated_issues

  private

  def check_for_associated_issues
    if Issue.where(severity: self.name).any?
      errors.add(:base, "No se puede eliminar la severidad '#{self.name}' porque está siendo usada por uno o más Issues.")
      throw :abort
    end
  end
end
