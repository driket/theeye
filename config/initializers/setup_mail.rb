ActionMailer::Base.smtp_settings = {  
  :address              => Settings.mailer.address,  
  :port                 => Settings.mailer.port,  
  :domain               => Settings.mailer.domain,  
  :user_name            => Settings.mailer.user_name,  
  :password             => Settings.mailer.password,  
  :authentication       => Settings.mailer.authentication,
  :enable_starttls_auto => true,
}  