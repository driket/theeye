class ReportMailer < ActionMailer::Base
  default from: Settings.notification_mail

  def report(days)
    
    @probes = ::Probe.all
    @days   = days
    
    mail(:to => Settings.admin_mail, :subject => "TheEye report")  
  end  
end
