# frozen_string_literal: true

class PublishMailer < ApplicationMailer
  self.delivery_job = EmailDeliveryJob

  def publish_email(edition, user)
    @user = user
    @edition = edition
    @status = edition.status

    unless @status.published? || @status.published_but_needs_2i?
      raise "Cannot send publish email with a non-published state"
    end

    mail(to: user.email, subject: subject)
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
