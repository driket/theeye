class CreateProbes < ActiveRecord::Migration
  def change
    create_table :probes do |t|
      t.string :title
      t.string :url
      t.integer :position
      t.timestamps
    end
    
    add_column :widgets, :probe_id, :integer
    rename_column :widgets, :url, :uri
   # drop_table :data_sources
  end
end
