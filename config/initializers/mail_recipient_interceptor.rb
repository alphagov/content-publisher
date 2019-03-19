if ENV.fetch("GOVUK_NOTIFY_ALLOW_LIST", nil)
  ActionMailer::Base.register_interceptor(MailRecipientInterceptor)
end
