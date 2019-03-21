if ENV.fetch("EMAIL_ADDRESS_OVERRRIDE", nil)
  ActionMailer::Base.register_interceptor(MailRecipientInterceptor)
end
