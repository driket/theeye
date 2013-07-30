class Widget < ActiveRecord::Base
  
  has_many    :thresholds
  belongs_to  :probe
  
  accepts_nested_attributes_for :thresholds
  
  scope :sorted, Widget.order('position ASC')
  
  def fetch_default_values 
    index_url = probe.url + '/' + uri.split('/')[0]+'/index'
    widget_command = uri.split('/')[1]
    index_data = JSON.parse(open("#{index_url}").read)
    logger.debug "index_url: #{index_url}"
    logger.debug "index_data: #{index_data}"
    for data in index_data
      logger.debug "data: #{data} / #{widget_command}"
      if widget_command == data['uri']
        self.unit = data['unit']
        logger.debug "unit = #{data['unit']}"
        self.save!
      end
    end
  end
  
  def Widget.sort! (widget_id_array, probe_id)
    widget_id_array.each_with_index do |widget_id, index|
      widget = Widget.find(widget_id.gsub('widget-',''))
      widget.position = index
      widget.save!
    end
  end
  
  def url
    if probe
      probe.url + '/' + uri
    else
      uri
    end
  end
end
