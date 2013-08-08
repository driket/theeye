class Sample < ActiveRecord::Base
  
  belongs_to :widget
  after_save :check_for_notifications
  
  CHECK_RETRY_BEFORE_NOTIFICATION   = Settings.retries_before_notification || 3
  
  SAMPLE_STATUS_OK                  = 0
  SAMPLE_STATUS_ALERT               = 1
  SAMPLE_STATUS_WARNING             = 2
  SAMPLE_STATUS_UNRESPONSIVE        = 3
  
  NOTIFICATION_STATUS_PROBLEM       = 10
  NOTIFICATION_STATUS_RECOVERY      = 11
  NOTIFICATION_STATUS_UNRESPONSIVE  = 12
    
  def check_for_notifications
  	# send alert notification if status has changed to'alert' since 3 samples
  	# don't send notification if already sent
    if widget.has_same_status_several_times?(SAMPLE_STATUS_ALERT, CHECK_RETRY_BEFORE_NOTIFICATION)
      if !widget.notifications.last or widget.notifications.last.status != NOTIFICATION_STATUS_PROBLEM
        notification = Notification.new ({
          :widget_id  => widget.id,
          :date       => DateTime.now,
          :status     => NOTIFICATION_STATUS_PROBLEM
        })
        notification.save!
        NotificationMailer.notification(notification).deliver
        logger.debug 'problem notification'
      end
    end

  	# send unresponsive notification if status has changed to 'ok' since 3 samples
  	# don't send notification if already sent
    #TODO : IF WAS ALERT ONLY
    if widget.has_same_status_several_times?(SAMPLE_STATUS_UNRESPONSIVE, CHECK_RETRY_BEFORE_NOTIFICATION)
      logger.debug 'unresponsive status for at least 3 times'
      if !widget.notifications.last or widget.notifications.last.status != NOTIFICATION_STATUS_UNRESPONSIVE
        notification = Notification.new ({
          :widget_id  => widget.id,
          :date       => DateTime.now,
          :status     => NOTIFICATION_STATUS_UNRESPONSIVE
        })
        notification.save!
        NotificationMailer.notification(notification).deliver
        logger.debug 'unresponsive notification'
      end
    end   
    
  	# send recovery notification if status has changed to 'ok' since 3 samples
  	# send notification only if was PROBLEM or UNRESPONSIVE
    if widget.has_same_status_several_times?(SAMPLE_STATUS_OK, CHECK_RETRY_BEFORE_NOTIFICATION)
      logger.debug 'ok status for at least 3 times'
      if widget.notifications.last and (widget.notifications.last.status == NOTIFICATION_STATUS_UNRESPONSIVE or  widget.notifications.last.status == NOTIFICATION_STATUS_PROBLEM)
        notification = Notification.new ({
          :widget_id  => widget.id,
          :date       => DateTime.now,
          :status     => NOTIFICATION_STATUS_RECOVERY
        })
        notification.save!
        NotificationMailer.notification(notification).deliver
        logger.debug 'recovery notification'
      end
    end    
  end
end
