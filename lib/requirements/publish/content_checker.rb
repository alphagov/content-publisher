class Requirements::Publish::ContentChecker < Requirements::Checker
  attr_reader :edition

  def initialize(edition, **)
    @edition = edition
  end

  def check
    edition.document_type.contents.each do |field|
      issues.push(*field.publish_issues(edition))
    end

    if edition.document.live_edition &&
        edition.update_type == "major" &&
        edition.change_note.blank?
      issues.create(:change_note, :blank)
    end
  end
end
