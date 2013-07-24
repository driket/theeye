class Probe < ActiveRecord::Base

  has_many :widgets
  accepts_nested_attributes_for :widgets, :allow_destroy => true
  
  before_validation :fetch_probe_default_data
  
  def fetch_probe_default_data 
    logger.debug "---------> record = #{self}"
    # list all widgets and set their default values
    for widget in widgets
      widget_command_data = widget.fetch_default_values
    end
  end
  
  require 'open-uri'
  require 'json'
  
  def available_uris
    uris = Array.new
    uris << { :title => 'Memory Usage', :path => "memory/usage"}
    if url 
      probe_index = JSON.parse(open("#{url}/index").read)
      # parse probes
      for probe in probe_index
        logger.debug "------------> url : #{url}/#{probe}"
        command_index = JSON.parse(open("#{url}/#{probe}/index").read)
        for command in command_index
          logger.debug "#{command}"    
          title = "#{command['title']} (#{command['unit']})"
          uris << { :title => title, :path => "#{probe}/#{command['uri']}"}
        end
      end
      #logger.debug Net::HTTP.get_response url
      #json = response.body
    end
    uris
  end
end
