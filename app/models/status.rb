class Status < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :check_for_associated_issues

  private

  def check_for_associated_issues
    if Issue.where(status: self.name).any?
      errors.add(:base, "No se puede eliminar. Está siendo usado por uno o más Issues.")
      throw :abort
    end
  end
end
