class Widget < ActiveRecord::Base
  has_one     :data_source
  has_many    :thresholds
  belongs_to  :template
  
  accepts_nested_attributes_for :data_source
  accepts_nested_attributes_for :thresholds
  accepts_nested_attributes_for :template
end
