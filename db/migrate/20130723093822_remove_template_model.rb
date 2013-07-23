class RemoveTemplateModel < ActiveRecord::Migration
  def change
    remove_column :widgets, :template_id
    add_column    :widgets, :template, :string, :default => 'widget-graph'
  end
end
