class AddAssigneeToIssues < ActiveRecord::Migration[8.1]
  def change
    add_column :issues, :assignee_id, :integer
  end
end
