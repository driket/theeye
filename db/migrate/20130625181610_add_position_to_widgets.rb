class AddPositionToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :position, :integer, :default => 0
  end
end
