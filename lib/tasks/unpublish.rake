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

    UnpublishService.new.retire(document, explanatory_note, nil)
  end

  desc "Remove a document from GOV.UK e.g. unpublish:remove_document['a-content-id']"
  task :remove_document, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    explanatory_note = ENV["NOTE"]
    alternative_path = ENV["NEW_PATH"]
    locale = ENV["LOCALE"] || "en"

    document = Document.find_by!(content_id: args.content_id, locale: locale)
    raise "Document must have a published version before it can be removed" unless document.has_live_version_on_govuk

    UnpublishService.new.remove(
      document,
      explanatory_note: explanatory_note,
      alternative_path: alternative_path,
    )
  end

  desc "Remove and redirect a document on GOV.UK e.g. unpublish:remove_and_redirect_document['a-content-id'] NEW_PATH='/redirect-to-here'"
  task :remove_and_redirect_document, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id
    raise "Missing NEW_PATH value" if ENV["NEW_PATH"].blank?

    explanatory_note = ENV["NOTE"]
    redirect_path = ENV["NEW_PATH"]
    locale = ENV["LOCALE"] || "en"

    document = Document.find_by!(content_id: args.content_id, locale: locale)
    raise "Document must have a published version before it can be redirected" unless document.has_live_version_on_govuk

    UnpublishService.new.remove_and_redirect(
      document,
      redirect_path,
      explanatory_note: explanatory_note,
    )
  end
end
