# frozen_string_literal: true

class DocumentType::BodyField
  def id
    "body"
  end

  def type
    "govspeak"
  end

  def payload(edition)
    {
      details: {
        body: GovspeakDocument.new(edition.contents[id], edition).payload_html,
      },
    }
  end
end
