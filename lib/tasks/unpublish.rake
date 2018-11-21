# frozen_string_literal: true

namespace :unpublish do
  desc "Retire a document on GOV.UK e.g. unpublish:retire_document CONTENT_ID='a-content-id' NOTE='A note'"
  task retire_document: :environment do
    raise "Missing CONTENT_ID value" if ENV["CONTENT_ID"].nil?
    raise "Missing NOTE value" if ENV["NOTE"].nil?

    content_id = ENV["CONTENT_ID"]
    explanatory_note = ENV["NOTE"]

    document = Document.find_by(content_id: content_id)
    DocumentUnpublishingService.new.retire(document, explanatory_note) if document.present?
  end

  desc "Remove a document from GOV.UK e.g. unpublish:remove_document CONTENT_ID='a-content-id'"
  task remove_document: :environment do
    raise "Missing CONTENT_ID value" if ENV["CONTENT_ID"].nil?

    content_id = ENV["CONTENT_ID"]
    document = Document.find_by(content_id: content_id)

    DocumentUnpublishingService.new.remove(document) if document.present?
  end

  desc "Remove and redirect a document on GOV.UK e.g. unpublish:remove_and_redirect_document CONTENT_ID='a-content-id' REDIRECT='/redirect-to-here'"
  task remove_and_redirect_document: :environment do
    raise "Missing CONTENT_ID value" if ENV["CONTENT_ID"].nil?
    raise "Missing REDIRECT value" if ENV["REDIRECT"].nil?

    content_id = ENV["CONTENT_ID"]
    redirect_path = ENV["REDIRECT"]

    document = Document.find_by(content_id: content_id)

    DocumentUnpublishingService.new.remove_and_redirect(document, redirect_path) if document.present?
  end
end
