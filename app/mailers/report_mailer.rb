class ReportMailer < ActionMailer::Base
  default from: Settings.notification_mail

  def report(days)
    
    @probes = ::Probe.all
    @days   = days
    @health = ::Probe.global_health
    
    mail(:to => Settings.admin_mail, :subject => "[#{@health}%] TheEye report")  
  end  
end
