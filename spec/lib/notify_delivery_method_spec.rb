# frozen_string_literal: true

RSpec.describe NotifyDeliveryMethod do
  describe "#deliver!" do
    it "calls Notify's send_email endpoint" do
      headers = { to: "x@y.com",
                  body: "Body content",
                  subject: "A subject line" }

      template_id = SecureRandom.uuid
      message = Mail::Message.new(headers)
      client = instance_double(Notifications::Client)

      allow(Notifications::Client).to receive(:new)
        .with("api-key").and_return(client)

      expect(client).to receive(:send_email)
        .with(email_address: headers[:to],
              template_id: template_id,
              personalisation: {
                body: headers[:body],
                subject: headers[:subject],
              })

      method = NotifyDeliveryMethod.new(notify_api_key: "api-key", template_id: template_id)
      method.deliver!(message)
    end

    it "raises an exception for multiple recipients" do
      headers = { to: ["x@y.com", "a@b.com"],
                  body: "Body content",
                  subject: "A subject line" }

      template_id = SecureRandom.uuid
      message = Mail::Message.new(headers)
      client = instance_double(Notifications::Client)

      allow(Notifications::Client).to receive(:new)
        .with("api-key").and_return(client)

      method = NotifyDeliveryMethod.new(notify_api_key: "api-key", template_id: template_id)

      expect { method.deliver!(message) }.to raise_error(
        RuntimeError,
        "Sending emails with multiple recipients is not supported",
      )
    end
  end
end
