class Widget < ActiveRecord::Base
  
  has_many    :thresholds
  belongs_to  :probe
  
  accepts_nested_attributes_for :thresholds
  
  scope :sorted, Widget.order('position ASC')

  require 'open-uri'
  require 'json'
  require 'socket'  

  def record_sample()
    file = open(url, "x-secret" => 'MySeCr3t')     
    content = JSON.parse(file.read)
    logger.debug "content: #{content.inspect}"
  end
  
  def Widget.sort! (widget_id_array)
    widget_id_array.each_with_index do |widget_id, index|
      widget = Widget.find(widget_id.gsub('widget-',''))
      widget.position = index
      widget.save!
    end
  end
  
  def url
    if probe
      #formated_args = args.replace(/&amp;/g, '&')
      if args
        "#{probe.url}/#{uri}?#{args}"
      else
        "#{probe.url}/#{uri}"        
      end
    else
      ''
    end
  end
end
