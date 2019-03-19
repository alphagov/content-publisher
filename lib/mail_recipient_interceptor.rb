# frozen_string_literal: true

class MailRecipientInterceptor
  def self.delivering_email(message)
    message.to = ENV["GOVUK_NOTIFY_ALLOW_LIST"]
  end
end
