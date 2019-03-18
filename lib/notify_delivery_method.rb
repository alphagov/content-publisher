# frozen_string_literal: true

require "notifications/client"

class NotifyDeliveryMethod
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    client.send_email(payload(mail))
  end

private

  def client
    @client ||= Notifications::Client.new(settings[:notify_api_key])
  end

  def payload(mail)
    {
      email_address: mail.to.first,
      template_id: mail[:template_id].to_s,
      personalisation: {
        body: mail.body.raw_source,
        subject: mail.subject,
      },
    }
  end
end
