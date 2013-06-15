class Widget < ActiveRecord::Base
  has_many  :data_sources
  has_one   :template
  
  accepts_nested_attributes_for :data_sources
  accepts_nested_attributes_for :template
end
