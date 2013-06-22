class CreateThresholds < ActiveRecord::Migration
  def change
    create_table :thresholds do |t|
      t.string :operator
      t.float  :value
      t.string :alert
      t.references :widget

      t.timestamps
    end
    add_index :thresholds, :widget_id
  end
end
