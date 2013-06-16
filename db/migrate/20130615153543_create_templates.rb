class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :uid
      t.text :body
      t.references :widget

      t.timestamps
    end
  end
end
