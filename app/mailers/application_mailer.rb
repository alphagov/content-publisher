require "notify"

class ApplicationMailer < Mail::Notify::Mailer
  def default_url_options
    { host: Plek.new.external_url_for("content-publisher") }
  end

  def template_id
    ENV.fetch("GOVUK_NOTIFY_TEMPLATE_ID", "fake-test-template-id")
  end
end
