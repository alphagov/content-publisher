# frozen_string_literal: true

class DocumentUnpublishingService
  def retire(document, explanatory_note)
    GdsApi.publishing_api_v2.unpublish(
      document.content_id,
      type: "withdrawal",
      explanation: explanatory_note,
      locale: document.locale,
    )
  end
end
