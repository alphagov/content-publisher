# frozen_string_literal: true

namespace :unpublish do
  desc "Remove a document from GOV.UK e.g. unpublish:remove['a-content-id']"
  task :remove, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id

    explanatory_note = ENV["NOTE"]
    alternative_path = ENV["NEW_PATH"]
    locale = ENV["LOCALE"] || "en"

    document = Document.find_by!(content_id: args.content_id, locale: locale)
    raise "Document must have a published version before it can be removed" unless document.live_edition

    removal = Removal.new(explanatory_note: explanatory_note,
                          alternative_path: alternative_path)

    RemoveService.call(document.live_edition, removal)
  end

  desc "Remove and redirect a document on GOV.UK e.g. unpublish:remove_and_redirect['a-content-id'] NEW_PATH='/redirect-to-here'"
  task :remove_and_redirect, [:content_id] => :environment do |_, args|
    raise "Missing content_id parameter" unless args.content_id
    raise "Missing NEW_PATH value" if ENV["NEW_PATH"].blank?

    explanatory_note = ENV["NOTE"]
    redirect_path = ENV["NEW_PATH"]
    locale = ENV["LOCALE"] || "en"

    document = Document.find_by!(content_id: args.content_id, locale: locale)
    raise "Document must have a published version before it can be redirected" unless document.live_edition

    removal = Removal.new(redirect: true,
                          explanatory_note: explanatory_note,
                          alternative_path: redirect_path)

    RemoveService.call(document.live_edition, removal)
  end
end
