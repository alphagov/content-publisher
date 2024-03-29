class ScheduledPublishMailer < ApplicationMailer
  helper :edition_url

  self.delivery_job = EmailDeliveryJob

  def success_email(recipient, edition, status)
    @edition = edition
    @status = status

    if !status.published? && !status.published_but_needs_2i?
      raise "Cannot send successful publish email for a #{status.state} state"
    end

    view_mail(template_id, to: recipient.email, subject: success_subject)
  end

  def failure_email(recipient, edition, status)
    @edition = edition
    @status = status
    @scheduling = @status.details

    unless @status.failed_to_publish?
      raise "Cannot send failed publish email for a #{status.state} state"
    end

    subject = I18n.t("scheduled_publish_mailer.failure_email.subject",
                     title: edition.title)

    view_mail(template_id, to: recipient.email, subject:)
  end

private

  def success_subject
    if @edition.first?
      I18n.t("scheduled_publish_mailer.success_email.subject.#{@status.state}",
             title: @edition.title)
    else
      I18n.t("scheduled_publish_mailer.success_email.subject.update",
             title: @edition.title)
    end
  end
end
