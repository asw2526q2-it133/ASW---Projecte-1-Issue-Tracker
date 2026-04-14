class CreatePriorities < ActiveRecord::Migration[8.1]
  def change
    create_table :priorities do |t|
      t.string :name
      t.string :color

      t.timestamps
    end
  end
end
