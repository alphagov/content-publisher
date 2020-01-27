# frozen_string_literal: true

class DocumentType::TitleAndBasePathField
  def id
    "title_and_base_path"
  end

  def payload(edition)
    {
      base_path: edition.base_path,
      title: edition.title,
      routes: [
        { path: edition.base_path, type: "exact" },
      ],
    }
  end
end
