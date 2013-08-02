class Sample < ActiveRecord::Base
  
  belongs_to :widget
  after_save :check_for_notifications
  
  def check_for_notifications
  	# send alert notification if status has changed to'alert' since 3 samples
  	# don't send notification if already sent

  	# send recovery notification if status has changed to 'ok' since 3 samples
  	# don't send notification if already sent
    logger.debug "check_for_notifications"
  end
end
