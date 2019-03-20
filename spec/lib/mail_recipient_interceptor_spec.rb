# frozen_string_literal: true

require "mail_recipient_interceptor"

RSpec.describe MailRecipientInterceptor do
  describe "#delivering_email" do
    let(:original_recipient) { "not-allowed@example.com" }
    let(:mail) { Mail.new(to: original_recipient) }

    before do
      ClimateControl.modify(EMAIL_ADDRESS_OVERRIDE: "allowed@example.com") do
        MailRecipientInterceptor.delivering_email(mail)
      end
    end

    it "intercepts emails and sends to an allow-listed email address" do
      expect(mail.to).to include("allowed@example.com")
    end

    it "intercepts emails and prefixes the original recipient to the body" do
      expect(mail.body.raw_source).to include(original_recipient)
    end
  end
end
