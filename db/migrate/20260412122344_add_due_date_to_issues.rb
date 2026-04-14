class AddDueDateToIssues < ActiveRecord::Migration[8.1]
  def change
    add_column :issues, :due_date, :date
  end
end
