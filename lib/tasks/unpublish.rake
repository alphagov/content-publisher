# frozen_string_literal: true

namespace :unpublish do
  desc "Retire a document on GOV.UK e.g. unpublish:retire_document['a-content-id'] NOTE='A note'"
  task :retire_document, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id
    raise "Missing NOTE value" if ENV["NOTE"].blank?

    explanatory_note = ENV["NOTE"]
    locale = ENV["LOCALE"] || "en"

    document = Document.find_by!(content_id: args.content_id, locale: locale)
    raise "Document must have a published version before it can be retired" unless document.has_live_version_on_govuk

    DocumentUnpublishingService.new.retire(document, explanatory_note)
  end

  desc "Remove a document from GOV.UK e.g. unpublish:remove_document['a-content-id']"
  task :remove_document, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    locale = ENV["LOCALE"] || "en"

    document = Document.find_by!(content_id: args.content_id, locale: locale)

    DocumentUnpublishingService.new.remove(document)
  end
end
