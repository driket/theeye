class CreateDataSources < ActiveRecord::Migration
  def change
    create_table :data_sources do |t|
      t.string :json_url
      t.references :widget

      t.timestamps
    end
    add_index :data_sources, :widget_id
  end
end
