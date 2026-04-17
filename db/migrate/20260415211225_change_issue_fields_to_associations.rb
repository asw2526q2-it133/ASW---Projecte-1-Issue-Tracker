class ChangeIssueFieldsToAssociations < ActiveRecord::Migration[8.1]
  def change
    # 1. Eliminamos las columnas de tipo string
    remove_column :issues, :issue_type, :string
    remove_column :issues, :priority, :string
    remove_column :issues, :severity, :string
    remove_column :issues, :status, :string

    # 2. Añadimos las columnas de relación (bigints)
    add_column :issues, :issue_type_id, :bigint
    add_column :issues, :priority_id, :bigint
    add_column :issues, :severity_id, :bigint
    add_column :issues, :status_id, :bigint

    # 3. Opcional: añadimos claves foráneas para integridad
    add_foreign_key :issues, :issue_types
    add_foreign_key :issues, :priorities
    add_foreign_key :issues, :severities
    add_foreign_key :issues, :statuses
  end
end
