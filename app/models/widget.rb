class Widget < ActiveRecord::Base
  has_one     :data_source
  has_many    :thresholds
  belongs_to  :template
  
  accepts_nested_attributes_for :data_source
  accepts_nested_attributes_for :thresholds
  accepts_nested_attributes_for :template
  
  scope :sorted, Widget.order('position ASC')
  
  def Widget.sort! (widget_id_array)
    widget_id_array.each_with_index do |widget_id, index|
      widget = Widget.find(widget_id.gsub('widget-',''))
      widget.position = index
      widget.save!
    end
    puts 'yeah'
  end
end
