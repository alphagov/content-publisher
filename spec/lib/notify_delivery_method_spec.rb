# frozen_string_literal: true

RSpec.describe NotifyDeliveryMethod do
  describe "#deliver!" do
    it "calls Notify's send_email endpoint" do
      headers = { to: "x@y.com", template_id: SecureRandom.uuid }
      personalisation = { body: "Body content", subject: "A subject line" }
      message = Mail::Message.new(headers.merge(personalisation))

      client = instance_double("Notifications::Client")
      allow(Notifications::Client).to receive(:new).and_return(client)

      expect(client).to receive(:send_email)
        .with(email_address: headers[:to],
              template_id: headers[:template_id],
              personalisation: personalisation)

      NotifyDeliveryMethod.new(api_key: "api-key").deliver!(message)
    end
  end
end
