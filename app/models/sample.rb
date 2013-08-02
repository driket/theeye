class Sample < ActiveRecord::Base
  
  belongs_to :widget
  after_save :check_for_notifications
  
  SAMPLE_STATUS_OK            = 0
  SAMPLE_STATUS_ALERT         = 1
  SAMPLE_STATUS_WARNING       = 2
  SAMPLE_STATUS_UNRESPONSIVE  = 3
  
  NOTIFICATION_STATUS_PROBLEM   = 10
  NOTIFICATION_STATUS_RECOVERY  = 11
  
  def check_for_notifications
  	# send alert notification if status has changed to'alert' since 3 samples
  	# don't send notification if already sent
    if widget.has_same_status_several_times?(SAMPLE_STATUS_ALERT, 3)
      if !widget.notifications.last or widget.notifications.last.status != NOTIFICATION_STATUS_PROBLEM
        notification = Notification.new ({
          :widget_id  => widget.id,
          :date       => DateTime.now,
          :status     => NOTIFICATION_STATUS_PROBLEM
        })
        notification.save!
        logger.debug 'problem notification'
      end
    end

  	# send recovery notification if status has changed to 'ok' since 3 samples
  	# don't send notification if already sent
    if widget.has_same_status_several_times?(SAMPLE_STATUS_OK, 3)
      logger.debug 'ok status for at least 3 times'
      if !widget.notifications.last or widget.notifications.last.status != NOTIFICATION_STATUS_RECOVERY
        notification = Notification.new ({
          :widget_id  => widget.id,
          :date       => DateTime.now,
          :status     => NOTIFICATION_STATUS_RECOVERY
        })
        notification.save!
        logger.debug 'recovery notification'
      end
    end    
  end
end
