class Widget < ActiveRecord::Base
  has_one     :data_source
  belongs_to  :template
  
  accepts_nested_attributes_for :data_source
  accepts_nested_attributes_for :template
end
