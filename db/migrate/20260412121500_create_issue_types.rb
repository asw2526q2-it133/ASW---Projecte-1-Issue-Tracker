class CreateIssueTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :issue_types do |t|
      t.string :name
      t.string :color

      t.timestamps
    end
  end
end
