class PublishMailer < ApplicationMailer
  helper :edition_url

  self.delivery_job = EmailDeliveryJob

  def publish_email(recipient, edition, status)
    @edition = edition
    @status = status

    unless status.published? || status.published_but_needs_2i?
      raise "Cannot send publish email for a #{status.state} state"
    end

    view_mail(template_id, to: recipient.email, subject:)
  end

private

  def subject
    if @edition.first?
      I18n.t("publish_mailer.publish_email.subject.#{@status.state}",
             title: @edition.title)
    else
      I18n.t("publish_mailer.publish_email.subject.update",
             title: @edition.title)
    end
  end
end
