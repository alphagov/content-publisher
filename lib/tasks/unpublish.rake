# frozen_string_literal: true

namespace :unpublish do
  desc "Retire a document"
  task :retire_document, %I(base_path explanatory_note) => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path
    raise "Missing explanatory_note parameter" unless args.explanatory_note

    document = Document.find_by(base_path: args.base_path)

    DocumentUnpublishingService.new.retire(document, args.explanatory_note) if document.present?
  end

  desc "Remove a document"
  task :remove_document, [:base_path] => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path

    document = Document.find_by(base_path: args.base_path)

    DocumentUnpublishingService.new.remove(document) if document.present?
  end
end
