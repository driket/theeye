class Widget < ActiveRecord::Base
  has_many    :data_sources
  belongs_to  :template
  
  accepts_nested_attributes_for :data_sources
  accepts_nested_attributes_for :template
end
