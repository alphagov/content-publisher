# frozen_string_literal: true

require "mail_recipient_interceptor"

RSpec.describe MailRecipientInterceptor do
  describe "#delivering_email" do
    it "intercepts emails and sends to an allow-listed email address" do
      mail = Mail.new(to: "not-allowed@example.com")

      ClimateControl.modify(GOVUK_NOTIFY_ALLOW_LIST: "allowed@example.com") do
        MailRecipientInterceptor.delivering_email(mail)
      end

      expect(mail.to).to include("allowed@example.com")
    end
  end
end
