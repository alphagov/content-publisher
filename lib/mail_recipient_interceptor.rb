# frozen_string_literal: true

class MailRecipientInterceptor
  def self.delivering_email(message)
    body_prefix = "Intended recipient(s): #{message.to.join(', ')}\n"

    message.body = body_prefix + message.body.raw_source
    message.to = ENV["GOVUK_NOTIFY_ALLOW_LIST"]
  end
end
