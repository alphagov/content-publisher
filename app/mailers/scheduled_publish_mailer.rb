# frozen_string_literal: true

class ScheduledPublishMailer < ApplicationMailer
  self.delivery_job = EmailDeliveryJob

  add_template_helper(EditionUrlHelper)

  def success_email(edition, user)
    @user = user
    @edition = edition
    @status = edition.status

    unless @status.published? || @status.published_but_needs_2i?
      raise "Cannot send publish email with a non-published state"
    end

    mail(to: user.email, subject: success_subject)
  end

  def failure_email(edition, user)
    @edition = edition
    @status = edition.status

    mail(to: user.email,
         subject: I18n.t("scheduled_publish_mailer.failure_email.subject"))
  end

private

  def success_subject
    if @edition.number > 1
      I18n.t("scheduled_publish_mailer.success_email.subject.update",
             title: @edition.title)
    else
      I18n.t("scheduled_publish_mailer.success_email.subject.#{@status.state}",
             title: @edition.title)
    end
  end
end
