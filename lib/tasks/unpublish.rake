# frozen_string_literal: true

namespace :unpublish do
  desc "Retire a document on GOV.UK e.g. unpublish:retire_document BASE_PATH='/base-path' NOTE='A note'"
  task retire_document: :environment do
    raise "Missing BASE_PATH value" if ENV["BASE_PATH"].nil?
    raise "Missing NOTE value" if ENV["NOTE"].nil?

    base_path = ENV["BASE_PATH"]
    explanatory_note = ENV["NOTE"]

    document = Document.find_by(base_path: base_path)
    DocumentUnpublishingService.new.retire(document, explanatory_note) if document.present?
  end

  desc "Remove a document from GOV.UK e.g. unpublish:remove_document BASE_PATH='/base-path'"
  task remove_document: :environment do
    raise "Missing BASE_PATH value" if ENV["BASE_PATH"].nil?

    base_path = ENV["BASE_PATH"]
    document = Document.find_by(base_path: base_path)

    DocumentUnpublishingService.new.remove(document) if document.present?
  end

  desc "Remove and redirect a document on GOV.UK e.g. unpublish:remove_and_redirect_document CONTENT_ID='a-content-id' REDIRECT='/redirect-to-here'"
  task remove_and_redirect_document: :environment do
    raise "Missing CONTENT_ID value" if ENV["CONTENT_ID"].nil?
    raise "Missing REDIRECT value" if ENV["REDIRECT"].nil?

    base_path = ENV["BASE_PATH"]
    redirect_path = ENV["REDIRECT"]

    document = Document.find_by(base_path: base_path)

    DocumentUnpublishingService.new.remove_and_redirect(document, redirect_path) if document.present?
  end
end
