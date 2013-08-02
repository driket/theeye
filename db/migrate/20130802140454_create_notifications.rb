class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :widget_id
      t.datetime :date
      t.integer :status

      t.timestamps
    end
  end
end
