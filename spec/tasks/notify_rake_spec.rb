# frozen_string_literal: true

RSpec.describe "Notify rake tasks" do
  describe "notify:send_email" do
    let(:email_address) { "x@y.com" }
    before { Rake::Task["notify:send_email"].reenable }

    it "sends an email notification via GOV.UK Notify" do
      template_id = SecureRandom.uuid
      body = "Body content"
      subject = "A subject line"

      ClimateControl.modify(TEMPLATE_ID: template_id, BODY: body, SUBJECT: subject) do
        expect { Rake::Task["notify:send_email"].invoke(email_address) }
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    it "raises an error if email address is not present" do
      expect { Rake::Task["notify:send_email"].invoke }
        .to raise_error("Missing email address")
    end

    it "uses default values if optional values not provided" do
      Rake::Task["notify:send_email"].invoke(email_address)
      message = ActionMailer::Base.deliveries.last

      expect(message[:template_id].to_s).to eq("759acac6-da53-4a19-b591-b7538c7c39de")
      expect(message.body.raw_source).to eq("This is a test email notification")
      expect(message.subject).to eq("Test email notification")
    end
  end
end
