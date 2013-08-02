class Sample < ActiveRecord::Base
  
  belongs_to :widget
  after_save :check_for_notifications
  
  SAMPLE_STATUS_OK            = 0
  SAMPLE_STATUS_ALERT         = 1
  SAMPLE_STATUS_WARNING       = 2
  SAMPLE_STATUS_UNRESPONSIVE  = 3
  
  def check_for_notifications
  	# send alert notification if status has changed to'alert' since 3 samples
  	# don't send notification if already sent
    if widget.has_same_status_several_times?(SAMPLE_STATUS_ALERT, 3)
      logger.debug 'alert for at least 3 times'
    else
      logger.debug 'nothing'      
    end

  	# send recovery notification if status has changed to 'ok' since 3 samples
  	# don't send notification if already sent
    if widget.has_same_status_several_times?(SAMPLE_STATUS_OK,3)
      logger.debug 'ok status for at least 3 times'
    else
      logger.debug 'nothing'      
    end    
  end
end