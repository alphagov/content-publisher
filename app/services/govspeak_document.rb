# frozen_string_literal: true

class GovspeakDocument
  attr_reader :text, :edition

  def initialize(text, edition)
    @text = text
    @edition = edition
  end

  def in_app_html
    in_app_options = InAppOptions.new(text, edition).to_h
    Govspeak::Document.new(text, in_app_options).to_sanitized_html
  end

  def payload_html
    payload_options = PayloadOptions.new(text, edition).to_h
    Govspeak::Document.new(text, payload_options).to_sanitized_html
  end
end
