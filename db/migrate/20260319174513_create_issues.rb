class CreateIssues < ActiveRecord::Migration[8.1]
  def change
    create_table :issues do |t|
      t.string :subject
      t.text :description
      t.string :issue_type
      t.string :severity
      t.string :priority
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
