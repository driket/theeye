class CreateSamples < ActiveRecord::Migration
  def change
    create_table :samples do |t|
      t.float :value
      t.date :date
      t.integer :widget_id
      t.integer :status
      t.string :details

      t.timestamps
    end
  end
end
