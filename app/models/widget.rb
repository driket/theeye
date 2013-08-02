class Widget < ActiveRecord::Base
  
  has_many    :thresholds
  belongs_to  :probe
  
  accepts_nested_attributes_for :thresholds
  
  scope :sorted, Widget.order('position ASC')

  require 'open-uri'
  require 'json'
  require 'socket'  
  
  STATUS = {
    'ok'            => 0,
    'alert'         => 1,
    'warning'       => 2,
    'unresponsive'  => 3,
  }

  def record_sample!
    
    file = open(url, "x-secret" => Settings.probe_secret)     
    content = JSON.parse(file.read)
    logger.debug "content: #{content.inspect}"
    alert = service_status_for_value(content['value'].to_f)
    logger.debug "alert level: #{alert}"
  end
  
  def service_status_for_value(value)
    
    return STATUS['ok'] if !thresholds
    
    for threshold in thresholds
			if threshold.operator == '>='
				return STATUS[threshold.alert] if value >= threshold.value	
			elsif threshold.operator == '>'
				return STATUS[threshold.alert] if value > threshold.value				
			elsif threshold.operator == '<'
				return STATUS[threshold.alert] if value < threshold.value				
			elsif threshold.operator == '<='
				return STATUS[threshold.alert] if value <= threshold.value				
			else
				logger.debug '(service_status_for_value) invalid comparison operator: ' + threshold.operator
      end
    end
    return STATUS['ok']
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
