class Probe < ActiveRecord::Base

  has_many :widgets
  accepts_nested_attributes_for :widgets, :allow_destroy => true
  
end
