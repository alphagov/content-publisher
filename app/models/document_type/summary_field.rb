# frozen_string_literal: true

class DocumentType::SummaryField
  def id
    "summary"
  end

  def payload(edition)
    { description: edition.summary }
  end
end
