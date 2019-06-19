# frozen_string_literal: true

class PublishMailer < ApplicationMailer
  helper :scheduling, :edition_url

  self.delivery_job = EmailDeliveryJob

  def publish_email(recipient, edition, status)
    @edition = edition
    @status = status

    unless status.published? || status.published_but_needs_2i?
      raise "Cannot send publish email for a #{status.state} state"
    end

    mail(to: recipient.email, subject: subject)
  end

private

  def subject
    if @edition.number > 1
      I18n.t("publish_mailer.publish_email.subject.update",
             title: @edition.title)
    else
      I18n.t("publish_mailer.publish_email.subject.#{@status.state}",
             title: @edition.title)
    end
  end
end
