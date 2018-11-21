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

  desc "Remove a document"
  task :remove_document, [:base_path] => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path

    document = Document.find_by(base_path: args.base_path)

    DocumentUnpublishingService.new.remove(document) if document.present?
  end

  desc "Remove and redirect a document"
  task :remove_and_redirect_document, %I(base_path redirect_path) => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path
    raise "Missing redirect_path parameter" unless args.redirect_path

    document = Document.find_by(base_path: args.base_path)

    DocumentUnpublishingService.new.remove_and_redirect(document, args.redirect_path) if document.present?
  end
end
