class Widget < ActiveRecord::Base
  
  has_many    :thresholds, dependent: :destroy
  has_many    :samples, dependent: :destroy
  has_many    :notifications
  belongs_to  :probe
  
  accepts_nested_attributes_for :thresholds, :allow_destroy => true
  
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
  
  def Widget.record_all_samples!
    
    for widget in Widget.all
      # record sample asynchronously (delayed job)
      widget.delay.record_sample!
    end
  end

  def record_sample!
    
    logger.debug "fetching #{url}"
    begin
      file = open(url, "x-secret" => Settings.probe_secret)     
      content = JSON.parse(file.read)
      logger.debug "content: #{content.inspect}"
    
      sample = Sample.new({
        :widget_id  => id,
        :value      => content['value'].to_f,
        :status     => service_status_for_value(content['value'].to_f),
        :date       => content['date'],
        :details    => content['details'],
      })
    rescue
      logger.debug "can't access #{url} -> unresponsive"
      sample = Sample.new({
        :widget_id  => id,
        :value      => -1,
        :status     => STATUS['unresponsive'],
        :date       => DateTime.now,
        :details    => {},
      })
    end
    sample.save!
  end
  
  def status
    return -1 if !samples.last
    value = samples.last.value
    service_status_for_value(value)
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
			elsif threshold.operator == '=='
				return STATUS[threshold.alert] if value == threshold.value				
			elsif threshold.operator == '='
				return STATUS[threshold.alert] if value == threshold.value				
			else
				logger.debug '(service_status_for_value) invalid comparison operator: ' + threshold.operator
      end
    end
    return STATUS['ok']
  end
  
  def has_same_status_several_times?(status, times)
    last_samples = samples.last(times)

    return false if last_samples.size < times

    for sample in last_samples
      return false if sample.status != status
    end
        
    return true    
  end
  
  def Widget.sort! (widget_id_array)
    
    widget_id_array.each_with_index do |widget_id, index|
      widget = Widget.find(widget_id.gsub('widget-',''))
      widget.position = index
      widget.save!
    end
  end
  
  def process_samples(days)
    data = {}
    begin
      data['samples'] = samples.where("created_at > :week", {:week => days.day.ago}).order('date ASC')
      data['average'] = data['samples'].average(:value).round(3)
      data['max']     = data['samples'].maximum(:value)
      data['graph']   = data['samples'].map { |s| s.value }.join(',')
      data['encoded_graph'] = Widget.encode_samples(data['samples'], max)
    rescue
      data['samples'] = []
      data['average'] = -1
      data['max']     = 0
      data['encoded_graph'] = Widget.encode_samples(data['samples'], max)
    end
    return data
  end
  
  def Widget.encode_samples(samples, max_value)
    sample_array = samples.map { |s| s.value } #.join ','
    simpleEncoding = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    chart_data = ['s:']
    if max_value == 0
      max_value = 1
    end
    for sample in sample_array
      if sample < 0 
        chart_data << '_'
      else
        index = ((simpleEncoding.size-1) * sample / max_value)
        if !index.nan?
          chart_data << simpleEncoding[index.round]
        else
          chart_data << '_'          
        end
      end
    end
    return chart_data.join ''
  end
  
  def url
    
    if probe
      #formated_args = args.replace(/&amp;/g, '&')
      if args && args != ''
        "#{probe.url}/#{uri}?#{args}"
      else
        "#{probe.url}/#{uri}"        
      end
    else
      ''
    end
  end
end
