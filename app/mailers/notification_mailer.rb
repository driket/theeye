class NotificationMailer < ActionMailer::Base
  default from: Settings.notification_mail

  
  def notification(notification)
    
    status = ""
    if notification.status == 10
      status = "problem"
    elsif notification.status == 11
      status = "recovery"
    elsif notification.status == 12
      status = "unresponsive"
    end

    @notification = notification
    @status = status
    @health = ::Probe.global_health
    
    mail(:to => Settings.admin_mail, :subject => "[#{@health}%] Service #{status} on #{notification.widget.probe.title}")  
  end  
end
