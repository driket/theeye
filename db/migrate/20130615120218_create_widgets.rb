class CreateWidgets < ActiveRecord::Migration
  def change
    create_table :widgets do |t|
      t.string :title
      t.string :url
      t.references :template

      t.timestamps
    end
    add_index :widgets, :template_id
  end
end
