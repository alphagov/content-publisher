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
  task :remove_document, %I(base_path redirect_path) => :environment do |_, args|
    raise "Missing base_path parameter" unless args.base_path

    document = Document.find_by(base_path: args.base_path)

    if document.present?
      if args.redirect_path.present?
        DocumentUnpublishingService.new.remove(document, redirect_path: args.redirect_path)
      else
        DocumentUnpublishingService.new.remove(document)
      end
    end
  end
end
