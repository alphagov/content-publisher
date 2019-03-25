# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  def default_url_options
    { host: Plek.new.external_url_for("content-publisher") }
  end
end
