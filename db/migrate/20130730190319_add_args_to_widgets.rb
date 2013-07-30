class AddArgsToWidgets < ActiveRecord::Migration
  def change
    add_column :widgets, :args, :string

  end
end
