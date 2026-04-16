class CreateSeverities < ActiveRecord::Migration[8.1]
  def change
    create_table :severities do |t|
      t.string :name
      t.string :color

      t.timestamps
    end
  end
end
