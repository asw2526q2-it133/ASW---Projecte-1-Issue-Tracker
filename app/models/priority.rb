class Priority < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  has_many :issues
  before_destroy :check_for_associated_issues

  private

  def check_for_associated_issues
    # OJO AQUÍ: Buscamos en la columna 'priority' de los Issues
    if Issue.where(priority: self.name).any?
      errors.add(:base, "No se puede eliminar la prioridad '#{self.name}' porque está siendo usada por uno o más Issues.")
      throw :abort
    end
  end
end
