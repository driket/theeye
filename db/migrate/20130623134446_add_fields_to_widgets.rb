class AddFieldsToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :min,            :float,   :default => 0
    add_column :widgets, :max,            :float,   :default => 100
    add_column :widgets, :unit,           :string,  :default => '%'
    add_column :widgets, :refresh_delay,  :string,  :default => 1000
  end
end
