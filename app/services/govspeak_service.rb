# frozen_string_literal: true

class GovspeakService
  def to_html(text)
    Govspeak::Document.new(text).to_html
  end
end
